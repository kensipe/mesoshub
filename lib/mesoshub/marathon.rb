module Mesoshub
  class Marathon

    def initialize(marathon_url)
      @marathon_url = marathon_url
    end

    def endpoints_url
      "%s/v1/endpoints" % @marathon_url
    end

    def endpoints
      #TODO RESCUE
      #SocketError: getaddrinfo: nodename nor servname provided, or not known
      #OpenURI::HTTPError: 404 Not Found
      begin
        tries ||=3
        response = open(endpoints_url, "Accept" => "application/json").read
      rescue Exception => e
        puts "Retrying..."
        sleep 1
        retry unless (tries -= 1).zero?
      end
      #TODO this mapping is temporary for marathon-0.3.0 that include ports as an array.
      #
      #[{
      #   "id": "recommender-1.1.1",
      #   "instances": [{
      #     "host": "ip-10-30-6-115.us-west-1.compute.internal",
      #     "id": "recommender-1.1.1_0-1389916787578",
      #     "ports": [ 31525 ]
      #   }],
      #   "ports": [10522]
      #}]
      ep = response.size > 0 ? JSON.load(response) : []
      endpoints = ep.map do |endpoint|
        servers = endpoint["instances"].reduce([]) do |acum, server|
          host_port = "%s:%s" % [ server["host"], server["ports"][0] ]
          acum.push( host_port)
          acum
        end
        {"name" => endpoint["id"], "port" => endpoint["ports"][0], "servers" => servers}
      end
      endpoints
    end

  end
end

