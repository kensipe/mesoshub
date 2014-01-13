module Mesoshub
  class Webapp < Sinatra::Application
    set :static, true
    set :public_folder, File.dirname(__FILE__) + '/../app'

    set :bind, '0.0.0.0'
    set :port, '1337'

    set :protection, :except => [:http_origin]

    post "/events" do
      payload = request.body.read
      message = JSON.parse(payload)
      restart_haproxy if message["eventType"] == "status_update_event"
      {"status" => "success"}.to_json
    end

    get "/endpoints" do
      settings.marathon.endpoints.to_json
    end

    get "/app_groups" do
      settings.zookeeper.app_groups.to_json
    end

    post "/app_groups" do
      payload = request.body.read
      new_app_groups = JSON.parse(payload)
      #remember to validate app_groups
      settings.zookeeper.app_groups = new_app_groups
      restart_haproxy #if $zookeeper.valid?
      {"status" => "success"}.to_json
    end

    def restart_haproxy
      settings.haproxy.update_endpoints(settings.marathon.endpoints)
      settings.haproxy.update_app_groups(settings.zookeeper.app_groups)
      settings.haproxy.write_config
      settings.haproxy.safe_reload
    end
  end
end
