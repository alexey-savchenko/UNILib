#
#  Be sure to run `pod spec lint UNILib.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "UNILib"
  spec.version      = "1.0.1"
  spec.summary      = "A short description of UNILib."
  spec.homepage = "https://github.com/alexey-savchenko/UNILib"
  spec.description  = "Universe team repo"
  spec.license      = "MIT"
  spec.author             = { "Alexey Savchenko" => "alexey.savchenko@gen.tech" }
  spec.platform     = :ios
  spec.ios.deployment_target = "13.0"
  spec.default_subspec = "Common"
  spec.swift_version = '5.0'
  spec.source       = { :git => "https://github.com/alexey-savchenko/UNILib.git", :tag => "#{spec.version}" }

  spec.subspec 'Common' do |sp|
    sp.source_files = 'Sources/Common/'
  end

  spec.subspec 'RxUNILib' do |sp|
    sp.source_files = 'Sources/RxUNILib/'
    sp.dependency "UNILib/Common"
    sp.dependency "RxSwift"
    sp.dependency "RxCocoa"
    sp.dependency "ReachabilitySwift"
  end

  spec.subspec 'CombineUNILib' do |sp|
    sp.dependency "UNILib/Common"
    sp.source_files = 'Sources/CombineUNILib/'
  end
end
