import AudioToolbox

enum SoundEffects {
    static func launch(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    static func success(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1025)
    }

    static func failure(enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1053)
    }
}
