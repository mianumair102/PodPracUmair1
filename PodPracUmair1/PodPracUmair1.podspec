Pod::Spec.new do |s|

  s.name         = "PodPracUmair1"
  s.version      = "0.0.6"
  s.summary      = "It is the short Summary of Pod project one"
  s.description  = "It is the short description of Pod project one. I am practicing on it so that when Janbaz will come I will work wih him to fix his issue."

  s.homepage     = "https://github.com/mianumair102/PodPracUmair1"

  s.license      = "MIT"

  s.author             = { "Mian Umair Nadeem" => "shukar.allah91@gmail.com" }

  s.platform     = :ios, "10.0"

  s.source       = { :git => "https://github.com/mianumair102/PodPracUmair1.git", :tag => "0.0.6" }

  s.source_files  = "PodPracUmair1/**/*.{h,m,swift}"
  # s.resource_bundles = {'PodPracUmair1' => ['PodPracUmair1/PodPracUmair1/*.png']}
  s.resource_bundles = {'PodPracUmair1' => ['PodPracUmair1/PodPracUmair1/*.xcdatamodeld']}

  # s.exclude_files = "Classes/Exclude"

end
