HELP_TEXT = <<-HELP
Usage: vagrant service-manager <command> [options]

Commands:
     env          displays connection information for services in the box
     box          displays box related information like version, release, IP etc
     restart      restarts the given systemd service in the box
     status       list services and their running state

Options:
     -h, --help   print this help

For help on any individual command run `vagrant service-manager COMMAND -h`
HELP

ENV_HELP_TEXT = <<-ENV_HELP
Usage: vagrant service-manager env [object] [options]

Objects:
      docker      display information and environment variables for docker
      openshift   display information and environment variables for openshift

If OBJECT is ommitted, display the information for all active services

Options:
      --script-readable  display information in a script readable format.
      -h, --help         print this help
ENV_HELP

###############################################################################
# Some helper functions
###############################################################################
# When running Vagrant from within a plugin development environment, Vagrant
# prints a warning which we can ignore
def stdout_without_plugin_context(raw_stdout)
  raw_stdout.lines.to_a[6..-1].join
end

def command_output_is_evalable(raw_stdout)
  console_out = stdout_without_plugin_context(raw_stdout)
  console_out.each_line do |line|
    expect(line).to match(/^#.*|^export [a-zA-Z_]+=.*$|^\n$/)
  end
end

def command_output_is_script_readable(raw_stdout)
  console_out = stdout_without_plugin_context(raw_stdout)
  console_out.each_line do |line|
    expect(line).to match(/^[a-zA-Z_]+=.*$/)
  end
end

###############################################################################
# Actual RSpec tests
###############################################################################
shared_examples "provider/cdk" do |provider, options|
  if !options[:box]
    raise ArgumentError,
      "box_basic option must be specified for provider: #{provider}"
  end

  include_context "acceptance"

  before do
    environment.skeleton("cdk")
    assert_execute("vagrant", "box", "add", "box", options[:box])
    assert_execute("vagrant", "up", "--provider=#{provider}")
  end

  after do
    assert_execute("vagrant", "destroy", "--force")
  end

  # We put all of this in a single RSpec test so that we can test all
  # the cases within a single VM rather than having to `vagrant up` many
  # times.
  it "verify cli output" do
    ###########################################################################
    # help
    ###########################################################################
    status("Test: 'service-manager env' prints env settings from all services")
    result = execute("vagrant", "service-manager", "env", "docker")
    expect(result).to exit_with(0)
    command_output_is_evalable(result.stdout)
    status("Test: service-manager with no arguments prints help")
    result = execute("vagrant", "service-manager")
    # TODO, why does this return an error code of 1!?
    expect(result).to exit_with(1)
    expect(stdout_without_plugin_context(result.stdout)).to eq(HELP_TEXT)

    ###########################################################################
    status("Test: 'service-manager -h' prints help")
    result = execute("vagrant", "service-manager", "-h")
    expect(result).to exit_with(0)
    expect(stdout_without_plugin_context(result.stdout)).to eq(HELP_TEXT)

    ###########################################################################
    status("Test: 'service-manager --help' prints help")
    result = execute("vagrant", "service-manager", "--help")
    expect(result).to exit_with(0)
    expect(stdout_without_plugin_context(result.stdout)).to eq(HELP_TEXT)

    ###########################################################################
    status("Test: service-manager with unkown option prints help")
    result = execute("vagrant", "service-manager", "--foo")
    expect(result).to exit_with(1)
    expect(stdout_without_plugin_context(result.stdout)).to eq(HELP_TEXT)

    ###########################################################################
    # env
    ###########################################################################
    status("Test: 'service-manager env docker -h' prints help")
    result = execute("vagrant", "service-manager", "env", "-h")
    expect(result).to exit_with(0)
    expect(stdout_without_plugin_context(result.stdout)).to eq(ENV_HELP_TEXT)

    ###########################################################################
    status("Test: 'service-manager env docker' prints evalable Docker settings")
    result = execute("vagrant", "service-manager", "env", "docker")
    expect(result).to exit_with(0)
    command_output_is_evalable(result.stdout)
    expect(result.stdout).to match(/^export DOCKER_HOST=tcp:\/\/10.10.2.2:2376/)
    expect(result.stdout).to match(/^export DOCKER_CERT_PATH=.*\/.vagrant\/machines\/default\/#{Regexp.quote(provider)}\/docker/)
    expect(result.stdout).to match(/^export DOCKER_TLS_VERIFY=1/)
    expect(result.stdout).to match(/^export DOCKER_API_VERSION=1.21/)
    expect(result.stdout).to match(/# eval "\$\(vagrant service-manager env docker\)"/)

    ###########################################################################
    status("Test: 'service-manager env docker --script-readable' prints script readable Docker settings")
    result = execute("vagrant", "service-manager", "env", "docker", "--script-readable")
    expect(result).to exit_with(0)
    command_output_is_script_readable(result.stdout)
    expect(result.stdout).to match(/^DOCKER_HOST=tcp:\/\/10.10.2.2:2376/)
    expect(result.stdout).to match(/^DOCKER_CERT_PATH=.*\/.vagrant\/machines\/default\/#{Regexp.quote(provider)}\/docker/)
    expect(result.stdout).to match(/^DOCKER_TLS_VERIFY=1/)
    expect(result.stdout).to match(/^DOCKER_API_VERSION=1.21/)

    ###########################################################################
    status("Test: 'service-manager env' prints env settings from all services")
    result = execute("vagrant", "service-manager", "env")
    expect(result).to exit_with(0)
    command_output_is_evalable(result.stdout)

    ###########################################################################
    status("Test: 'service-manager env' prints env settings from all services")
    result = execute("vagrant", "service-manager", "env")
    expect(result).to exit_with(0)
    command_output_is_evalable(result.stdout)

    ###########################################################################
    status("Test: 'service-manager env --script-readable' prints env settings from all services sprint readable")
    result = execute("vagrant", "service-manager", "env", "--script-readable")
    expect(result).to exit_with(0)
    command_output_is_script_readable(result.stdout)
  end
end
