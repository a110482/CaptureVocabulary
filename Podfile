 platform :ios, '15.0'

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
  pod 'FirebaseCrashlytics'
  pod 'SSZipArchive'
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
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
     end
  end
end
