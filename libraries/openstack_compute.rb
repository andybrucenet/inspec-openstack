# author: Andrew Bruce

class OpenStackCompute < Inspec.resource(1)
  name 'openstack_compute'
  desc 'Verifies settings for an OpenStack instance'

  example "
    describe openstack_compute('966b6b65-ca18-4b70-81b1-347db5188199') do
      it { should be_running }
    end

    describe openstack_compute(name: 'my-instance') do
      it { should be_running }
    end
  "

  def initialize(opts, conn = OpenStackConnection.new)
    @opts = opts
    @opts.is_a?(Hash) ? @display_name = @opts[:name] : @display_name = opts
    @client = conn.compute_client
  end

  def id
    return @instance_id if defined?(@instance_id)
    if @opts.is_a?(Hash)
      first = @client.servers( :name => @opts[:name] ).first
      # catch case where the instance is not known
      @instance_id = first.id unless first.nil?
    else
      @instance_id = @opts
    end
  end
  alias instance_id id

  def exists?
    instance.exists?
  end

  # returns the instance state
  def state
    instance.state.name if instance
  end

  # helper methods for each state
  %w{
    pending running shutting-down
    terminated stopping stopped unknown
  }.each do |state_name|
    define_method state_name.tr('-', '_') + '?' do
      state == state_name
    end
  end

  # attributes that we want to expose
  %w{
    public_ip_address private_ip_address key_name private_dns_name
    public_dns_name subnet_id architecture root_device_type
    root_device_name virtualization_type client_token launch_time
    instance_type image_id vpc_id
  }.each do |attribute|
    define_method attribute do
      instance.send(attribute)
    end
  end

  def security_groups
    @security_groups ||= instance.security_groups.map { |sg|
      { id: sg.group_id, name: sg.group_name }
    }
  end

  def tags
    @tags ||= instance.tags.map { |tag| { key: tag.key, value: tag.value } }
  end

  def to_s
    "OpenStack Instance #{@display_name}"
  end

  private

  def instance
    @instance ||= @client.get_server(id)
  end
end

