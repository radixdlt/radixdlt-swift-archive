platform :ios, '11.0'
inhibit_all_warnings!
use_modular_headers!

def shared
  # Code convention linter
  pod 'SwiftLint'

  # Logging
  pod 'SwiftyBeaver' 

  # Reactive
  pod 'RxSwift'
end

target 'RadixSDK' do
  shared

  target 'RadixSDKTests' do
    inherit! :search_paths
    pod 'RxTest'
    pod 'RxBlocking'
  end
end