# Orbit Escape — Oyun Tasarım Dokümanı

> Sürüm: 0.1 — konsept ve ilk üretim planı  
> Platform hedefi: iPhone/iPad için yerel iOS uygulaması; App Store yayını

## 1. Kısa fikir

**Orbit Escape**, klasik “içe ok saplama” fikrini tersine çeviren hızlı bir refleks bulmacasıdır. Oyuncu ekrana her bastığında iç çemberdeki fırlatıcı bir enerji oku ateşler. Ok, dönen dış halkadaki **açık kapılardan** geçip dışarı kaçmalıdır. İç halkadaki mevcut oklar hareketli engellerdir; yeni ok onlara çarparsa bölüm biter.

Her bölüm, ritim yakalama, doğru anda ateşleme ve giderek karmaşıklaşan iki halka davranışını birleştirir. Kısa turlar, güçlü görsel geri bildirim ve net bir “bir kez daha deneyeyim” döngüsü hedeflenir.

Bu oyun AA markasını veya onun görsellerini kullanmaz; yalnızca aynı türün tanıdık tek-dokunuşlu erişilebilirliğinden esinlenen, özgün bir ters yönlü mekaniğe sahiptir.

## 2. Oyuncu deneyimi hedefi

- İlk 10 saniyede anlaşılır: “Dokun, oku boşluktan kaçır.”
- Bir bölüm 10–35 saniye sürer; başarısızlık anında yeniden deneme mümkün olur.
- Başarı yalnızca sayı değil, **tatmin edici ses, ışık, titreşim ve yavaş çekim** ile hissettirilir.
- Görünüm canlı ama okunaklıdır: yoğun efekt oyun bilgisini gizlememelidir.
- Hesap, kullanıcı adı ve çevrimiçi bağlantı gerekmez; ilerleme cihazda saklanır.

## 3. Ana oynanış

### Oyun alanı

Ekranın merkezinde aynı ekseni paylaşan iki halka bulunur:

| Öğe | Görev | Davranış |
| --- | --- | --- |
| İç halka — `Çekirdek` | Fırlatıcı ve sıkışan okların yüzeyi | Sabit ya da bölüm kuralına göre yavaş döner. Oyuncu okları buradan dışarı fırlatır. |
| Dış halka — `Geçit` | Kaçış hedefi | Üzerinde açık geçitler ve kapalı zırhlı parçalar vardır; çoğunlukla döner. |
| Enerji oku | Oyuncunun atışı | Merkezden belirlenmiş radyal hatta fırlar, geçitten çıkarsa puan alır. |
| İçteki oklar | Risk / zamanlama bulmacası | İlk halka üzerinde durur ve halka ile beraber döner; yeni okun rotasını kapatabilir. |

### Bir dokunuşun sonucu

1. Oyuncu ekrana veya büyük `ATEŞ` alanına dokunur.
2. Fırlatıcı 80 ms parlaklık ve kısa geri tepme verir; ok dışarı doğru hızlanır.
3. Ok önce iç halka sınırını geçer. Rota üzerinde mevcut bir oka değerse anında hata oluşur.
4. Ok dış halkaya ulaşır:
   - **Açık geçide** denk gelirse halkayı aşar, iz bırakarak ekrandan çıkar ve hedef sayacı azalır.
   - **Kapalı bölüme** denk gelirse parçalanır; bir can kaybolur veya bölüm biter.
5. Gerekli sayıda ok başarıyla kaçarsa bölüm tamamlanır.

### Başarı ve kaybetme

- Başarı şartı: Bölümde istenen sayıda oku, tanımlanan hata sınırını aşmadan kaçırmak.
- Standart mod: 3 hata hakkı. İlk 15 eğitim bölümünde 3 hak; sonrasında 2, ustalık bölümlerinde 1 hak.
- İsteğe bağlı `Mükemmel` rozeti: hiç hata yapmadan ve hedef sürenin altında bitirmek.
- Kaybedince: zaman 0.15 saniye durur, kamera çok hafif sarsılır, çarpışma bölgesinde kontrollü parçacık patlaması oluşur; ardından tek dokunuşla tekrar dene.

## 4. Bölüm tasarımı ve zorluk eğrisi

Başlangıç sürümü 60 bölümle çıkar; seviye verileri koddan bağımsız JSON/ScriptableObject benzeri tanımlarda tutulur. Böylece yeni paketler kolay eklenir.

| Bölüm aralığı | Yeni fikir | Örnek yapı |
| --- | --- | --- |
| 1–5: Uyanış | Yavaş dönen halkalar, dört geniş geçit | Oyuncu yönü ve atış ritmini öğrenir. |
| 6–12: Yörünge | Dönüş hızı artar, geçitler daralır | Geçit hedef çizgiye gelince atış. |
| 13–20: Sıkışma | İç halkada daha çok ok, dar geçit | İç engel ile dış geçidi aynı anda okuma. |
| 21–30: Ters Akım | Halkalar zıt yönlerde döner | Basit tahmin yerine ritim gerekir. |
| 31–40: Nabız | Dönüş hızlanır/yavaşlar, kısa duraklar | Önceden görünen ritim göstergesiyle adil zorluk. |
| 41–50: Kırık Geçit | Birden çok geçit, bazıları kapanıp açılır | Öncelik ve kısa karar anları. |
| 51–60: Usta Yörüngeler | Kombine kurallar ve tek hata hakkı | Görsel gürültü değil, hassas zamanlama ile zorlaşır. |

### Bölüm parametreleri

Her seviye aşağıdaki değerlerle kurulabilir:

- `requiredEscapes`: 3–14
- `outerRotation`: hız, yön, başlangıç açısı
- `innerRotation`: hız, yön, başlangıç açısı
- `gates`: geçit açısı, genişliği, hareket eğrisi, açılıp-kapanma zamanlaması
- `launchSpeed`: okun başlangıç/son hızı
- `lives`: 1–3
- `hazards`: kilitli segment, nabız, sahte ışık, yön değiştirme
- `perfectTime`: opsiyonel kusursuz bitiriş süresi

Zorluk adil olmalı: hız değişimi veya geçit kapanması başlamadan en az 350 ms önce renk/çizgi sinyali verilmelidir. Rastgelelik kullanılacaksa çözümsüz kombinasyon üretmemelidir.

## 5. İlerleme, ödül ve tekrar oynanabilirlik

Ana akış: **Ana ekran → bölüm haritası → bölüm → sonuç → sonraki bölüm**.

- Bölüm tamamlama ile sonraki bölüm açılır.
- Her bölüm 0–3 yıldız verir: tamamlama, hatasız bitirme, hedef sürenin altı.
- Her 10 bölümde yeni bir görsel “bölge” açılır: renk paleti, arka plan dokusu ve yeni geçit davranışı değişir.
- Günlük görev, hesap gerektirmeden cihaz tarihine göre üretilir: ör. “5 bölümü hatasız tamamla.” Bu özellik ilk sürümden sonra eklenebilir.
- Reklam, enerji sistemi, zorunlu ödeme veya giriş ekranı bu tasarımın parçası değildir.

## 6. Görsel yön ve tasarım sistemi

### Sanat yönü: `Neon orbital arcade`

Koyu uzay zemini üzerinde cam gibi yarı saydam halkalar, canlı enerji akışları ve temiz geometrik şekiller. Arayüz, oyun alanını gölgelemeyecek kadar sade; oyun anı ise parlak ve kinetik olmalı.

### Renk tokenları

| Token | Renk | Kullanım |
| --- | --- | --- |
| `--bg-deep` | `#080B1F` | Ana arka plan |
| `--surface` | `#131A3A` | Menü/kart yüzeyi |
| `--ink-primary` | `#F6F7FF` | Ana metin |
| `--ink-muted` | `#B6BDE6` | İkincil metin |
| `--energy-cyan` | `#3DEBFF` | Oyuncu oku, aktif geçit |
| `--energy-violet` | `#8B5CFF` | İç halka, ikincil parıltı |
| `--success-lime` | `#A7F84B` | Kaçış, tamamlandı |
| `--warning-amber` | `#FFC857` | Yaklaşan hız değişimi |
| `--danger-coral` | `#FF5D7A` | Çarpışma, hata |

Renk asla tek başına durum bildirmez: açık geçitte renk yanında kesik halka formu, tehlikeli kapalı segmentte dolu/çizgili form, hız değişiminde yön oku kullanılır. Metin kontrastı koyu zeminde en az 4.5:1 hedeflenir.

### Tipografi ve ikonlar

- Başlık: geometrik, kalın bir sans-serif (ör. **Space Grotesk** veya **Sora**).
- Metin ve sayaçlar: okunaklı sans-serif (ör. **Inter**).
- Sayılar için sabit genişlikli (tabular) karakterler kullanılır; sayaç zıplamaz.
- Sistem ikonlarında emoji yerine tek çizgi kalınlığında SVG ikon seti kullanılır.

### Ekran düzeni

```text
┌────────────────────────────────┐
│  ←   BÖLÜM 18         ⏸         │
│       KAÇIŞ  4 / 7              │
│                                │
│           ╭─────────╮           │
│        ╭──│  geçit  │──╮        │
│        │  │  ○ iç   │  │        │
│        ╰──│ halka   │──╯        │
│           ╰─────────╯           │
│                                │
│      ●  ●  ○   hata hakkı       │
│                                │
│       Ekrana dokun ve ateşle    │
└────────────────────────────────┘
```

Oyun alanı ekran yüksekliğinin yaklaşık %58–66’sını alır. Tüm etkileşim alanları en az 44 × 44 pt olmalıdır; asıl atış bölgesi ekranın büyük kısmını kapsar.

## 7. Efekt, ses ve dokunsal geri bildirim

Efektler sonuç ile birebir bağlı olmalıdır; sadece ekranı süsleyen ve zamanlamayı saklayan efektler kullanılmaz.

| Olay | Görsel | Ses | Titreşim |
| --- | --- | --- | --- |
| Dokunma | Fırlatıcıda 1.06x nabız, kısa cyan flaş | Kısa, tok “tick” | Çok hafif |
| Ok uçuşu | 120–180 ms kalan iz, hafif yönlü parçacık | Yükselen “whoosh” | Yok |
| Geçitten kaçış | Lime halka dalgası, 12–20 parçacık, puan etiketi | Parlak “chime” | Hafif |
| Seri kaçış | Arka planda katmanlı yıldız kayması | Perde yükselten katman | Orta |
| Çarpışma | 150 ms ekran sarsıntısı, coral kırılma, 0.15 sn zaman durması | Kısa düşük ton | Orta/sert |
| Bölüm sonu | Halkalar açılır, parçacıklar dışarı akar, sonuç kartı alttan gelir | 2 notalı bitiş | Kutlama deseni |

Varsayılan mikro animasyonlar 150–300 ms aralığında olur. `Ayarlar > Hareketi azalt` açık olduğunda ekran sarsıntısı, parçacık sayısı ve geçiş ölçeklemesi azaltılır; oyun kuralları değişmez. Ses ve titreşim ayrı ayrı kapatılabilir.

## 8. Ekranlar

### Ana ekran

- Arka planda etkileşimsiz, yavaş hareket eden iki halka önizlemesi.
- Birincil CTA: `OYNA`.
- Alt kısımda: `Bölümler`, `Ayarlar` ve son ulaşılan bölüm rozeti.
- Üyelik, sosyal giriş, izin istemi veya karmaşık mağaza bölümü yoktur.

### Bölüm haritası

- 10 bölümlük renk bölgeleri içinde dairesel düğümler.
- Kilitli düğmeler erişilemez görünür; açılma koşulu net yazılır.
- Tamamlananlarda yıldızlar ve kusursuz rozet gösterilir.

### Oyun içi HUD

- Üstte bölüm adı, ilerleme ve duraklatma.
- Altta yalnızca hata hakları ve ilk 3 bölümde kısa ipucu.
- Hata/başarı bilgisi merkezden uzak, hedefi kapatmayacak şekilde görünür.

### Sonuç kartı

- Başarı: yıldızlar sırayla dolar; `Sonraki Bölüm` en görünür eylemdir.
- Başarısızlık: neden kısa ve somut söylenir: “Ok, iç halkadaki oka çarptı.”
- `Tekrar Dene` birincil, `Bölümlere Dön` ikincil eylemdir.

## 9. Teknik yaklaşım

İlk öneri: **SwiftUI + SpriteKit (iOS 17+)**. SwiftUI; ana ekran, bölüm haritası, ayarlar ve sonuç kartını taşır. SpriteKit ise 60 FPS oyun döngüsü, iki dönen halka, açısal çarpışma, parçacıklar ve dokunuşları işler. Bu seçim doğrudan iPhone/iPad'e yerel uygulama olarak çıkar ve App Store yayınına uygundur. Oyun fizik tabanlı görünse de, asıl ihtiyaç deterministik açısal çarpışma olduğundan ağır fizik motoru gerekli değildir.

- Çarpışma: okun radyal hattı ile içteki okların açı/yarıçap aralığı; dış halkada geçit açı aralık kontrolü.
- Zamanlama: sabit timestep; bölüm davranışları seed ile tekrar üretilebilir.
- Performans: ok ve parçacıklar nesne havuzu (object pooling) ile yeniden kullanılır; parçacık sayısı cihaz performansına göre düşürülür.
- Kayıt: `UserDefaults` ile açılan bölüm, yıldız ve ayarlar tutulur; kullanıcı hesabı gerekmez.
- Erişilebilirlik: ekran okuyucu etiketli butonlar, görünür odak halkası, klavyede boşluk/Enter ile ateşleme, azaltılmış hareket desteği.

SpriteKit, 2D oyunlar için Metal destekli çizim, şekiller ve parçacıklar sunduğu için oyun motoru olarak seçildi. Apple, bir `SKScene`in `SKView` içinde sunulabildiğini; SpriteKit'in 2D, yüksek performanslı oyunlar için tasarlandığını belgeliyor. İlerleme de SwiftUI `AppStorage`/`UserDefaults` ailesindeki yerel depolama ile cihazda saklanır. [SpriteKit](https://developer.apple.com/documentation/spritekit), [SKScene](https://developer.apple.com/documentation/spritekit/skscene), [AppStorage](https://developer.apple.com/documentation/SwiftUI/AppStorage).

## 10. İlk üretim kapsamı (MVP)

1. Tek oyun sahnesi: iki halka, döngü, ok fırlatma, geçit kontrolü ve çarpışma.
2. 15 elle tasarlanmış eğitim/orta zorluk bölümü.
3. Ana ekran, bölüm haritası, duraklatma ve sonuç kartı.
4. Yukarıdaki temel palet, ses/titreşim ayarları ve azaltılmış hareket modu.
5. Yerel ilerleme kaydı ve mobil tarayıcı testleri.

İlk sürümün dışında: günlük görevler, kozmetik tema açılımları, liderlik tablosu, reklam/ödeme, bulut kayıt ve sosyal özellikler.

## 11. Başarı ölçütleri

- Yeni oyuncu ilk bölümü yardım almadan tamamlayabilmeli.
- İlk 5 bölümde haksız görünmüş çarpışma olmamalı; hitboxlar görsel şekillerden taşmamalı.
- Orta sınıf bir telefonda hedef 60 FPS; yoğun efektlerde 45 FPS altına sürekli düşmemeli.
- Tekrar dene eylemi 1 saniye içinde yeni turu başlatmalı.
- Oyuncu hata nedenini ek açıklama olmadan anlayabilmeli.

## 12. Netleştirilmesi gereken kararlar

Tasarım, aşağıdaki varsayımlarla hazırlandı: portre modunda, neon uzay temalı ve çevrimiçi olmayan bir mobil web oyunu. Üretime geçmeden önce şu tercihleri senden almak iyi olur:

1. Oyunun adı **Orbit Escape** kalsın mı, yoksa Türkçe bir isim mi istersin? (Örn. `Yörünge Kaçışı`.)
2. Hedef sadece tarayıcı/PWA mı, yoksa Android/iOS mağazalarına da çıkması gerekiyor mu?
3. Oyunun havası neon-uzay mı olsun, yoksa daha sevimli, sade veya başka bir temaya mı geçelim?
4. Hata sistemi 3 canlı mı kalsın, yoksa tek çarpışmada bölüm bittiği daha sert arcade biçimini mi tercih edersin?
