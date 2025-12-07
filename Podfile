
platform :ios, '17.0'
use_frameworks!

target 'PuzzleQuestMaster' do
  # We pin this to 11.10.0 because newer versions renamed the classes
  pod 'Google-Mobile-Ads-SDK', '11.10.0' 
end

# FORCE DISABLE SIGNING FOR ALL PODS (Required for unsigned build)
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
