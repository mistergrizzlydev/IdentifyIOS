#
# Be sure to run `pod lib lint IdentifyIOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IdentifyIOS'
  s.version          = '0.1.1'
  s.summary          = 'identify.com.tr'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
"Identify 24 iOS Pod"
                       DESC

  s.homepage         = 'https://github.com/emirbeytekin/IdentifyIOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Emir Beytekin' => 'emir@beytekin.net' }
  s.source           = { :git => 'https://github.com/emirbeytekin/IdentifyIOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = "5"
  s.ios.deployment_target = '12.1'

  s.source_files = '*'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  
  s.dependency 'Alamofire', '~> 4.9.1'
  s.dependency 'Starscream', '~> 3.0.2'
  s.dependency 'GoogleWebRTC'
  s.dependency 'NFCPassportReader'
  
  
  # s.resource_bundles = {
  #   'IdentifyIOS' => ['IdentifyIOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
