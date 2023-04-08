# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

inhibit_all_warnings!


target 'PODZ' do


  # Comment the next line if you don't want to use dynamic frameworks

  use_frameworks!

  # Pods for PODZ

pod 'Firebase/Auth'
pod 'Firebase/Analytics'
pod 'Firebase/Firestore'
pod 'FBSDKLoginKit'
pod 'GoogleSignIn'
pod 'FirebaseFirestoreSwift'
pod 'Firebase/Messaging'
pod 'Firebase/Functions'
pod 'Firebase/Crashlytics'
pod 'Purchases'
pod 'Firebase/Performance'


post_install do |installer|   

	installer.pods_project.build_configurations.each do |config|
        	config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
	end
	
	installer.pods_project.targets.each do |t|
		t.build_configurations.each do |bc|
           		bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
		end
	end

end

end

