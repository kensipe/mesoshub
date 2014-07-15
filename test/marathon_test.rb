require "minitest/autorun"
require "mocha/setup"
require "webmock/minitest"
require_relative "../lib/mesoshub"

class MarathonTest < MiniTest::Unit::TestCase
  def setup
    @url = "http://marathon.url:8080"
    @marathon = Mesoshub::Marathon.new(@url)
  end

  def test_apps_url
    assert_equal @marathon.apps_url, "http://marathon.url:8080/v2/apps"
  end

  def test_tasks_url
    assert_equal @marathon.tasks_url, "http://marathon.url:8080/v2/tasks"
  end

  def test_endpoints_success
    tasks_response = File.open('test/sample_tasks')
    stub_request(:get, @marathon.tasks_url).to_return( {:body => tasks_response} )
    apps_response = File.open('test/sample_apps')
    stub_request(:get, @marathon.apps_url).to_return( {:body => apps_response} )
    assert_equal Array, @marathon.endpoints.class
    assert_equal 10,    @marathon.endpoints.size

    first_endpoint = {"name"=>"apns-deploy-00022", "health_path"=>"/", "port"=>14924, "servers"=>["10.30.6.170:31872"]}
    assert_equal first_endpoint, @marathon.endpoints.first
  end

  def test_endpoints_empty_withoutapps
    tasks_response = File.open('test/sample_tasks')
    stub_request(:get, @marathon.tasks_url).to_return( {:body => tasks_response} )
    stub_request(:get, @marathon.apps_url).to_return( {:body => ""} )
    assert_equal [], @marathon.endpoints
  end

  def test_endpoints_servers_empty_withouttasks
    stub_request(:get, @marathon.tasks_url).to_return( {:body => ""} )
    apps_response = File.open('test/sample_apps')
    stub_request(:get, @marathon.apps_url).to_return( {:body => apps_response} )
    assert_equal [], @marathon.endpoints.select {|a| !a["servers"].empty?}
  end

end
