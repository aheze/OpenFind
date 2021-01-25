platform :ios, '13.0'

target 'Find' do
  use_frameworks!
#use_modular_headers!

pod 'QuickLayout'
pod 'RealmSwift'
pod 'SDWebImage', '~> 5.0'
pod 'SDWebImagePhotosPlugin'
pod 'SwiftEntryKit'
pod 'SnapKit'
pod 'Parchment'
pod 'SPAlert'
pod 'SwiftyJSON', '~> 4.0'
pod 'WhatsNewKit'
pod 'SwiftRichString'

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

