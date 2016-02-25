# Changelog

## v0.0.3 Feb 25, 2016
-
- Enhanced the developer instructions for developing the plugin in README @budhrg
- Fix #45: Adds exit status for commands and invalid commands @navidshaikh

## v0.0.2 Feb 17, 2016
- Fixes #53: Prep for version v0.0.2
- Fixes #41: Plugin reports to bring up machine for even help command @navidshaikh
- Updates CHANGELOG.md @navidshaikh
- Fix #41: Fixes the check for finding vagrant box state @navidshaikh
- Adding a version.rb @lalatendumohanty
- Adding steps to build the plugin using Bundler @lalatendumohanty
- Update README with quick start steps @navidshaikh
- Fixes #31: Private key wasn't being sourced for libvirt @bexelbie
- Add notice when copying certificates @bexelbie
- `vagrant service-manager env` return all info @bexelbie
- Fix #4 and #5: Add running machine detection @bexelbie
- Adding objective to the README @lalatendumohanty
- Adds links to gemfile and copr build @navidshaikh
- Adds SPEC file for version 0.0.1 release @navidshaikh

## v0.0.1 Feb 09, 2016
- Updates the source git repository URL
- Restructure the lib directory and sources plugin from module
- Removes unused vagrant password from repository
- Uses net/scp module instead of scp command
- Adds a sub-command for configuring docker daemon vagrant-service-manager env docker
- Ports equivalent functionality of plugin for https://github.com/projectatomic/vagrant-adbinfo
- Renames the plugin and update the rest of repository

@navidshaikh @bexelbie

## Plugin is forked and extended from [vagrant-adbinfo](https://github.com/projectatomic/vagrant-adbinfo)
