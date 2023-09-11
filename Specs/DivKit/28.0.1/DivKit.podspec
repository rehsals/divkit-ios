Pod::Spec.new do |s|
  s.name             = 'DivKit'
  s.version          = '28.0.1'
  s.summary          = 'DivKit framework'
  s.description      = 'DivKit is a backend-driven UI framework'
  s.homepage         = 'https://divkit.tech'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'divkit' => 'divkit@yandex-team.ru' }
  s.source           = { :git => 'https://github.com/divkit/divkit-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.7'
  s.requires_arc = true
  s.prefix_header_file = false
  s.platforms = { :ios => '11.0' }

  s.dependency 'DivKit_LayoutKit', s.version.to_s
  s.dependency 'DivKit_Serialization', s.version.to_s
  s.dependency 'VGSLCommonCore', '~> 2.2.0'
  s.dependency 'VGSLNetworking', '~> 2.2.0'

  s.source_files = [
    'DivKit/**/*'
  ]
end
