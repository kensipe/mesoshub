require "minitest/autorun"
require "mocha/setup"
require "webmock/minitest"
require_relative "../lib/mesoshub"

class MarathonTest < MiniTest::Unit::TestCase
  def setup
    @url = "http://marathon.url:8080"
    @marathon = Mesoshub::Marathon.new(@url)
  end

  def test_endpoints_url
    assert_equal @marathon.endpoints_url, "http://marathon.url:8080/v1/endpoints"
  end

  def test_endpoints_success
    response = File.open('test/sample_endpoints')
    stub_request(:get, @marathon.endpoints_url).to_return( {:body => response} )
    assert_equal @marathon.endpoints.class, Array
    assert_equal @marathon.endpoints.size, 2
    assert_equal @marathon.endpoints.first,
      {"name"=>"recommender-1.1.1", "port"=>10522, "servers"=>["ip-10-30-6-115.us-west-1.compute.internal:31525"]}
  end

  def test_endpoints_empty
    stub_request(:get, @marathon.endpoints_url).to_return( {:body => ""} )
    assert_equal @marathon.endpoints, []
  end

end
