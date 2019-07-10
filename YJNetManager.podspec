Pod::Spec.new do |s|

  s.name         = "YJNetManager"
  s.version      = "1.0.7"
  s.summary      = "网络工具，网络监控"


  s.homepage     = "https://github.com/LYajun/YJNetManager"
 

  s.license      = "MIT"
 
  s.author             = { "刘亚军" => "liuyajun1999@icloud.com" }
 

  s.platform     = :ios, "8.0"

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/LYajun/YJNetManager.git", :tag => s.version }


  s.source_files  = "YJNetManager/*.{h,m}"


  s.requires_arc = true

  s.dependency 'YJExtensions'
  s.dependency 'AFNetworking'
  s.dependency 'Reachability'
end
