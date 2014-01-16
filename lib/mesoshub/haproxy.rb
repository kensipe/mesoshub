module Mesoshub
  class Haproxy
    attr_accessor :endpoints, :endpoints_lookup, :groups

    def update_endpoints(endpoints)
      @endpoints = endpoints
      @endpoints_lookup = endpoints.reduce({}) do |acum, ep|
        acum[ep["name"]] = {"port" => ep["port"], "servers" => ep["servers"]}
        acum
      end
    end

    def update_groups(groups)
      @groups = groups
    end

    def write_config
      raise "add endpoints or groups first" if @endpoints.nil? && @groups.nil?
      system("cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.old")
      File.open("/etc/haproxy/haproxy.cfg", "w") do |file|
        file << generate_config
      end
    end

    def safe_reload
      system("/etc/init.d/haproxy reload")
      # if something goes wrong, cp /etc/haproxy/haproxy.cfg.old and restart
      # airbnb's synapse
      # res = `#{opts['reload_command']}`.chomp
      # raise "failed to reload haproxy via #{opts['reload_command']}: #{res}" unless $?.success?
      #system("sudo /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)")
    end

    private
    def generate_config
      configuration = [defaults, listen_defaults, listen_groups, listen_apps].join("\n\n")
      configuration
    end

    def defaults
      return <<EOF
global
  daemon
  spread-checks 2
  user    ubuntu
  group   ubuntu
  maxconn 8192
  log     127.0.0.1 local1
  stats   socket /var/run/haproxy.sock group ubuntu mode 660 level admin

defaults
  log      global
  option   dontlognull
  option   log-separate-errors
  option   httpchk
  option   abortonclose
  maxconn  2000
  timeout  connect 5s
  timeout  check   5s
  timeout  client  50s
  timeout  server  50s
  option   redispatch
  retries  3
  balance  roundrobin
EOF
    end

    def listen_defaults
      return <<EOF
#DEFAULT APPS
listen webui
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:80
   server webui localhost:8080 check weight 80

listen stats
  bind 0.0.0.0:9999
  balance
  mode http
  stats enable
  stats auth admin:admin
EOF
    end

    def listen_groups
      output = groups.each.reduce("#MESOS Application Groups\n") do |acum, group|
        #does the endpoint app exist?
        if group["apps"].reject{|g| endpoints_lookup[g]}.size < group["apps"].size
          acum += <<"EOF"
listen #{group["name"]}
  bind 0.0.0.0:#{group["port"]}
  mode http
  option tcplog
  option httpchk GET /
  balance leastconn
EOF
          i = 0
          group["apps"].each do |name|
            if endpoints_lookup[name]
              acum += endpoints_lookup[name]["servers"].reduce("") do |a, server|
                a += "  server #{name}-#{i} #{server} check weight 1\n"
                i += 1
                a
              end
            end
          end
        end
        acum
      end
      output
    end

    def listen_apps
      output = endpoints.each.reduce("#MESOS Applications\n") do |acum, endpoint|
         acum += <<"EOF"
listen #{endpoint["name"]}
  bind 0.0.0.0:#{endpoint["port"]}
  mode http
  option tcplog
  option httpchk GET /
  balance leastconn
EOF
         i = 0
         acum += endpoint["servers"].reduce("") do |a, server|
           a += "  server #{endpoint["name"]}-#{i} #{server} check \n"
           i += 1
           a
         end
         acum
       end
       output
    end

  end
end
