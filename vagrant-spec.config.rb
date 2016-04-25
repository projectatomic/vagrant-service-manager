Vagrant::Spec::Acceptance.configure do |c|
  errors = []
  errors << 'You need to specify the box location via the environment variable VAGRANT_SPEC_BOX' unless ENV.has_key?('VAGRANT_SPEC_BOX')

  unless errors.empty?
  	puts errors.join("\n")
  	abort
  end

  c.provider ENV['VAGRANT_SPEC_PROVIDER'], box: ENV['VAGRANT_SPEC_BOX']
  c.component_paths << 'vagrant-spec'
  c.skeleton_paths  << 'vagrant-spec/skeleton'
end
