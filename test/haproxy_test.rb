require "minitest/autorun"
require "mocha/setup"
require_relative "../lib/mesoshub"

class HaproxyTest < MiniTest::Unit::TestCase
  def setup
    @haproxy = Mesoshub::Haproxy.new
  end

  def test_endpoints_listen_apps
    endpoints = [
      {"name"=>"recommender-1.1.1", "port"=>10522, "servers"=>["ip-10-30-6-115.us-west-1.compute.internal:31525"]},
      {"name"=>"hello-scala", "port"=>10487, "servers"=>["ip-10-30-6-115.us-west-1.compute.iternal:31480", "ip-10-30-6-180.us-west-1.compute.internal:31304"]}
    ]
    haproxy = Mesoshub::Haproxy.new
    haproxy.update_endpoints(endpoints)
    listen_apps = haproxy.send(:listen_apps)
    assert_equal listen_apps, <<-EOF
#MESOS Applications
listen recommender-1.1.1
  bind 0.0.0.0:10522
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server recommender-1.1.1-0 ip-10-30-6-115.us-west-1.compute.internal:31525 check
listen hello-scala
  bind 0.0.0.0:10487
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check
EOF
  end

  def test_endpoints_and_groups_listen_groups
    endpoints = [
      {"name"=>"recommender-1.1.1", "port"=>10522, "servers"=>["ip-10-30-6-115.us-west-1.compute.internal:31525"]},
      {"name"=>"hello-scala", "port"=>10487, "servers"=>["ip-10-30-6-115.us-west-1.compute.iternal:31480", "ip-10-30-6-180.us-west-1.compute.internal:31304"]}
    ]
    groups = [
      {"name"=>"demo", "port"=>50001, "apps"=>["hello-scala"]},
      {"name"=>"recommender", "port"=>50000, "apps"=>["recommender-1.1.1"]}
    ]
    haproxy = Mesoshub::Haproxy.new
    haproxy.update_endpoints(endpoints)
    haproxy.update_groups(groups)
    listen_groups = haproxy.send(:listen_groups)
    assert_equal listen_groups, <<-EOF
#MESOS Application Groups
listen demo
  bind 0.0.0.0:50001
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check weight 1
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check weight 1
listen recommender
  bind 0.0.0.0:50000
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server recommender-1.1.1-0 ip-10-30-6-115.us-west-1.compute.internal:31525 check weight 1
EOF
  end

  def test_endpoints_and_groups_listen_groups_when_endpoint_gone
    endpoints = [
      {"name"=>"recommender-1.1.1", "port"=>10522, "servers"=>["ip-10-30-6-115.us-west-1.compute.internal:31525"]},
      {"name"=>"hello-scala", "port"=>10487, "servers"=>["ip-10-30-6-115.us-west-1.compute.iternal:31480", "ip-10-30-6-180.us-west-1.compute.internal:31304"]}
    ]
    groups = [
      {"name"=>"demo", "port"=>50001, "apps"=>["hello-scala"]},
      {"name"=>"recommender", "port"=>50000, "apps"=>["recommender-1.1.1", "GONE"]}
    ]
    haproxy = Mesoshub::Haproxy.new
    haproxy.update_endpoints(endpoints)
    haproxy.update_groups(groups)
    listen_groups = haproxy.send(:listen_groups)
    assert_equal listen_groups, <<-EOF
#MESOS Application Groups
listen demo
  bind 0.0.0.0:50001
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check weight 1
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check weight 1
listen recommender
  bind 0.0.0.0:50000
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server recommender-1.1.1-0 ip-10-30-6-115.us-west-1.compute.internal:31525 check weight 1
EOF
  end

  def test_endpoints_and_groups_listen_groups_when_endpoint_nonexistent
    endpoints = [
      {"name"=>"recommender-1.1.1", "port"=>10522, "servers"=>["ip-10-30-6-115.us-west-1.compute.internal:31525"]},
      {"name"=>"hello-scala", "port"=>10487, "servers"=>["ip-10-30-6-115.us-west-1.compute.iternal:31480", "ip-10-30-6-180.us-west-1.compute.internal:31304"]}
    ]
    groups = [
      {"name"=>"demo", "port"=>50001, "apps"=>["hello-scala"]},
      {"name"=>"recommender", "port"=>50000, "apps"=>["NONEXISTENT"]}
    ]
    haproxy = Mesoshub::Haproxy.new
    haproxy.update_endpoints(endpoints)
    haproxy.update_groups(groups)
    listen_groups = haproxy.send(:listen_groups)
    assert_equal listen_groups, <<-EOF
#MESOS Application Groups
listen demo
  bind 0.0.0.0:50001
  mode http
  option tcplog
  option httpchk GET /check
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check weight 1
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check weight 1
EOF
  end

  def test_write_config_raises_exception
    assert_raises RuntimeError do
      @haproxy.write_config
    end
  end

end
