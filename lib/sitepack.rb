require 'stringio'
require 'pathname'

require 'hpricot'
require 'redcloth'

module SitePack
  RackDefaultEnv = {
    'REQUEST_METHOD' => 'GET',
    'SCRIPT_NAME' => 'app.rb',
    'SERVER_NAME' => 'localhost',
    'SERVER_PORT' => 9999,
    'rack.url_scheme' => 'http',
    'rack.version' => [1,1],
    'rack.input' => StringIO.new,
    'rack.errors' => StringIO.new,
    'rack.run_once' => true,
    'rack.multiprocess' => false,
    'rack.multithread' => false
  }.freeze

  #
  # Generate a static site using sinatra
  #
  # Given a content root folder, Builder will auto generate a site.
  #
  # builder = SitePack::Builder.new(MyAppKlass, 'mydomain.com', './site/')
  # 
  # # walk all .xml files in the './content/' directory
  # # calling builder.save with the computed path will
  # # write out a rendered .html file into the ./site/ directory at the path
  # # ./content/#{path}.html
  #
  # builder.content('./content/') do|path|
  #   builder.save(path)
  # end
  # 
  class Builder

    def initialize(appklass, domain, sitedir)
      @appklass = appklass
      @domain   = domain
      @sitedir  = sitedir
    end

    #
    # yield each sub path of each content file within the content directory
    # or return an array of all paths
    #
    def content(dir)
      dir_path = Pathname.new(File.expand_path(dir))
      paths = Dir["#{dir}/**/**.xml"].map{|p| Pathname.new(File.expand_path(p)).relative_path_from(dir_path) }
      paths.each {|p| yield p } if block_given?
      paths
    end

    #
    # save a given url into the site URL
    # 
    def save(path)
      html_path = path.sub(/\.xml$/,'.html')
      file = "#{@sitedir}/#{html_path}"
      url = "http://#{@domain}/#{html_path}"
      env = RackDefaultEnv.dup
      uri = URI.parse(url)
      env['PATH_INFO'] = uri.path
      env['QUERY_STRING'] = uri.query || ''
      req = Rack::Request.new(env) #Rack::MockRequest.env_for(url, env)
      status, headers, body = @appklass.call(req.env)
      res = Rack::MockResponse.new(status, headers, body, req.env["rack.errors"].flush)

      case status
      when 200
        puts "render: #{url} as #{file}"
        FileUtils.mkdir_p(File.dirname(file)) unless File.exist?(File.dirname(file))
        File.open(file,'wb') { |f| f << res.body }
      else
        raise "error #{status} status code: #{status} when requesting: #{url}\n#{res.body}"
      end
    end
  end

  #
  # enable content by including this module in your sinatra application
  #
  # class MyApp  < Sinatra::Application
  #   include SitePack::Content
  #   set :content_path, 'content'
  #   set :public, 'public'
  #
  #   get '/:page.html' do
  #     erb site_content(options.content_path, params)
  #   end
  # end
  #
  # sample page content format:
  #
  # <?xml version="1.0"?>
  # <page>
  # <title>Title Content</title>
  # <body template="special" filter="redcloth">
  # h1. Foo Bar
  #
  # A *simple* paragraph with 
  # a line break, some _emphasis_ and a "link":http://redcloth.org
  #
  # * an item
  # * and another
  #
  # # one
  # # two
  #
  # </body>
  # </page>
  #
  # template = by default is page, e.g. views/page.erb
  # filter   = by default is redcloth, but can be html -> in which case use <![CDATA[ html ]]>
  #
  module Content

    def site_content(content_path, params)
      if params[:splat].nil?
        file_path = "#{content_path}/index.xml"
      else
        file_path = "#{content_path}/#{params[:splat].join('/')}.xml"
      end
      halt 404, "page not found: #{file_path.inspect}" unless File.exists?(file_path)
      doc = Hpricot.XML(File.read(file_path))
      @title = doc.at(:title) ? doc.at(:title).inner_html : nil
      @body = doc.at(:body)
      if @body
        template = @body[:template] || 'page'
        filter = @body[:filter] || 'redcloth'
        case filter
        when 'redcloth'
          @body = RedCloth.new(@body.inner_html).to_html
        when 'html'
          @body = @body.inner_html
        else
          halt 500, "Unsupported filter: #{filter} when rendering #{file_path}"
        end
      else
        halt 500, "Missing body tag!"
      end
      template.to_sym
    end

  end

end
