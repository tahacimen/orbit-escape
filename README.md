# Orbit Escape iOS

App Store hedefli, portre yönelimli 2D refleks oyunu. Oyuncu dokunarak oku içeriden dışarı fırlatır; dış halkanın dönen açık geçitlerinden kaçırmaya çalışır. İç halkadaki önceki oklar engeldir.

## İçerik

- SwiftUI menüler, bölüm haritası ve ayarlar
- SpriteKit tabanlı oyun sahnesi ve parçacık efektleri
- Özgün 1024 × 1024 App Store simgesi
- 60 seviyelik zorluk verisi
- Yerel ilerleme, yıldızlar, ses/titreşim tercihleri
- VoiceOver etiketleri, 44pt hedefler ve iOS `Hareketi Azalt` tercihi
- `PrivacyInfo.xcprivacy` dosyasında UserDefaults kullanım nedeni ve izleme/veri toplama beyanı

## Mac'te açma ve çalıştırma

Bu klasör Windows'ta hazırlanabilir; ancak iPhone simülatörü, iOS derlemesi ve App Store gönderimi için macOS ile Xcode gerekir.

1. Projeyi Mac'e taşıyın.
2. [XcodeGen](https://github.com/yonaskolb/XcodeGen) kurun (`brew install xcodegen`).
3. Bu klasörde `xcodegen generate` komutunu çalıştırın.
4. `OrbitEscape.xcodeproj` dosyasını Xcode ile açın.
5. `OrbitEscape` şemasından bir iPhone simülatörü veya bağlı cihaz seçip çalıştırın.
6. `Signing & Capabilities` kısmında kendi Apple Developer Team'inizi seçin ve benzersiz bundle kimliği verin.

## App Store'a çıkarma öncesi

- Apple Developer Program üyeliği gerekir.
- Uygulama adı, simge seti, gizlilik bildirimi, yaş derecelendirmesi, ekran görüntüleri ve App Store açıklaması eklenmelidir.
- Gerçek cihazda dokunma, titreşim, erişilebilirlik ve tüm 60 seviye test edilmelidir.
- TestFlight ile beta testi yapıldıktan sonra App Store Connect üzerinden sürüm gönderilir.
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md) metnini kendi alan adınızda herkese açık yayımlayın; bu URL iOS uygulamaları için App Store Connect’te zorunludur.

Tasarım kararları ve bölüm sistemi için [OYUN_TASARIM_DOKUMANI.md](OYUN_TASARIM_DOKUMANI.md) dosyasına bakın.
