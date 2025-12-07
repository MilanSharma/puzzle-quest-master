
platform :ios, '17.0'
use_frameworks!

target 'PuzzleQuestMaster' do
  pod 'Google-Mobile-Ads-SDK'
end

# FORCE DISABLE SIGNING FOR ALL PODS
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ""
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
    end
  end
end
