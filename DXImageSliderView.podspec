#
# Be sure to run `pod lib lint DXImageSliderView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DXImageSliderView'
  s.version          = '1.0.0'
  s.summary          = 'A light weight image slider view with page controller which easy to use and modify.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
'A light weight image slider view with page controller which easy to use and modify.'
                       DESC

  s.homepage         = 'https://github.com/yasirdx777/DXImageSliderView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yasirdx777' => 'yasir.romaya@gmail.com' }
  s.source           = { :git => 'https://github.com/yasirdx777/DXImageSliderView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.instagram.com/yasirdx777'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*.*'
  
  s.swift_version = '5.0'
  
  s.platforms = {"ios": "11.0"}
end
