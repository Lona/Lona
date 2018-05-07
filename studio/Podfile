source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :osx, '10.11'

# Workspace
workspace 'LonaStudio.xcworkspace'
use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!

# Pods
def important_pods

  # Pods for LonaStudio
  pod 'Yoga', '~> 1.6'
  pod 'MASPreferences', '~> 1.3'
  pod 'SwiftLint'
  pod 'Sparkle'
  pod 'LetsMove'
  pod 'lottie-ios', :git => 'https://github.com/dabbott/lottie-ios.git', :branch => 'master'

end

target 'LonaStudio' do
  important_pods
end

target 'LonaStudioTests' do
  important_pods
end
