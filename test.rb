
require 'app'
require 'test/unit'
require 'rack/test'

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App
  end

  def test_index_redirect
    get '/'
    assert_equal 302, last_response.status
  end

  def test_404
    get '/foobar.html'
    assert_equal 404, last_response.status
    assert_match /That page is missing/, last_response.body
  end

  def test_500
    get '/badcontent.html'
    assert_equal 500, last_response.status
    assert_match /Missing body tag/, last_response.body
  end

  def test_200
    get '/index.html'
    assert_equal 200, last_response.status
    assert_match /Home Page/, last_response.body
  end

  def test_package
    system("mv content/badcontent.xml .")
    system("rake package")
    assert File.exist?("site/index.html")
    assert File.exist?("site/page2.html")
    assert File.exist?("site/services/foo.html")
    assert File.exist?("site/404.html")
  ensure
    system("mv badcontent.xml content/badcontent.xml")
  end

end
