# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ABCarte2' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Workaround for Cocoapods issue #7606
  post_install do |installer|
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end

  # Pods for ABCarte2
pod 'IQKeyboardManagerSwift'
pod 'BarcodeScanner', '4.1.3'
pod 'RealmSwift'
pod 'Alamofire'
pod 'NXDrawKit', '0.7.1'
pod 'JLStickerTextView', :git => 'https://github.com/luiyezheng/JLStickerTextView.git'
pod 'SwiftyJSON'
pod 'SDWebImage'
pod 'Fabric'
pod 'Crashlytics'
pod 'lottie-ios'
pod 'SnapKit'
pod 'EFColorPicker', '1.1.1'
pod 'ExpyTableView', '1.0.0'
pod 'TransitionButton', :git => 'https://github.com/AladinWay/TransitionButton.git'
pod 'Charts', '3.2.1'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'ReachabilitySwift'
end
