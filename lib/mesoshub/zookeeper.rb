module Mesoshub
  class Zookeeper

    def initialize(zookeeper_hosts="localhost:2181")
      @zk = ZK.new(zookeeper_hosts)
      @zk.create("/mesoshub") unless @zk.exists?("/mesoshub")
      @zk.create("/mesoshub/app_groups") unless @zk.exists?("/mesoshub/app_groups")
    end

    def app_groups
      app_groups =  @zk.children("/mesoshub/app_groups").reduce({}) do |acum, group|
        begin
          payload = @zk.get("/mesoshub/app_groups/#{group}")
        rescue ZK::Exceptions::NoNode
          next
        end
        if payload && payload.kind_of?(Array) && !payload[0].nil?
          acum[group] = JSON.load(@zk.get("/mesoshub/app_groups/#{group}")[0])
        end
        acum
      end
    end

    def app_groups=(app_groups)
      existing_groups = @zk.children("/mesoshub/app_groups")
      deleted_groups = existing_groups - app_groups.keys
      deleted_groups.each do |group|
        @zk.delete("/mesoshub/app_groups/#{group}")
      end
      app_groups.keys.each do |group|
        key = "/mesoshub/app_groups/%s" % group
        payload = JSON.dump(app_groups[group])
        if @zk.exists?(key)
          @zk.set(key, payload)
        else
          @zk.create(key, payload)
        end
      end
    end


  end
end
