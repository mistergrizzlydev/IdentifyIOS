# IdentifyIOS

[![CI Status](https://img.shields.io/travis/emir@beytekin.net/IdentifyIOS.svg?style=flat)](https://travis-ci.org/emir@beytekin.net/IdentifyIOS)
[![Version](https://img.shields.io/cocoapods/v/IdentifyIOS.svg?style=flat)](https://cocoapods.org/pods/IdentifyIOS)
[![License](https://img.shields.io/cocoapods/l/IdentifyIOS.svg?style=flat)](https://cocoapods.org/pods/IdentifyIOS)
[![Platform](https://img.shields.io/cocoapods/p/IdentifyIOS.svg?style=flat)](https://cocoapods.org/pods/IdentifyIOS)

## Gereklilikler
iOS 12.1 sürümü ve üzerinde çalışır.
                    
** Lütfen plist ve entitlements dosyanızı kontrol etmeyi unutmayın. Aşağıda gösterilen tüm özellikler Example/IdentifyIOS/ViewController.swift dosyasında mevcuttur. **

## Kurulum
                    
Aşağıdaki kodu kendi .podfile dosyanıza ekleyin:

```ruby
pod 'IdentifyIOS'
pod 'QKMRZParser'
pod 'CHIOTPField/Two'
pod 'IQKeyboardManagerSwift'
pod 'SwiftSignatureView'
```

## Identify SDK
                    
```ruby
Pod install ile gerekli kütüphaneleri projenize yükleyin
Proje içinde bulunan "Views" klasörünü kendi tasarımınıza göre kişiselleştirin
SDKCallWaitScreenController router ekranıdır, modüllerin yönetimi ve çağrı bekleme ekranı buradadır. Bu ekranın ismini değiştirmeyin, SDK bu ekrana göre çalışmaktadır.
Kişiselleştirme yaparken delegate methodlara mutlaka dikkat edin
Var olan tasarımı ister "Design.swift" dosyasından renk ve fontlarını, isterseniz xib dosyasını kendi tasarımınıza göre güncelleyebilirsiniz.(ViewController.swift dosyasında kullanılabilen modül örnekleri ve tasarım kişiselleştirilmesi mevcuttur)
Uygulamanın sağlıklı çalışması için info.plist dosyanızda "mikrafon", "kamera", "konuşma izni" ve "NFC Tag Reader Session" ayarlarının açık olduğundan emin olun. Örnek uygulamada info.plist dosyasına bakabilirsiniz.
NFC özelliğinin düzgün çalışması için "Signing & Capabilities" ayarlarında "Near Field Communication Tag Reading" özelliğinin eklenmiş olmasına dikkat edin ve .entitlements dosyanızı kontrol edin.
```

## Kişiselleştirme Seçenekleri
                    
NFC okutulamaması durumunda max error count belirleyebilirsiniz. Belirlediğiniz rakama ulaşınca nfc modülü otomatik olarak iptal edilir ve sıradaki modüle geçilir. Default olarak 3 gelmektedir.
```ruby
GlobalConstants.nfcErrorMaxCount = 3
```
İstediğiniz modülü, istediğiniz sırada sunabilirsiniz
```ruby
manager.addModules(module: [.ncf, .livenessDetection, .selfie])
```
Network timeout sürenizi kişiselleştirebilirsiniz
```ruby
manager.netw.timeoutIntervalForRequest = 35
manager.netw.timeoutIntervalForResource = 15
```
Network request adreslerinizi değiştirebilirsiniz
```ruby
manager.baseAPIUrl = "https://api.identifytr.com/"
manager.webSocketUrl = "wss://ws.identifytr.com:8888/"
manager.stunServers = ["stun:stun.l.google.com:19302", "turn:3.64.99.127:3478"]
manager.stunUsername = "test"
manager.stunPassword = "test"
```
## Tüm Aşamaları Atla, Tesimcilye Bağlan
                    
SDKBaseViewController dosyasına eklenen "addSkipModulesButton" fonksiyonunu istediğiniz ekrandan çağırabilirsiniz. Böylece tüm aşamaları iptal edip müşteri temsilcisi bekleme ekranına yönlendirmiş olursunuz.

## Mevcut Modüller
                    
Modül ismi  | İşleyişi
------------- | -------------
nfc           | MRZ + NFC Modülünü tektikler
livenessDetection  | Karşıdaki kişinin telefonuna bağlı olarak gülümseme kontrolü ekler. True Depth teknolojisine sahip olmayan cihazlarda fotoğraf çekilir, fotoğraf üzerinde gülümseyen yüz aranır; yeni cihazlarda ise anlık olarak kamera açılır ve kişinin gülümsemesi istenir.
selfie        | Kişinin anlık fotoğrafı çekilir, galeriden seçilmesine izin verilmez.
videoRecord   | Canlılık testi için kişiden 5 saniyelik video çekmesi istenir, henüz yapım aşamasındadır.
idCard        | Kişinin kimliğinin ön ve arka fotoğraflarını çekmesi istenir, galeriden seçime izin verilmez.
signature     | Canlılık testi için kişinin imzası alınır.
speech        | Canlılık testi için kişinin ekranda gördüğü metni okuması istenir.


## Author
                    
emir@beytekin.net

## License
                    
IdentifyIOS is available under the MIT license. See the LICENSE file for more info.
