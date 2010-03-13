require 'rubygems'
require 'sinatra'
$:.unshift File.expand_path(File.join(File.dirname(__FILE__),"lib"))
require 'sitepack'

class App < Sinatra::Application
  include SitePack::Content
  extend SitePack::Config

  set :content_path, 'content'
  set :public, 'public'

  configure do
    site_pack_config("vars.yml")
  end

  get '/' do
    halt 302, {'Location' => '/index.html'}, ['']
  end

  get '/*.:ext' do
    erb site_content(options.content_path, params)
  end

  not_found do
    erb site_content(options.content_path, {:splat => ['404']})
  end

end

if $0 == __FILE__
  App.run! :port => 4567
  exit(1)
end
