Pod::Spec.new do |s|
  s.name         = "EEBlocks"
  s.version      = "1.1.0"
  s.summary      = "Simple blocks wrapper for Objective-C."
  s.homepage     = "https://github.com/eugeneego/Blocks"
  s.license      = "MIT"
  s.author       = "Evgeniy Egorov"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/eugeneego/Blocks.git", :tag => "#{s.version}" }
  s.source_files  = "EEBlocks/*.{h,m,c}"
  s.requires_arc = true
end
