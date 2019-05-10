Pod::Spec.new do |s|

  s.name         = "MOA-Swift"
  s.version      = "0.2.0"
  s.summary      = "Swift Boilerplate code and building blocks for Module Oriented Architecture (MOA)"
  s.description  = <<-DESC
                  Module Oriented Architecture (MOA) is a principle of building the client apps
                  with the logic of routed services, but local, within the bundle.
                  This repository contains all the building blocks to implement it in the apps
                   DESC
  s.homepage     = "http://itnext.io/module-oriented-architecture-4b54c8976415"
  s.license      = "MIT"

  s.author             = { "Mladen Despotovic" => "mladen.despotovic@icloud.com" }
  s.social_media_url   = "http://twitter.com/mladendes"

  s.platform     = :ios, "11.0"
  s.swift_version = '4.2'

  s.source       = { :git => "https://github.com/poksi592/MOA-Swift.git", :tag => "0.2.0" }

  s.source_files  = "MOA-Swift/MOA-Swift/Helpers/*", "MOA-Swift/MOA-Swift/Application Services/*", "MOA-Swift/MOA-Swift/Routing/*"
  s.exclude_files = "MOA-Swift/MOA-Swift/Application Services/Examples/*"

end
