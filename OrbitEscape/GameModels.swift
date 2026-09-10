import Foundation
import Observation

struct Gate: Identifiable, Hashable {
    let id = UUID()
    let angle: CGFloat
    let width: CGFloat
}

struct LevelDefinition: Identifiable {
    let id: Int
    let requiredEscapes: Int
    let startingArrows: Int
    let outerSpeed: CGFloat
    let innerSpeed: CGFloat
    let gates: [Gate]
    let lives: Int
    let perfectTime: TimeInterval
}

enum LevelCatalog {
    static func level(_ number: Int) -> LevelDefinition {
        let safeNumber = min(max(number, 1), 60)
        let band = (safeNumber - 1) / 10
        let progress = CGFloat((safeNumber - 1) % 10)
        let gateCount = safeNumber < 21 ? 4 : (safeNumber < 41 ? 5 : 6)
        let gateWidth = max(0.16, 0.54 - CGFloat(band) * 0.060 - progress * 0.017)
        let gates = (0..<gateCount).map { index in
            Gate(angle: -CGFloat.pi / 2 + CGFloat(index) * (2 * .pi / CGFloat(gateCount)) + 0.16, width: gateWidth)
        }

        return LevelDefinition(
            id: safeNumber,
            requiredEscapes: min(14, 3 + safeNumber / 4),
            startingArrows: min(7, max(0, (safeNumber - 4) / 7)),
            outerSpeed: (0.42 + CGFloat(band) * 0.25 + progress * 0.045) * (safeNumber.isMultiple(of: 2) ? 1 : -1),
            innerSpeed: 0.85 * (safeNumber.isMultiple(of: 3) ? -1 : 1),
            gates: gates,
            lives: safeNumber >= 51 ? 1 : (safeNumber >= 26 ? 2 : 3),
            perfectTime: max(10, 25 - Double(band) * 2)
        )
    }
}

@Observable
final class PlayerProgress {
    var highestUnlocked: Int {
        didSet { UserDefaults.standard.set(highestUnlocked, forKey: "highestUnlocked") }
    }
    var stars: [Int: Int] {
        didSet { saveStars() }
    }
    var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") }
    }
    var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled") }
    }

    init() {
        highestUnlocked = max(1, UserDefaults.standard.integer(forKey: "highestUnlocked"))
        soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        hapticsEnabled = UserDefaults.standard.object(forKey: "hapticsEnabled") as? Bool ?? true
        let stored = UserDefaults.standard.dictionary(forKey: "levelStars") as? [String: Int] ?? [:]
        stars = Dictionary(uniqueKeysWithValues: stored.compactMap { key, value in
            Int(key).map { ($0, value) }
        })
    }

    func finish(level: Int, stars earnedStars: Int) {
        highestUnlocked = min(60, max(highestUnlocked, level + 1))
        stars[level] = max(stars[level, default: 0], earnedStars)
    }

    private func saveStars() {
        let values = Dictionary(uniqueKeysWithValues: stars.map { (String($0.key), $0.value) })
        UserDefaults.standard.set(values, forKey: "levelStars")
    }
}
