import SwiftUI
import SpriteKit

struct ContentView: View {
    enum Destination { case home, levels, settings, game(Int) }
    @State private var destination: Destination = .home
    let progress: PlayerProgress

    var body: some View {
        ZStack {
            OrbitTheme.deep.ignoresSafeArea()
            switch destination {
            case .home:
                HomeView(progress: progress, play: { destination = .game(progress.highestUnlocked) }, levels: { destination = .levels }, settings: { destination = .settings })
            case .levels:
                LevelMapView(progress: progress, select: { destination = .game($0) }, close: { destination = .home })
            case .settings:
                SettingsView(progress: progress, close: { destination = .home })
            case .game(let level):
                GameView(level: level, progress: progress, advance: { destination = .game($0) }, exit: { destination = .levels })
                    .id(level)
            }
        }
    }
}

private struct HomeView: View {
    let progress: PlayerProgress
    let play: () -> Void
    let levels: () -> Void
    let settings: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 10) {
                Text("ORBIT")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(OrbitTheme.cyan)
                Text("ESCAPE")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(OrbitTheme.lime)
                Text("İÇTEN DIŞA KAÇ")
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(OrbitTheme.muted)
            }
            OrbitPreview().frame(width: 260, height: 260)
            VStack(spacing: 12) {
                PrimaryButton(title: "OYNA", action: play)
                HStack(spacing: 12) {
                    SecondaryButton(title: "BÖLÜMLER", systemImage: "circle.grid.3x3.fill", action: levels)
                    SecondaryButton(title: "AYARLAR", systemImage: "gearshape.fill", action: settings)
                }
            }
            Text("En son ulaşılan bölüm: \(progress.highestUnlocked)")
                .font(.footnote)
                .foregroundStyle(OrbitTheme.muted)
            Spacer().frame(height: 24)
        }
        .padding(24)
    }
}

private struct OrbitPreview: View {
    @State private var spinning = false
    var body: some View {
        ZStack {
            Circle().stroke(OrbitTheme.violet.opacity(0.25), lineWidth: 20).frame(width: 130, height: 130)
            Circle().stroke(OrbitTheme.violet, lineWidth: 5).frame(width: 130, height: 130)
            Circle().trim(from: 0.12, to: 0.30).stroke(OrbitTheme.lime, style: StrokeStyle(lineWidth: 12, lineCap: .round)).frame(width: 220, height: 220).rotationEffect(.degrees(spinning ? 360 : 0))
            Circle().stroke(OrbitTheme.muted.opacity(0.35), lineWidth: 9).frame(width: 220, height: 220)
            Capsule().fill(OrbitTheme.cyan).frame(width: 5, height: 46).offset(y: -74)
        }
        .onAppear { withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) { spinning = true } }
        .accessibilityHidden(true)
    }
}

private struct LevelMapView: View {
    let progress: PlayerProgress
    let select: (Int) -> Void
    let close: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Header(title: "BÖLÜMLER", close: close)
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 16) {
                    ForEach(1...60, id: \.self) { level in
                        Button { if level <= progress.highestUnlocked { select(level) } } label: {
                            VStack(spacing: 4) {
                                Text("\(level)").font(.headline.monospacedDigit())
                                Text(String(repeating: "★", count: progress.stars[level, default: 0])).font(.caption2).foregroundStyle(OrbitTheme.lime)
                            }
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(level <= progress.highestUnlocked ? OrbitTheme.surface : Color.white.opacity(0.06), in: Circle())
                            .overlay(Circle().stroke(level <= progress.highestUnlocked ? OrbitTheme.violet.opacity(0.7) : .clear, lineWidth: 1))
                            .foregroundStyle(level <= progress.highestUnlocked ? Color.white : OrbitTheme.muted.opacity(0.5))
                        }
                        .disabled(level > progress.highestUnlocked)
                        .accessibilityLabel(level <= progress.highestUnlocked ? "Bölüm \(level)" : "Bölüm \(level), kilitli")
                    }
                }
                .padding(.vertical, 8)
            }
        }.padding(20)
    }
}

private struct SettingsView: View {
    let progress: PlayerProgress
    let close: () -> Void
    @State private var showPrivacy = false
    var body: some View {
        VStack(spacing: 16) {
            Header(title: "AYARLAR", close: close)
            VStack(spacing: 0) {
                Toggle("Ses efektleri", isOn: Bindable(progress).soundEnabled)
                Divider().overlay(Color.white.opacity(0.12))
                Toggle("Titreşim", isOn: Bindable(progress).hapticsEnabled)
            }
            .tint(OrbitTheme.cyan)
            .padding()
            .background(OrbitTheme.surface, in: RoundedRectangle(cornerRadius: 20))
            Text("Hareketi Azalt ayarı, iPhone Erişilebilirlik tercihinize otomatik olarak uyulur.")
                .font(.footnote).foregroundStyle(OrbitTheme.muted).multilineTextAlignment(.center)
            Button("GİZLİLİK VE VERİLER") { showPrivacy = true }
                .font(.footnote.weight(.bold))
                .foregroundStyle(OrbitTheme.cyan)
                .frame(minHeight: 44)
            Spacer()
        }.padding(20)
        .sheet(isPresented: $showPrivacy) { PrivacyNoticeView() }
    }
}

private struct PrivacyNoticeView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Aroro kişisel veri, konum, reklam kimliği veya analiz verisi toplamaz.")
                    Text("Bölüm ilerlemesi, yıldızlar ve ses/titreşim tercihleri yalnızca bu cihazda saklanır. Bu bilgiler uygulama dışına gönderilmez ve geliştirici tarafından erişilemez.")
                    Text("Uygulama reklam, üçüncü taraf analiz SDK’sı veya çevrimiçi satın alma içermez.")
                }
                .font(.body).foregroundStyle(.primary).padding(24)
            }
            .navigationTitle("Gizlilik ve Veriler")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Bitti", action: { dismiss() }) } }
        }
        .presentationDetents([.medium])
    }
}

private struct GameView: View, OrbitGameSceneDelegate {
    let level: Int
    let progress: PlayerProgress
    let advance: (Int) -> Void
    let exit: () -> Void
    @State private var escaped = 0
    @State private var lives = 3
    @State private var result: ResultState?
    @State private var scene: OrbitGameScene?

    struct ResultState: Identifiable { let id = UUID(); let won: Bool; let elapsed: TimeInterval; let lives: Int }

    var body: some View {
        let definition = LevelCatalog.level(level)
        ZStack {
            SpriteView(scene: makeScene(definition), options: [.allowsTransparency])
                .ignoresSafeArea()
                .contentShape(Rectangle())
            VStack {
                HStack {
                    Button(action: exit) { Image(systemName: "chevron.left").font(.title3.bold()).frame(width: 44, height: 44) }
                        .accessibilityLabel("Bölümlere dön")
                    Spacer()
                    VStack(spacing: 2) {
                        Text("BÖLÜM \(level)").font(.caption.weight(.bold)).tracking(1.2)
                        Text("KAÇIŞ \(escaped) / \(definition.requiredEscapes)").font(.headline.monospacedDigit())
                    }
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .foregroundStyle(.white).padding(.horizontal, 18).padding(.top, 6)
                Spacer()
                HStack(spacing: 8) {
                    Text("HATA HAKKI").font(.caption.weight(.bold)).foregroundStyle(OrbitTheme.muted)
                    ForEach(0..<definition.lives, id: \.self) { index in Circle().fill(index < lives ? OrbitTheme.coral : Color.white.opacity(0.14)).frame(width: 12, height: 12) }
                }.padding(.bottom, 26)
                Text("Ekrana dokun ve ateşle").font(.footnote.weight(.semibold)).foregroundStyle(OrbitTheme.muted).padding(.bottom, 22)
            }
            if let result { ResultCard(result: result, level: level, progress: progress, retry: restart, next: nextLevel, exit: exit) }
        }
        .onAppear { lives = definition.lives }
    }

    private func makeScene(_ definition: LevelDefinition) -> OrbitGameScene {
        if let scene { return scene }
        let newScene = OrbitGameScene(size: CGSize(width: 390, height: 720), level: definition, hapticsEnabled: progress.hapticsEnabled, soundEnabled: progress.soundEnabled)
        newScene.gameDelegate = self
        DispatchQueue.main.async { scene = newScene }
        return newScene
    }

    private func restart() { scene = nil; escaped = 0; lives = LevelCatalog.level(level).lives; result = nil }
    private func nextLevel() { level < 60 ? advance(level + 1) : exit() }
    func gameSceneDidUpdate(escaped: Int, lives: Int) { DispatchQueue.main.async { self.escaped = escaped; self.lives = lives } }
    func gameSceneDidFinish(won: Bool, elapsed: TimeInterval, remainingLives: Int) { DispatchQueue.main.async { result = ResultState(won: won, elapsed: elapsed, lives: remainingLives); if won { let stars = remainingLives == LevelCatalog.level(level).lives ? (elapsed <= LevelCatalog.level(level).perfectTime ? 3 : 2) : 1; progress.finish(level: level, stars: stars) } } }
}

private struct ResultCard: View {
    let result: GameView.ResultState; let level: Int; let progress: PlayerProgress; let retry: () -> Void; let next: () -> Void; let exit: () -> Void
    var body: some View {
        Color.black.opacity(0.58).ignoresSafeArea().overlay {
            VStack(spacing: 18) {
                Image(systemName: result.won ? "checkmark.seal.fill" : "xmark.octagon.fill").font(.system(size: 52)).foregroundStyle(result.won ? OrbitTheme.lime : OrbitTheme.coral)
                Text(result.won ? "YÖRÜNGE TAMAMLANDI" : "YÖRÜNGE KIRILDI").font(.title3.bold()).multilineTextAlignment(.center)
                Text(result.won ? "Bölüm \(level) açıldı." : "Ok, iç halkadaki oka veya kapalı bölgeye çarptı.").font(.subheadline).foregroundStyle(OrbitTheme.muted).multilineTextAlignment(.center)
                if result.won { Text("\(progress.stars[level, default: 1]) ★").font(.title.bold()).foregroundStyle(OrbitTheme.lime) }
                PrimaryButton(title: result.won ? (level < 60 ? "SONRAKİ BÖLÜM" : "BÖLÜMLERE DÖN") : "TEKRAR DENE", action: result.won ? next : retry)
                Button("BÖLÜMLERE DÖN", action: exit).font(.footnote.bold()).foregroundStyle(OrbitTheme.muted).frame(minHeight: 44)
            }
            .padding(28).background(OrbitTheme.surface, in: RoundedRectangle(cornerRadius: 28)).padding(28)
        }
    }
}

private struct Header: View { let title: String; let close: () -> Void; var body: some View { HStack { Button(action: close) { Image(systemName: "chevron.left").frame(width: 44, height: 44) }.accessibilityLabel("Geri"); Spacer(); Text(title).font(.headline.weight(.heavy)); Spacer(); Color.clear.frame(width: 44, height: 44) }.foregroundStyle(.white) } }
private struct PrimaryButton: View { let title: String; let action: () -> Void; var body: some View { Button(action: action) { Text(title).font(.headline.weight(.black)).frame(maxWidth: .infinity).frame(minHeight: 56).foregroundStyle(OrbitTheme.deep).background(OrbitTheme.lime, in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain).accessibilityHint("Oyuna devam eder") } }
private struct SecondaryButton: View { let title: String; let systemImage: String; let action: () -> Void; var body: some View { Button(action: action) { Label(title, systemImage: systemImage).font(.caption.weight(.bold)).frame(maxWidth: .infinity).frame(minHeight: 52).background(OrbitTheme.surface, in: RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(OrbitTheme.violet.opacity(0.5), lineWidth: 1)) }.foregroundStyle(.white).buttonStyle(.plain) } }

#Preview { ContentView(progress: PlayerProgress()) }
