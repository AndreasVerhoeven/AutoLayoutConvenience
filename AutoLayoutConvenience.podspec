Pod::Spec.new do |s|
    s.name             = 'AutoLayoutConvenience'
    s.version          = '1.0.0'
    s.summary          = 'Convenience Helpers for working with AutoLayout'
    s.homepage         = 'https://github.com/AndreasVerhoeven/AutoLayoutConvenience'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Andreas Verhoeven' => 'cocoapods@aveapps.com' }
    s.source           = { :git => 'https://github.com/AndreasVerhoeven/AutoLayoutConvenience.git', :tag => s.version.to_s }
    s.module_name      = 'AutoLayoutConvenience'

    s.swift_versions = ['5.3']
    s.ios.deployment_target = '11.0'
    s.source_files = 'Sources/*.swift', 'Sources/**/*.swift'
end
