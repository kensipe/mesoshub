require "minitest/autorun"
require "mocha/setup"
require_relative "../lib/mesoshub"

class TestZookeeper < Minitest::Unit::TestCase

  class Mock
  end

  def setup
    def ZK.new(*args);  Mock.new; end
    Mock.any_instance.stubs("exists?").with("/mesoshub").returns true
    Mock.any_instance.stubs("exists?").with("/mesoshub/app_groups").returns true
    @zookeeper = Mesoshub::Zookeeper.new
  end

  def test_app_groups_empty
    Mock.any_instance.stubs(:children).returns([])
    assert_equal @zookeeper.app_groups, {}
  end

  def test_app_groups_success
    Mock.any_instance.stubs(:children).returns(["search_api"])
    Mock.any_instance.stubs(:get).with("/mesoshub/app_groups/search_api").returns([JSON.dump({"a"=>1}), "somethingelse"])
    assert_equal @zookeeper.app_groups, {"search_api"=>{"a"=>1}}
  end

  def test_app_groups_keys_with_empty_key
    Mock.any_instance.stubs(:children).returns(["01","02"])
    Mock.any_instance.stubs(:get).with("/mesoshub/app_groups/01").returns(nil)
    Mock.any_instance.stubs(:get).with("/mesoshub/app_groups/02").returns([JSON.dump({"a"=>1}), "something"])
    assert_equal @zookeeper.app_groups, {"02" => {"a" => 1}}
  end

  def test_app_groups_setter_none_existing
    new_app_groups = {
      "01" => {"a" => 1},
      "02" => {"b" => 1}
    }
    Mock.any_instance.stubs(:children).returns([])
    Mock.any_instance.stubs("exists?").returns(false)
    Mock.any_instance.expects(:create).with("/mesoshub/app_groups/01", JSON.dump({"a"=>1}))
    Mock.any_instance.expects(:create).with("/mesoshub/app_groups/02", JSON.dump({"b"=>1}))
    @zookeeper.app_groups=new_app_groups
  end

  def test_app_groups_setter_one_existing
    new_app_groups = {
      "01" => {"a" => 1},
      "02" => {"b" => 1}
    }
    Mock.any_instance.stubs(:children).returns(["01"])
    Mock.any_instance.stubs("exists?").with("/mesoshub/app_groups/01").returns(true)
    Mock.any_instance.stubs("exists?").with("/mesoshub/app_groups/02").returns(false)
    Mock.any_instance.expects(:set).with("/mesoshub/app_groups/01", JSON.dump({"a"=>1}))
    Mock.any_instance.expects(:create).with("/mesoshub/app_groups/02", JSON.dump({"b"=>1}))
    @zookeeper.app_groups=new_app_groups
  end

  def test_app_groups_setter_delete_update
    new_app_groups = {
      "01" => {"a" => 1},
    }
    Mock.any_instance.stubs(:children).returns(["01", "03"])
    Mock.any_instance.expects(:delete).with("/mesoshub/app_groups/03")
    Mock.any_instance.stubs("exists?").with("/mesoshub/app_groups/01").returns(true)
    Mock.any_instance.expects(:set).with("/mesoshub/app_groups/01", JSON.dump({"a"=>1}))
    @zookeeper.app_groups=new_app_groups
  end

  def test_app_groups_setter_delete_create
    new_app_groups = {
      "04" => {"a" => 1},
    }
    Mock.any_instance.stubs(:children).returns(["03"])
    Mock.any_instance.expects(:delete).with("/mesoshub/app_groups/03")
    Mock.any_instance.stubs("exists?").returns(false)
    Mock.any_instance.expects(:create).with("/mesoshub/app_groups/04", JSON.dump({"a"=>1}))
    @zookeeper.app_groups=new_app_groups
  end



end
