# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

def shared_pods
  pod 'Log'
  pod 'SQLite.swift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Moya'
  pod 'Then'
  pod 'SnapKit'
  pod 'SwifterSwift'
  pod 'Google-Mobile-Ads-SDK'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseAnalytics'
end

target 'CaptureVocabulary' do
  use_frameworks!
  shared_pods
end

target 'CaptureVocabularyWidgetExtension' do
  use_frameworks!
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
     end
  end
end
