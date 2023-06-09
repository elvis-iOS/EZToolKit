#
# Be sure to run `pod lib lint EZToolKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EZToolKit'
  s.version          = '0.1.1'
  s.summary          = 'A short description of EZToolKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/elvis-iOS/EZToolKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhujun' => 'elviszhu.0122@gmail.com' }
  s.source           = { :git => 'https://github.com/elvis-iOS/EZToolKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

#  s.source_files = 'EZToolKit/Classes/**/*'

  s.subspec 'Vendor' do |v|
      v.source_files = 'EZToolKit/Classes/Vendor/**/*'
  end

  s.subspec 'Common' do |c|
      c.source_files = 'EZToolKit/Classes/Common/**/*'
      c.dependency 'EZToolKit/Vendor'
  end
  
  s.subspec 'App' do |a|
      a.source_files = 'EZToolKit/Classes/App/**/*'
      a.dependency 'EZToolKit/Common'
  end
  
  # s.resource_bundles = {
  #   'EZToolKit' => ['EZToolKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
