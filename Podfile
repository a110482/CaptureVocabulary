# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'CaptureVocabulary' do
  use_frameworks!
  pod 'SnapKit'
  pod 'SwifterSwift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Log'
  pod 'Then'
  pod 'Moya'
  pod 'SQLite.swift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
    end
  end
end
