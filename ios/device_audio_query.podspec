#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint device_audio_query.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'device_audio_query'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to query audio files and metadata from the device storage.'
  s.description      = <<-DESC
    A Flutter plugin that provides an easy-to-use API for retrieving information about
    songs, albums, artists, and playlists from the iOS media library via MPMediaQuery.
  DESC
  s.homepage         = 'https://github.com/example/device_audio_query'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '13.0'

  # MediaPlayer framework is required for MPMediaQuery, MPMediaLibrary, etc.
  s.frameworks = 'MediaPlayer'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
