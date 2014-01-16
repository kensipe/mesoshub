module Mesoshub
  class Zookeeper

    def initialize(zookeeper_hosts="localhost:2181")
      @zk = ZK.new(zookeeper_hosts)
      @zk.create("/mesoshub") unless @zk.exists?("/mesoshub")
      @zk.create("/mesoshub/groups") unless @zk.exists?("/mesoshub/groups")
    end

    def groups
      groups =  @zk.children("/mesoshub/groups").reduce([]) do |acum, group|
        begin
          payload = @zk.get("/mesoshub/groups/#{group}")
        rescue ZK::Exceptions::NoNode
          next
        end
        if payload && payload.kind_of?(Array) && !payload[0].nil?
          acum.push(JSON.load(@zk.get("/mesoshub/groups/#{group}")[0]))
        end
        acum
      end
    end

    def groups=(groups)
      #raise unless is_valid(groups)
      existing_groups = @zk.children("/mesoshub/groups")
      deleted_groups = existing_groups - groups.map{|x| x["name"]}
      deleted_groups.each do |group|
        @zk.delete("/mesoshub/groups/#{group}")
      end
      groups.map do |group|
        key = "/mesoshub/groups/%s" % group["name"]
        payload = JSON.dump(group)
        if @zk.exists?(key)
          @zk.set(key, payload)
        else
          @zk.create(key, payload)
        end
      end
    end

  end
end
