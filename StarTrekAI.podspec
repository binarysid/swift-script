#
# Be sure to run `pod lib lint StarTrekAI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  version            = '1.0.6'
  s.name             = 'StarTrekAI'
  s.version          = version
  s.summary          = 'A short description of StarTrekAI.'
  s.swift_versions = ['5.10']
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Linkon/StarTrekAI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'V2 Technologies' => 'linkon.devin@gmail.com' }
  s.source           = { :git => 'https://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@github.com/V2-Technologies-LTD/StarTrekAi-IOS.git', :tag => version }

#  s.source           = { :git => 'https://github.com/Linkon/StarTrekAI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'

  s.source_files = 'StarTrekAI/Classes/**/*'
  s.resources =  ['StarTrekAI/Assets/**/*']
  # s.resource_bundles = {
  #   'StarTrekAI' => ['StarTrekAI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Kingfisher', '~> 8.0'
   s.dependency 'PhoneNumberKit', '~> 3.7'
end
