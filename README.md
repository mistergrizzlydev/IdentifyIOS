# IdentifyIOS

[![CI Status](https://img.shields.io/travis/emir@beytekin.net/IdentifyIOS.svg?style=flat)](https://travis-ci.org/emir@beytekin.net/IdentifyIOS)
[![Version](https://img.shields.io/cocoapods/v/IdentifyIOS.svg?style=flat)](https://cocoapods.org/pods/IdentifyIOS)
[![License](https://img.shields.io/cocoapods/l/IdentifyIOS.svg?style=flat)](https://cocoapods.org/pods/IdentifyIOS)
[![Platform](https://img.shields.io/cocoapods/p/IdentifyIOS.svg?style=flat)](https://cocoapods.org/pods/IdentifyIOS)

## What is new in 2.0.1
- Multilanguage added
- New Human Verification Module
- Added headset support to the call screen
- Added alert window when socket connection is lost
- Added face control to selfie screen
- Fixed camera session issue when dismissing Mrz screen
- Switch to NFC screen if KPS data is connected
- Default FPS setting reduced from 30 to 24
- Added alarm tone next to vibration when incoming call

## Requirements
Min Target iOS 12.1 
                    
** Please don't forget to check your plist and entitlements file. All the features shown below are available in Example/IdentifyIOS/ViewController.swift. **

## Setup
                    
Add the following code to your own .podfile:

```ruby
pod 'IdentifyIOS'
pod 'QKMRZParser'
pod 'CHIOTPField/Two'
pod 'IQKeyboardManagerSwift'
pod 'SwiftSignatureView'
pod 'GoogleMLKit/FaceDetection'
```

## Identify SDK
                    
```ruby
Install the necessary libraries into your project with pod install
Customize the "Views" folder in the project according to your own design
SDKCallWaitScreenController is the router screen, the management of modules and call waiting screen are here. Do not change the name of this screen, the SDK works according to this screen.
Be sure to pay attention to delegate methods when customizing
You can update the colors and fonts of the existing design from the "Design.swift" file or the xib file according to your own design. (There are module examples and design customization that can be used in the ViewController.swift file)
For the application to work properly, make sure that the "microphone", "camera", "speech permission" and "NFC Tag Reader Session" settings are turned on in your info.plist file. In the sample application, you can look at the info.plist file.
For the NFC feature to work properly, make sure that the "Near Field Communication Tag Reading" feature is added in the "Signing & Capabilities" settings and check your .entitlements file.
```

## Customizations
                    
In case NFC cannot be read, you can set the maximum error count. When you reach the number you set, the NFC module is automatically canceled and the next module is passed. It comes with 3 by default.
```ruby
GlobalConstants.nfcErrorMaxCount = 3
```
You can present the module you want, in the order you want.
```ruby
manager.addModules(module: [.ncf, .livenessDetection, .selfie])
```
You can customize your network timeout.
```ruby
manager.netw.timeoutIntervalForRequest = 35
manager.netw.timeoutIntervalForResource = 15
```
You can change your network request addresses.
```ruby
manager.baseAPIUrl = "https://api.identifytr.com/"
manager.webSocketUrl = "wss://ws.identifytr.com:8888/"
manager.stunServers = ["stun:stun.l.google.com:19302", "turn:3.64.99.127:3478"]
manager.stunUsername = "test"
manager.stunPassword = "test"
```
You don't need to start all over again in case of disconnection..
```ruby
manager.appQuitType = .onlyCall // If the connection is lost during the call, it only opens the call screen.
manager.appQuitType = .restartModules // All processes start over
```
You can open the app without reading the MRZ with the KPS data
```ruby
manager.mrzBirthDate = "01.12.1950"
manager.mrzValidDate = "03.05.2029"
manager.mrzDocumentNo = "B26C75239"
```
## Skip All Stages, Connect to Representative
                    
You can call the "addSkipModulesButton" function added to SDKBaseViewController from any screen. Thus, you cancel all stages and direct them to the customer representative waiting screen.

## Available Modules
                    
Module Name  | Description
------------- | -------------
nfc           | Initializes the MRZ + NFC Module
livenessDetection  | Starts the vitality check screen
selfie        | A snapshot of the person is taken, it is not allowed to be selected from the gallery.
videoRecord   | For the vitality test, the person is asked to shoot a 5-second video, it is still under construction.
idCard        | The person is asked to take front and back photos of their ID, selection from the gallery is not allowed.
signature     | For the vitality test, the signature of the person is taken.
speech        | For the vitality test, the person is asked to read the text they see on the screen.


## Author
                    
emir@beytekin.net

## License
                    
IdentifyIOS is available under the MIT license. See the LICENSE file for more info.

