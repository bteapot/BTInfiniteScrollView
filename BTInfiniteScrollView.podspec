Pod::Spec.new do |s|
  s.name             = "BTInfiniteScrollView"
  s.version          = "1.0.8"
  s.summary          = "Yet another Infinite ScrollView."
  s.description      = <<-DESC
                       UIScrollView subclass with infinite scrolling.
                       DESC
  s.homepage         = "https://github.com/bteapot/BTInfiniteScrollView"
  s.screenshots      = "http://i.imgur.com/LW1OnZM.gif"
  s.license          = 'MIT'
  s.author           = { "Денис Либит" => "bteapot@me.com" }
  s.source           = { :git => "https://github.com/bteapot/BTInfiniteScrollView.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true

  s.source_files     = 'Pod/Classes'
end
