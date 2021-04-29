Pod::Spec.new do |s|
  s.name             = 'SwiftLogger'
  s.version          = '1.1.0'
  s.summary          = 'SwiftLogger'
  s.description      = <<-DESC
SwiftLogger
                       DESC

  s.homepage         = 'https://github.com/sergejs/SwiftLogger'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sergejs Smirnovs' => 'sergey@nbi.me' }
  s.source           = { :git => 'https://github.com/sergejs/SwiftLogger.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'Sources/SwiftLogger/**/*'
end
