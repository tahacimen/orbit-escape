import SpriteKit
import UIKit

protocol OrbitGameSceneDelegate {
    func gameSceneDidUpdate(escaped: Int, lives: Int)
    func gameSceneDidFinish(won: Bool, elapsed: TimeInterval, remainingLives: Int)
}

final class OrbitGameScene: SKScene {
    var gameDelegate: OrbitGameSceneDelegate?
    private let level: LevelDefinition
    private let hapticsEnabled: Bool
    private let soundEnabled: Bool
    private var core = SKNode()
    private var outerRing = SKNode()
    private var arrows: [CGFloat] = []
    private var escaped = 0
    private var lives: Int
    private var elapsed: TimeInterval = 0
    private var isFinished = false
    private var hasLaunched = false
    private let launchAngle = -CGFloat.pi / 2

    init(size: CGSize, level: LevelDefinition, hapticsEnabled: Bool, soundEnabled: Bool) {
        self.level = level
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.lives = level.lives
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.isMultipleTouchEnabled = false
        buildScene()
    }

    private func buildScene() {
        addStarfield()
        let coreRadius = min(size.width, size.height) * 0.19
        let outerRadius = min(size.width, size.height) * 0.335

        let glow = SKShapeNode(circleOfRadius: coreRadius + 17)
        glow.strokeColor = UIColor(OrbitTheme.violet).withAlphaComponent(0.15)
        glow.lineWidth = 13
        core.addChild(glow)

        let coreCircle = SKShapeNode(circleOfRadius: coreRadius)
        coreCircle.strokeColor = UIColor(OrbitTheme.violet)
        coreCircle.lineWidth = 6
        coreCircle.fillColor = UIColor(OrbitTheme.surface).withAlphaComponent(0.8)
        core.addChild(coreCircle)
        addChild(core)

        addClosedOuterSegments(radius: outerRadius)
        addChild(outerRing)

        for index in 0..<level.startingArrows {
            arrows.append(-CGFloat.pi / 2 + CGFloat(index + 1) * (2 * .pi / CGFloat(level.startingArrows + 1)))
        }
        redrawAnchoredArrows(radius: coreRadius)
        addLauncher(radius: coreRadius)
    }

    private func addStarfield() {
        for index in 0..<36 {
            let seed = CGFloat((index * 37) % 101) / 100
            let seedY = CGFloat((index * 61) % 101) / 100
            let star = SKShapeNode(circleOfRadius: index.isMultiple(of: 7) ? 1.8 : 0.8)
            star.fillColor = UIColor.white.withAlphaComponent(index.isMultiple(of: 7) ? 0.32 : 0.15)
            star.strokeColor = .clear
            star.position = CGPoint(x: size.width * (seed - 0.5), y: size.height * (seedY - 0.5))
            star.name = "star"
            addChild(star)
        }
    }

    private func addClosedOuterSegments(radius: CGFloat) {
        let sortedGates = level.gates.sorted { normalized($0.angle) < normalized($1.angle) }
        var cursor: CGFloat = 0
        for gate in sortedGates {
            let openingStart = normalized(gate.angle - gate.width / 2)
            let openingEnd = normalized(gate.angle + gate.width / 2)
            if openingStart > cursor { addOuterArc(radius: radius, start: cursor, end: openingStart) }
            addGateMarkers(gate, radius: radius)
            cursor = openingEnd
        }
        if cursor < 2 * .pi { addOuterArc(radius: radius, start: cursor, end: 2 * .pi) }
    }

    private func addOuterArc(radius: CGFloat, start: CGFloat, end: CGFloat) {
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        let segment = SKShapeNode(path: path.cgPath)
        segment.strokeColor = UIColor(OrbitTheme.muted).withAlphaComponent(0.42)
        segment.lineWidth = 11
        segment.lineCap = .round
        outerRing.addChild(segment)
    }

    private func addGateMarkers(_ gate: Gate, radius: CGFloat) {
        for angle in [gate.angle - gate.width / 2, gate.angle + gate.width / 2] {
            let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: angle - 0.04, endAngle: angle + 0.04, clockwise: true)
            let marker = SKShapeNode(path: path.cgPath)
            marker.strokeColor = UIColor(OrbitTheme.lime)
            marker.lineWidth = 5
            marker.glowWidth = 6
            marker.lineCap = .round
            outerRing.addChild(marker)
        }
    }

    private func addLauncher(radius: CGFloat) {
        let launcher = SKShapeNode(circleOfRadius: 8)
        launcher.fillColor = UIColor(OrbitTheme.cyan)
        launcher.strokeColor = .white
        launcher.lineWidth = 2
        launcher.glowWidth = 5
        launcher.position = point(radius: radius * 0.52, angle: launchAngle)
        core.addChild(launcher)
    }

    private func redrawAnchoredArrows(radius: CGFloat) {
        core.childNode(withName: "arrows")?.removeFromParent()
        let container = SKNode()
        container.name = "arrows"
        for angle in arrows {
            let arrow = arrowNode(color: UIColor(OrbitTheme.cyan))
            arrow.position = point(radius: radius, angle: angle)
            arrow.zRotation = angle - .pi / 2
            container.addChild(arrow)
        }
        core.addChild(container)
    }

    private func arrowNode(color: UIColor) -> SKNode {
        let node = SKNode()
        let shaft = SKShapeNode(rectOf: CGSize(width: 4, height: 34), cornerRadius: 2)
        shaft.fillColor = color
        shaft.strokeColor = .clear
        shaft.position.y = 10
        let tip = SKShapeNode(path: trianglePath().cgPath)
        tip.fillColor = color
        tip.strokeColor = .white.withAlphaComponent(0.8)
        tip.lineWidth = 1
        tip.position.y = 30
        node.addChild(shaft)
        node.addChild(tip)
        return node
    }

    private func trianglePath() -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: -8, y: -7))
        path.addLine(to: CGPoint(x: 8, y: -7))
        path.close()
        return path
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        launchArrow()
    }

    private func launchArrow() {
        guard !isFinished, !hasLaunched else { return }
        hasLaunched = true
        SoundEffects.launch(enabled: soundEnabled)
        let radius = min(size.width, size.height) * 0.19
        let outerRadius = min(size.width, size.height) * 0.335
        let projectile = arrowNode(color: UIColor(OrbitTheme.cyan))
        projectile.name = "projectile"
        let flightAngle = launchAngle + core.zRotation
        projectile.zRotation = flightAngle - .pi / 2
        projectile.position = point(radius: 18, angle: flightAngle)
        addChild(projectile)

        let pulse = SKAction.sequence([.scale(to: 1.16, duration: 0.07), .scale(to: 1, duration: 0.1)])
        core.run(pulse)
        let distance = outerRadius + 92
        let target = point(radius: distance, angle: flightAngle)
        projectile.run(.move(to: target, duration: 0.23)) { [weak self, weak projectile] in
            guard let self, let projectile else { return }
            self.resolveFlight(projectile: projectile, innerRadius: radius, flightAngle: flightAngle)
        }
    }

    private func resolveFlight(projectile: SKNode, innerRadius: CGFloat, flightAngle: CGFloat) {
        let localInnerAngle = normalized(flightAngle - core.zRotation)
        let collidesWithArrow = arrows.contains { angularDistance($0, localInnerAngle) < 0.12 }
        let localOuterAngle = normalized(flightAngle - outerRing.zRotation)
        let escapes = level.gates.contains { angularDistance($0.angle, localOuterAngle) < $0.width / 2 }

        if collidesWithArrow || !escapes {
            projectile.removeFromParent()
            fail(at: projectile.position)
        } else {
            escaped += 1
            celebrate(at: projectile.position)
            projectile.removeFromParent()
            gameDelegate?.gameSceneDidUpdate(escaped: escaped, lives: lives)
            if escaped >= level.requiredEscapes { finish(won: true) }
        }
        hasLaunched = false
    }

    private func celebrate(at point: CGPoint) {
        let burst = SKEmitterNode()
        burst.particleTexture = particleTexture(color: UIColor(OrbitTheme.lime))
        burst.particleBirthRate = 320
        burst.numParticlesToEmit = UIAccessibility.isReduceMotionEnabled ? 6 : 18
        burst.particleLifetime = 0.45
        burst.particleSpeed = 170
        burst.particleSpeedRange = 80
        burst.particleScale = 0.22
        burst.particleScaleSpeed = -0.35
        burst.particleAlphaSpeed = -2.2
        burst.position = point
        addChild(burst)
        burst.run(.sequence([.wait(forDuration: 0.6), .removeFromParent()]))
        if hapticsEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        SoundEffects.success(enabled: soundEnabled)
    }

    private func fail(at point: CGPoint) {
        lives -= 1
        let burst = SKEmitterNode()
        burst.particleTexture = particleTexture(color: UIColor(OrbitTheme.coral))
        burst.particleBirthRate = 440
        burst.numParticlesToEmit = UIAccessibility.isReduceMotionEnabled ? 8 : 26
        burst.particleLifetime = 0.38
        burst.particleSpeed = 220
        burst.particleScale = 0.25
        burst.particleScaleSpeed = -0.46
        burst.particleAlphaSpeed = -2.6
        burst.position = point
        addChild(burst)
        burst.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))
        if !UIAccessibility.isReduceMotionEnabled {
            run(.sequence([.moveBy(x: 8, y: 0, duration: 0.04), .moveBy(x: -16, y: 0, duration: 0.07), .moveBy(x: 8, y: 0, duration: 0.04)]))
        }
        if hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.error) }
        SoundEffects.failure(enabled: soundEnabled)
        gameDelegate?.gameSceneDidUpdate(escaped: escaped, lives: lives)
        if lives <= 0 { finish(won: false) }
    }

    private func finish(won: Bool) {
        guard !isFinished else { return }
        isFinished = true
        if won, hapticsEnabled { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        gameDelegate?.gameSceneDidFinish(won: won, elapsed: elapsed, remainingLives: lives)
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isFinished else { return }
        let delta = min(1.0 / 30.0, 1.0 / 60.0)
        elapsed += delta
        core.zRotation += level.innerSpeed * delta
        outerRing.zRotation += level.outerSpeed * delta
    }

    private func point(radius: CGFloat, angle: CGFloat) -> CGPoint {
        CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }

    private func normalized(_ value: CGFloat) -> CGFloat {
        var value = value.truncatingRemainder(dividingBy: 2 * .pi)
        if value < 0 { value += 2 * .pi }
        return value
    }

    private func angularDistance(_ first: CGFloat, _ second: CGFloat) -> CGFloat {
        abs(atan2(sin(first - second), cos(first - second)))
    }

    private func particleTexture(color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let image = renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 8, height: 8))
        }
        return SKTexture(image: image)
    }
}
