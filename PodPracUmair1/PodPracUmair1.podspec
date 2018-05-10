Pod::Spec.new do |s|

  s.name         = "PodPracUmair1"
  s.version      = "1.0.0"
  s.summary      = "It is the short Summary of Pod project one"
  s.description  = "It is the short description of Pod project one. I am practicing on it so that when Janbaz will come I will work wih him to fix his issue."

  s.homepage     = "https://github.com/mianumair102/PodPracUmair1"

  s.license      = "MIT"

  s.author             = { "Mian Umair Nadeem" => "shukar.allah91@gmail.com" }

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/mianumair102/PodPracUmair1.git", :tag => "1.0.0" }

  s.source_files  = "PodPracUmair1/**/*.{h,m,swift}"


  s.source_files  = 'PodPracUmair1/PodPracUmair1', 'PodPracUmair1/PodPracUmair1/ChatDBModel.xcdatamodeld', 'PodPracUmair1/PodPracUmair1/ChatDBModel.xcdatamodeld/*.xcdatamodel'
  s.resources = [ 'PodPracUmair1/PodPracUmair1/ChatDBModel.xcdatamodeld', 'PodPracUmair1/PodPracUmair1/ChatDBModel.xcdatamodeld/*.xcdatamodel']
  s.preserve_paths = 'PodPracUmair1/PodPracUmair1/ChatDBModel.xcdatamodeld'
  s.framework  = 'CoreData'
  s.requires_arc = true

s.dependency "SwiftHEXColors"
s.dependency "Alamofire", "~> 4.0"
s.dependency "SDWebImage/WebP"
s.dependency "INSPersistentContainer"
s.dependency "RMQClient"

  # s.resource_bundles = {'PodPracUmair1' => ['PodPracUmair1/PodPracUmair1/*.png']}
# s.resource_bundles = {'PodPracUmair1' => ['PodPracUmair1/PodPracUmair1/*.xcdatamodeld']}

  # s.exclude_files = "Classes/Exclude"

end
