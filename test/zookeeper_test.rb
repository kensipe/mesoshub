require "minitest/autorun"
require "mocha/setup"
require_relative "../lib/mesoshub"

class ZookeeperTest < MiniTest::Unit::TestCase

  class Mock
  end

  def setup
    def ZK.new(*args);  Mock.new; end
    Mock.any_instance.stubs("exists?").with("/mesoshub").returns true
    Mock.any_instance.stubs("exists?").with("/mesoshub/groups").returns true
    @zookeeper = Mesoshub::Zookeeper.new
  end

  def test_groups_empty
    Mock.any_instance.stubs(:children).returns([])
    assert_equal @zookeeper.groups, []
  end

  def test_groups_success
    Mock.any_instance.stubs(:children).returns(["search_api"])
    Mock.any_instance.stubs(:get).with("/mesoshub/groups/search_api").returns([JSON.dump({"a" => 1}), "somethingelse"])
    assert_equal @zookeeper.groups, [{"a" => 1}]
  end

  def test_groups_keys_with_empty_key
    Mock.any_instance.stubs(:children).returns(["01","02"])
    Mock.any_instance.stubs(:get).with("/mesoshub/groups/01").returns(nil)
    Mock.any_instance.stubs(:get).with("/mesoshub/groups/02").returns([JSON.dump({"a" => 1}), "something"])
    assert_equal @zookeeper.groups, [{"a" => 1}]
  end

  def test_groups_setter_none_existing
    new_groups = [
      {"name" => "01", "a" => 1},
      {"name" => "02", "b" => 1}
    ]
    Mock.any_instance.stubs(:children).returns([])
    Mock.any_instance.stubs("exists?").returns(false)
    Mock.any_instance.expects(:create).with("/mesoshub/groups/01", JSON.dump({"name" => "01", "a" => 1}))
    Mock.any_instance.expects(:create).with("/mesoshub/groups/02", JSON.dump({"name" => "02", "b" => 1}))
    @zookeeper.groups=new_groups
  end

  def test_groups_setter_one_existing
    new_groups = [
      {"name" => "01", "a" => 1},
      {"name" => "02", "b" => 1}
    ]
    Mock.any_instance.stubs(:children).returns(["01"])
    Mock.any_instance.stubs("exists?").with("/mesoshub/groups/01").returns(true)
    Mock.any_instance.stubs("exists?").with("/mesoshub/groups/02").returns(false)
    Mock.any_instance.expects(:set).with("/mesoshub/groups/01",    JSON.dump({"name" => "01", "a" => 1}))
    Mock.any_instance.expects(:create).with("/mesoshub/groups/02", JSON.dump({"name" => "02", "b" => 1}))
    @zookeeper.groups=new_groups
  end

  def test_groups_setter_delete_update
    new_groups = [
      {"name" => "01", "a" => 1}
    ]
    Mock.any_instance.stubs(:children).returns(["01", "03"])
    Mock.any_instance.expects(:delete).with("/mesoshub/groups/03")
    Mock.any_instance.stubs("exists?").with("/mesoshub/groups/01").returns(true)
    Mock.any_instance.expects(:set).with("/mesoshub/groups/01", JSON.dump({"name" => "01", "a"=>1}))
    @zookeeper.groups=new_groups
  end

  def test_groups_setter_delete_create
    new_groups = [
      {"name" => "04", "a" => 1}
    ]
    Mock.any_instance.stubs(:children).returns(["03"])
    Mock.any_instance.expects(:delete).with("/mesoshub/groups/03")
    Mock.any_instance.stubs("exists?").returns(false)
    Mock.any_instance.expects(:create).with("/mesoshub/groups/04", JSON.dump({"name"=>"04", "a"=>1}))
    @zookeeper.groups=new_groups
  end



end
