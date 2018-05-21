Pod::Spec.new do |s|

  s.name         = "ICViewPager"
  s.version      = "2.0.0"
  s.summary      = ""

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/monsieurje/ICViewPager"
  s.screenshots  = ""
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Ilter Cengiz" => "iltercengiz@yahoo.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/monsieurje/ICViewPager.git", :tag => "2.0.0" }
  s.source_files = 'ICViewPager/ICViewPager/**/*.swift'
  s.requires_arc = true

end
