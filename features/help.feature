Feature: Command output from help command
  service-manager should return the correct output from its help commands

  Scenario: Boot and execute help commands
    When I successfully run `bundle exec vagrant service-manager --help`
    Then stdout from "bundle exec vagrant service-manager --help" should contain:
    """
    Usage: vagrant service-manager <command> [options]

    Commands:
         env          displays connection information for services in the box
         box          displays box related information like version, release, IP etc
         restart      restarts the given service in the box
         start        starts the given service in the box
         stop         stops the given service in the box
         status       list services and their running state
         install-cli  install the client binary for the specified service

    Options:
         -h, --help   print this help

    For help on any individual command run `vagrant service-manager COMMAND -h`
    """

    When I successfully run `bundle exec vagrant service-manager -h`
    Then stdout from "bundle exec vagrant service-manager -h" should contain:
    """
    Usage: vagrant service-manager <command> [options]

    Commands:
         env          displays connection information for services in the box
         box          displays box related information like version, release, IP etc
         restart      restarts the given service in the box
         start        starts the given service in the box
         stop         stops the given service in the box
         status       list services and their running state
         install-cli  install the client binary for the specified service

    Options:
         -h, --help   print this help

    For help on any individual command run `vagrant service-manager COMMAND -h`
    """

    When I run `bundle exec vagrant service-manager`
    Then the exit status should be 1
    And stdout from "bundle exec vagrant service-manager -h" should contain:
    """
    Usage: vagrant service-manager <command> [options]

    Commands:
         env          displays connection information for services in the box
         box          displays box related information like version, release, IP etc
         restart      restarts the given service in the box
         start        starts the given service in the box
         stop         stops the given service in the box
         status       list services and their running state
         install-cli  install the client binary for the specified service

    Options:
         -h, --help   print this help

    For help on any individual command run `vagrant service-manager COMMAND -h`
    """


