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
  # spec.source_files  = "Sources", "Sources/{Common,RxUNILib,CombineUNILib}/*.{swift}"
  # spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # spec.framework  = "SomeFramework"
  # spec.frameworks = "SomeFramework", "AnotherFramework"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
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
