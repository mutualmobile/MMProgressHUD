Pod::Spec.new do |s|
  s.name         = "MMProgressHUD"
  s.version      = "0.0.1"
  s.summary      = "A progress HUD with flair."
  # s.description  = <<-DESC
  #                   An optional longer description of MMProgressHUD
  #
  #                   * Markdown format.
  #                   * Don't worry about the indent, we strip it!
  #                  DESC
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
