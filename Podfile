platform :ios, '13.0'


def shared_pods
  use_frameworks!
  pod 'QuickLayout'
  pod 'SPAlert'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'SwiftRichString'
  pod 'SnapKit'
end

def photos_pods
  pod 'RealmSwift'
  pod 'SDWebImage', '~> 5.0'
  pod 'SDWebImagePhotosPlugin'
end

target 'Find' do
  shared_pods
  photos_pods
  pod 'SwiftEntryKit'
end

target 'TabController' do
  shared_pods
end

target 'Photos' do
  shared_pods
  photos_pods
end

target 'Camera' do
  shared_pods
end

target 'Lists' do
  shared_pods
end


post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

