require 'fileutils'
require 'app'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__),"lib"))
require 'sitepack'

SiteDir = "site".freeze
DistFiles = Dir["public/**"].freeze
SiteDomain = "test.domain.com".freeze

task :default => :package

desc "Update Static Pages"
task :package => :clean do
  FileUtils.mkdir_p(SiteDir) unless File.exist?(SiteDir)

  bundler = SitePack::Builder.new(App, SiteDomain, SiteDir)
  bundler.content('content') do|path|
    bundler.save(path)
  end

  DistFiles.each do|f|
    system("cp -r #{f} #{SiteDir}")
  end

  system("tar -zcf site.tar.gz #{SiteDir}")
end

desc "Delete Site dir"
task :clean do
  system("rm -rf #{SiteDir}")
end
