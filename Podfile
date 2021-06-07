# Uncomment the next line to define a global platform for your project
source 'https://gitee.com/mirrors/CocoaPods-Specs.git'
platform :ios, '11.0'
#1.10.0 电脑pod 版本

def common
  #pod 'KSPlayer', :path => '../', :testspecs => ['Tests']
  #pod 'OpenSSL', :path => '../'
  #pod 'FFmpeg'
end

target 'SwiftDemos' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
inhibit_all_warnings!

pod 'SwiftyTesseract'
pod 'SwifterSwift'
# pod 'KSPlayer',:git => 'https://github.com/kingslay/KSPlayer.git', :branch => 'develop'
 #   pod 'FFmpeg',:git => 'https://github.com/kingslay/KSPlayer.git', :branch => 'develop'
  #  pod 'Openssl',:git => 'https://github.com/kingslay/KSPlayer.git', :branch => 'develop'

common

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
        end
    end
end



end
