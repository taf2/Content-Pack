Gem::Specification.new do |s|
  s.name          = "sitepack"
  s.authors       = ["Todd A. Fisher"]
  s.version       = "0.5"
  s.date          = '2010-03-02'
  s.description   = "Sinatra Static Pages"
  s.summary       = "Sinatra Static Pages"
  s.email         = "todd.fisher@gmail.com"
  s.files         = ["README", "lib/sitepack.rb"]
  s.require_paths = ['lib']

  s.add_dependency 'hpricot'
  s.add_dependency 'RedCloth'
  s.add_dependency 'erubis'

  s.test_files    = ["test.rb"]
end
