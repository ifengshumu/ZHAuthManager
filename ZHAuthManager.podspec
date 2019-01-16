#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ZHAuthManager"
  s.version      = "1.0.1"
  s.summary      = "系统权限"
  s.description  = "iOS系统权限请求、判断"

  s.homepage     = "https://github.com/leezhihua/ZHAuthManager"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors      = {"leezhihua" => "leezhihua@yeah.net"}

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/leezhihua/ZHAuthManager.git", :tag => "#{s.version}" }

  s.source_files = "Pod/Classes/*.{h,m}"

  s.frameworks   =  "Foundation","CoreTelephony","CoreLocation","AVFoundation","Photos","AssetsLibrary","Contacts","AddressBook","EventKit","Intents","Speech"

  s.requires_arc = true

end
