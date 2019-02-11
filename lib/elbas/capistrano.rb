require 'capistrano/dsl'

load File.expand_path("../tasks/elbas.rake", __FILE__)

def autoscale(groupname, *args)
  include Capistrano::DSL
  include Elbas::Logger

  set :aws_autoscale_group_name, groupname

  asg = Elbas::AWS::AutoscaleGroup.new groupname
  instances = asg.instances.running

  instances.each do |instance|
    info "Adding server: #{instance.hostname}"
    server instance.hostname, *args
  end

  if instances.any?
    after 'deploy', 'elbas:deploy'
  else
    error <<~MESSAGE
      Could not create AMI because no running instances were found in the specified
      AutoScale group. Ensure that the AutoScale group name is correct and that
      there is at least one running instance attached to it.
    MESSAGE
  end
end
