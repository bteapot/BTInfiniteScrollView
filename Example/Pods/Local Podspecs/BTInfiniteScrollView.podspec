#
# Be sure to run `pod lib lint BTInfiniteScrollView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BTInfiniteScrollView"
  s.version          = "1.0.0"
  s.summary          = "Yet another Infinite ScrollView."
  s.description      = <<-DESC
                       UIScrollView subclass with infinite scrolling.
                       DESC
  s.homepage         = "https://github.com/bteapot/BTInfiniteScrollView"
  s.screenshots      = "http://i.imgur.com/LW1OnZM.gif"
  s.license          = 'MIT'
  s.author           = { "Денис Либит" => "bteapot@me.com" }
  s.source           = { :git => "https://github.com/bteapot/BTInfiniteScrollView.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'BTInfiniteScrollView' => ['Pod/Assets/*.png']
  }
end
