# Süt Hesaplayıcı 🥛

Modern ve kullanıcı dostu süt hesaplama ve takip uygulaması. Flutter ile geliştirilmiş, kalıcı veri depolama özellikli mobil uygulama.

## 📱 Özellikler

### Ana Sayfa
- **Süt miktarı girişi** - Manuel veya hızlı seçim butonları ile
- **Hızlı seçim butonları** - 1L, 2L, 2.5L, 3L, 4L, 5L
- **Anlık fiyat hesaplama** - Girilen miktara göre otomatik hesaplama
- **Kaydetme** - Süt kayıtlarını tarihle birlikte saklama

### Kayıtlar
- **Süt kayıtları** - Miktar, toplam fiyat ve tarih bilgisi
- **Ödeme kayıtları** - Yapılan ödemeler ve tarihleri
- **Kronolojik sıralama** - En yeni kayıtlar en üstte
- **Görsel ayırım** - Farklı renkler ve simgelerle kolay ayırt

### Hesaplama
- **Son hafta toplamı** - Son 7 günün süt tutarı
- **Son ay toplamı** - Son 30 günün süt tutarı
- **Bekleyen ödeme takibi** - Aylık toplam - yapılan ödemeler
- **Ödeme ekleme** - Kolayca ödeme kaydı oluşturma

### Ayarlar
- **Litre fiyatı belirleme** - 1 litre sütün TL cinsinden fiyatı
- **Kalıcı ayarlar** - Uygulama kapatılsa da korunur

## 🛠️ Teknik Özellikler

- **Flutter** - Cross-platform mobil uygulama
- **Material Design 3** - Modern ve tutarlı arayüz
- **shared_preferences** - Kalıcı veri depolama
- **Responsive tasarım** - Farklı ekran boyutlarına uyum
- **Async/await** - Performanslı veri işlemleri

## 📋 Gereksinimler

- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Git

## 🚀 Kurulum

1. **Repository'yi klonlayın**
   ```bash
   git clone https://github.com/Kenfrozz/suthesaplayici.git
   cd suthesaplayici
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın**
   ```bash
   flutter run
   ```

## 📦 Bağımlılıklar

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
```

## 📱 Desteklenen Platformlar

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🎯 Kullanım Senaryoları

- **Çiftçiler** - Süt üretimi ve satış takibi
- **Süt satıcıları** - Günlük satış kayıtları
- **Küçük işletmeler** - Süt tedarik hesaplamaları
- **Kişisel kullanım** - Ev tüketimi takibi

## 📊 Veri Saklama

Uygulama tüm verileri cihazda güvenli şekilde saklar:
- Süt kayıtları (miktar, fiyat, tarih)
- Ödeme kayıtları (miktar, tarih)
- Kullanıcı ayarları (litre fiyatı)

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

**Kenfrozz**
- GitHub: [@Kenfrozz](https://github.com/Kenfrozz)

---

🤖 *Bu uygulama [Claude Code](https://claude.ai/code) ile geliştirilmiştir.*