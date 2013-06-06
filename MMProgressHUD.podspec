Pod::Spec.new do |s|
  s.name         = "MMProgressHUD"
  s.version      = "0.0.3-mm"
  s.summary      = "An easy to use HUD interface with flair."
  s.homepage     = "https://stash.r.mutualmobile.com/projects/IOS/repos/mmprogresshud"
  s.license      = 'MIT'
  s.author       = { "Lars Anderson" => "lars.anderson@mutualmobile.com" }
  s.source       = {
     :git => "ssh://git@stash.r.mutualmobile.com/ios/mmprogresshud.git",
     :tag => s.version.to_s
  }
  s.platform     = :ios, '5.0'
  s.source_files = 'Source/*.{h,m}'
  s.public_header_files = 'Source/MMProgressHUD.h'
  s.frameworks = 'QuartzCore', 'CoreGraphics'
  s.requires_arc = true
end
