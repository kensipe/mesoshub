module Mesoshub
  class Marathon

    DEFAULT_HEALTH_PATH = "/"
    DEFAULT_PORT_INDEX = 0

    def initialize(marathon_url)
      @marathon_url = marathon_url
    end

    def apps_url
      "%s/v2/apps" % @marathon_url
    end

    def tasks_url
      "%s/v2/tasks" % @marathon_url
    end

    def endpoints
      response = open_with_retry(tasks_url)
      tasks = (response.nil? || response.size == 0) ? [] : JSON.load(response)["tasks"]
      servers = tasks.reduce({}) do |acum, task|
        host_port = "%s:%s" % [task["host"], task["ports"][DEFAULT_PORT_INDEX]]
        acum[task["appId"]] ||= []
        acum[task["appId"]].push(host_port)
        acum
      end

      response = open_with_retry(apps_url)
      apps = (response.nil? || response.size == 0) ? [] : JSON.load(response)["apps"]
      endpoints = apps.map do |app|
        health_path = app["healthChecks"].empty? ? DEFAULT_HEALTH_PATH : app["healthChecks"].reduce(DEFAULT_HEALTH_PATH)  {|acum,item| acum = item["path"] if item["protocol"]=="HTTP"; acum}
        app_port = app["ports"][DEFAULT_PORT_INDEX]
        srvs = servers[app["id"]].nil? ? [] : servers[app["id"]]
        safe_app_id = safe_chars(app["id"])
        {"name" => safe_app_id, "health_path" => health_path, "port" => app_port, "servers" => srvs}
      end

     endpoints
    end

    private

      # converts /something => something
      # converts a/b/c/app =>  a-b-c-app
      def safe_chars(name)
        newname = name[0] == "/" ? name[1..-1] : name
        newname.gsub("/", "-")
      end

      def open_with_retry(url)
        #TODO RESCUE
        #SocketError: getaddrinfo: nodename nor servname provided, or not known
        #OpenURI::HTTPError: 404 Not Found
        begin
          tries ||=3
          response = open(url, "Accept" => "application/json").read
        rescue Exception => e
          puts "Retrying..."
          puts e.inspect
          sleep 1
          retry unless (tries -= 1).zero?
        end
      end

  end
end

