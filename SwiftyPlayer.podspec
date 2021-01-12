Pod::Spec.new do |spec|

  spec.name = "SwiftyPlayer"
  spec.version = "1.2.3"
  spec.summary = "An audio and video playback component written in Swift"

  spec.description = <<-DESC
  SwiftyPlayer is an audio and video playback component written in Swift, based on AVPlayer.
  SwiftyPlayer only focuses on playback events, and does not provide screen rotation, gesture control, and other functions that are not related to playback events.
                   DESC

  spec.homepage = "https://github.com/shanbay/SwiftyPlayer"
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author = { "shiwei93" => "stayfocusjs@gmail.com" }
  spec.platform = :ios, "10.0"
  spec.swift_versions = '5.1'

  spec.source = { :git => "https://github.com/shanbay/SwiftyPlayer.git", :tag => "#{spec.version}" }
  spec.dependency 'PINCache'

  spec.source_files = [
    'Sources/**/*.swift',
  ]
end
