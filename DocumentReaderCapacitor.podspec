require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name = 'DocumentReaderCapacitor'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = package['homepage']
  s.author = package['author']
  s.source = { :git => 'https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Cordova.git', :tag => s.version.to_s }
  s.source_files = 'ios/Sources/DocumentReaderSdkPlugin/**/*.{h,m,mm,swift}'
  s.public_header_files = 'ios/Sources/DocumentReaderSdkPlugin/**/*.h'
  s.ios.deployment_target = '13.0'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'
  s.libraries = 'c++'
  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation'
  # Keep framework on disk; do NOT use vendored_frameworks — docsdk is
  # device arm64 only and CocoaPods would force-link it into simulator builds.
  s.preserve_paths = 'ios/Frameworks/**/*'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]' => '$(inherited) "$(PODS_TARGET_SRCROOT)/ios/Frameworks"',
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework docsdk -lc++',
  }
end
