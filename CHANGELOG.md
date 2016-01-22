# Changelog

## v0.1.0 Jan 19, 2015

- Fix#66: Added CHANGELOG.md to repository @navidshaikh
- Added gemspec in Gemfile to enable bundler packaging @lalatendumohanty
- Fix#67: OS is not a module (TypeError) on Windows @budhrg
- Update ADB box Atlas namespace to projectatomic/adb @lalatendumohanty
- Update README to reflect latest code and project goals @bexelbie
- Update Vagrantfile for QuickStart guide @navidshaikh


## v0.0.9 Nov 25, 2015

- Fix: Prevents TLS certs generation on every run of plugin @navidshaikh


## v0.0.8  Nov 24, 2015

- Fix#40: Handle private networking for different providers and generate Docker daemon TLS certs accordingly
- Support backward compatibility with older versions of ADB boxes
- lib/command.rb - Fixes bash file check command
- Restart Docker daemon after generating correct TLS certs

@navidshaikh @bexelbie

## v0.0.7 Nov 24, 2015

- Add RPM SPEC file
- Fix docker certificate regeneration to only happen for new ADB installs and VirtualBox (because of late DHCP on second adapter)

@navidshaikh @bexelbie

## v0.0.6 Nov 20, 2015

The important part of this release is finding the IP address of the guest provisioned via private networking and display the docker daemon connection information with private network IP

- Find IP address of the guest provisioned via private networking
- Fixed typo in eval command of adbinfo output
- Added License, Contributing and Maintainers files
- Added Quick Start and Contact us sections

@navidshaikh @bexelbie

## v0.0.5 Nov 17, 2015

This release is mostly focused on fixing the adbinfo output for Windows platform, with following two particular fixes

- Adds correct command to export the environment variables for Windows platform
- Adds instruction to evaluate the env vars from adbinfo output

@navidshaikh

## v0.0.4 Nov 9, 2015

- Cleanup scp and ssh commands
- Identify ssh to use based on host OS
- Fixes for Windows and pscp

@navidshaikh @bexelbie

## v0.0.3 Sep 15, 2015

Fix syntax error in outpu

@navidshaikh @bexelbie

## v0.0.2 Sep 15, 2015

- Fix #5 - docker machine name in output
- Client Cert is now copied to workstation and CERT_PATH is set

@navidshaikh @bexelbie

## v0.0.1 Sep 11, 2015

Initial Release

@navidshaikh @bexelbie
