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
#MARATHON Application Endpoints

frontend recommender-1-1-1
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:10522
   default_backend recommender-1-1-1

backend recommender-1-1-1
  mode http
  option httpchk GET /
  balance leastconn
  server recommender-1.1.1-0 ip-10-30-6-115.us-west-1.compute.internal:31525 check

frontend hello-scala
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:10487
   default_backend hello-scala

backend hello-scala
  mode http
  option httpchk GET /
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check
EOF
  end

  def test_name_based_frontend
    endpoints = [
      {"name"=>"recommender-1.1.1", "port"=>10522, "servers"=>["ip-10-30-6-115.us-west-1.compute.internal:31525"]},
      {"name"=>"hello-scala", "port"=>10487, "servers"=>["ip-10-30-6-115.us-west-1.compute.iternal:31480", "ip-10-30-6-180.us-west-1.compute.internal:31304"]}
    ]
    haproxy = Mesoshub::Haproxy.new
    haproxy.update_endpoints(endpoints)
    name_based_frontend = haproxy.send(:name_based_frontend)
    assert_equal name_based_frontend, <<-EOF
# NAME BASED FRONTEND
frontend name_based
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:80
   default_backend webui
   acl is_group_recommender-1-1-1 hdr_beg(host) -i recommender-1-1-1.
   use_backend recommender-1-1-1 if is_group_recommender-1-1-1
   acl is_group_hello-scala hdr_beg(host) -i hello-scala.
   use_backend hello-scala if is_group_hello-scala
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
#MESOSHUB Application Groups
frontend demo
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:50001
   default_backend demo

backend demo
  mode http
  option httpchk GET /
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check weight 1
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check weight 1

frontend recommender
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:50000
   default_backend recommender

backend recommender
  mode http
  option httpchk GET /
  balance leastconn
  server recommender-1.1.1-0 ip-10-30-6-115.us-west-1.compute.internal:31525 check weight 1

backend webui
  mode http
  server webui localhost:1337
EOF
  end

  def test_name_based_frontend_with_groups
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
    name_based_frontend = haproxy.send(:name_based_frontend)
    assert_equal name_based_frontend, <<-EOF
# NAME BASED FRONTEND
frontend name_based
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:80
   default_backend webui
   acl is_group_demo hdr_beg(host) -i demo.
   use_backend demo if is_group_demo
   acl is_group_recommender hdr_beg(host) -i recommender.
   use_backend recommender if is_group_recommender
   acl is_group_recommender-1-1-1 hdr_beg(host) -i recommender-1-1-1.
   use_backend recommender-1-1-1 if is_group_recommender-1-1-1
   acl is_group_hello-scala hdr_beg(host) -i hello-scala.
   use_backend hello-scala if is_group_hello-scala
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
#MESOSHUB Application Groups
frontend demo
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:50001
   default_backend demo

backend demo
  mode http
  option httpchk GET /
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check weight 1
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check weight 1

frontend recommender
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:50000
   default_backend recommender

backend recommender
  mode http
  option httpchk GET /
  balance leastconn
  server recommender-1.1.1-0 ip-10-30-6-115.us-west-1.compute.internal:31525 check weight 1

backend webui
  mode http
  server webui localhost:1337
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
#MESOSHUB Application Groups
frontend demo
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:50001
   default_backend demo

backend demo
  mode http
  option httpchk GET /
  balance leastconn
  server hello-scala-0 ip-10-30-6-115.us-west-1.compute.iternal:31480 check weight 1
  server hello-scala-1 ip-10-30-6-180.us-west-1.compute.internal:31304 check weight 1

backend webui
  mode http
  server webui localhost:1337
EOF
  end

  def test_name_based_frontend_with_groups_when_endpoint_nonexistent
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
    name_based_frontend = haproxy.send(:name_based_frontend)
    assert_equal name_based_frontend, <<-EOF
# NAME BASED FRONTEND
frontend name_based
   mode http
   option httpclose
   option httplog
   bind 0.0.0.0:80
   default_backend webui
   acl is_group_demo hdr_beg(host) -i demo.
   use_backend demo if is_group_demo
   acl is_group_recommender-1-1-1 hdr_beg(host) -i recommender-1-1-1.
   use_backend recommender-1-1-1 if is_group_recommender-1-1-1
   acl is_group_hello-scala hdr_beg(host) -i hello-scala.
   use_backend hello-scala if is_group_hello-scala
EOF
  end

end
