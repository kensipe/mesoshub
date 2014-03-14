module Mesoshub
  class Webapp < Sinatra::Application
    set :static, true
    set :public_folder, File.dirname(__FILE__) + '/../app'

    set :bind, '0.0.0.0'
    set :port, '1337'

    set :protection, :except => [:http_origin]

    get "/" do
      send_file File.join(settings.public_folder, 'index.html')
    end

    get "/haproxyfqdn" do
      {"haproxyfqdn" => settings.haproxyfqdn}.to_json
    end

    post "/events" do
      payload = request.body.read
      message = JSON.parse(payload)
      restart_haproxy if message["eventType"] == "status_update_event"
      {"status" => "success"}.to_json
    end

    get "/endpoints" do
      settings.marathon.endpoints.to_json
    end

    get "/groups" do
      settings.zookeeper.groups.to_json
    end

    post "/groups" do
      payload = request.body.read
      new_groups = JSON.parse(payload)
      #remember to validate groups
      settings.zookeeper.groups = new_groups
      restart_haproxy #if $zookeeper.valid?
      {"status" => "success"}.to_json
    end

    def restart_haproxy
      settings.haproxy.update_endpoints(settings.marathon.endpoints)
      settings.haproxy.update_groups(settings.zookeeper.groups)
      settings.haproxy.write_config
      settings.haproxy.safe_reload
    end
  end
end
