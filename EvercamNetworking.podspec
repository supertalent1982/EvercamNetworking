Pod::Spec.new do |s|
  s.name             = "EvercamNetworking"
  s.version          = "1.0.0"
  s.summary          = "Objective C Evercam API Wrapper"
  s.homepage         = "http://www.evercam.io/"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Jiang Wei" => "supertalent1982@hotmail.com" }
  s.source           = { :git => "https://github.com/supertalent1982/EvercamNetworking.git", :tag => '1.0.0' }

  s.platform         = :ios, '7.0'
  s.source_files     = 'EvercamNetworking/*.{h,m}'
  s.requires_arc     = true
  s.dependency      'AFNetworking', '~> 2.3'
end
