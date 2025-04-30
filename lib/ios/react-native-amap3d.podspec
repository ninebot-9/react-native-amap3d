require "json"

package = JSON.parse(File.read(File.join(__dir__, "../../package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-amap3d"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/qiuxiang/react-native-amap3d.git", :tag => "#{s.version}" }


  s.resource_bundles = {
    'react-native-amap3d' => ['Assets/**/*.*']
  }
  s.dependency "React-Core"
#  s.dependency 'AMapNavi'
  
  case ENV['type']
  when 'overseas'
    s.dependency 'GoogleMaps'
    s.source_files = "GoogleMaps/**/*"
  else
    s.dependency 'AMapLibrary/AmapNav'
    s.source_files = "AMap/**/*"
  end
  
end
