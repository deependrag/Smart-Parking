# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'SmartParking' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SmartParking

  #For Design
  pod 'IBAnimatable'

  #Firebase
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift', '~> 7.11.0-beta'
  pod 'Firebase/Storage'

  pod 'lottie-ios'
  pod 'IQKeyboardManagerSwift'
  
  pod "ToastViewSwift"
  
  post_install do |installer|
      installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
          end
      end
  end
end
