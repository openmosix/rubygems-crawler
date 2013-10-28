require 'rake/testtask'

Rake::TestTask.new do |task|
  task.libs << "test"  
  task.test_files = FileList['test/*test.rb']
  task.verbose = false
end

task :build do
  system "gem build rubygems-crawler.gemspec"
end

task :default => :test