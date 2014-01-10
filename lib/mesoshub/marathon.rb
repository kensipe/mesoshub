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
        ep = open(endpoints_url).read
      rescue Exception => e
        puts "Retrying..."
        sleep 1
        retry unless (tries -= 1).zero?
      end
      endpoints = ep.split("\n").reduce({}) do |acum, item|
        parts = item.split(" ")
        acum[parts[0]] = { "port" => parts[1], "servers" => parts[2..-1]}
        acum
      end
      endpoints
    end

  end
end

