Pod::Spec.new do |s|
  s.name             = 'DivKit_LayoutKitInterface'
  s.module_name      = 'LayoutKitInterface'
  s.version          = '28.4.1-source'
  s.summary          = 'Part of DivKit framework'
  s.description      = 'Part of DivKit framework'
  s.homepage         = 'https://divkit.tech'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'divkit' => 'divkit@yandex-team.ru' }
  s.source           = { :git => 'https://github.com/rehsals/divkit-ios.git', :tag => s.version.to_s }

  s.swift_version = '5.7'
  s.requires_arc = true
  s.prefix_header_file = false
  s.platforms = { :ios => '11.0' }
  s.static_framework = true

  s.dependency 'VGSLBase', '2.2.1-source'
  s.dependency 'VGSLBaseTiny', '2.2.1-source'
  s.dependency 'VGSLBaseUI', '2.2.1-source'

  s.source_files = [
    'LayoutKit/Interface/**/*'
  ]
end
