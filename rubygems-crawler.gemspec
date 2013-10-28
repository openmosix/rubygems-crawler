Gem::Specification.new do |s|
  s.name = "rubygems-crawler"
  s.version = `cat #{File.dirname(__FILE__)}/VERSION`
  s.authors = ['Luca Bonmassar']
  s.email = ['luca@gild.com']
  s.homepage = 'http://www.gild.com'
  s.summary = 'A very simple crawler for RubyGems.org'
  s.description = 'A very simple crawler for RubyGems.org used to demo the power of ElasticSearch at RubyConf 2013'
  s.files = `git ls-files | grep lib`.split("\n")

  s.executables = `git ls-files -- bin/*`.split("\n").map{|i| i.gsub(/^bin\//,'')}
  
  s.add_dependency 'nokogiri', '>= 1.5.5'  
  s.add_dependency 'mongo', '~> 1.8.0'
  s.add_dependency 'bson_ext', '~> 1.8.0'
  s.add_dependency 'gems', "~> 0.8.3"
    
  s.add_development_dependency "rake", ">= 0"
end
