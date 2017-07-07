# author: Andrew Bruce

class OpenStackConnection
  def initialize
    require 'openstack'

    # TODO: extract from config somewhere??
    os_auth_url = ENV['OS_AUTH_URL'],
    os_domain_name = ENV['OS_DOMAIN_NAME'],
    os_identity_api_version = ENV['OS_IDENTITY_API_VERSION'],
    os_image_api_version = ENV['OS_IMAGE_API_VERSION'],
    os_password = ENV['OS_PASSWORD'],
    os_project_domain_name = ENV['OS_PROJECT_DOMAIN_NAME'],
    os_project_name = ENV['OS_PROJECT_NAME'],
    os_region_name = ENV['OS_REGION_NAME'],
    os_tenant_name = ENV['OS_TENANT_NAME'],
    os_username = ENV['OS_USERNAME'],
    os_user_domain_name = ENV['OS_USER_DOMAIN_NAME'],
    os_version = ENV['OS_VERSION'],
    os_volume_api_version = ENV['OS_VOLUME_API_VERSION']

    # assign to OpenStack options
    @opts = {
      api_key: os_password,
      auth_method: 'password',
      authtenant_name: os_tenant_name,
      auth_url: os_auth_url,
      username: os_username,
      user_domain: os_user_domain_name,
      project_name: os_project_name,
      project_domain_name: os_project_domain_name,
      region: os_region_name
    }
  end

  private def create_connection(service_type)
    the_opts = @opts.clone
    the_opts[:service_type] = service_type
    @createOpenStack::Connection.create(the_opts)
  end
  
  def compute_client
    @compute_client ||= create_connection('compute')
  end
end

