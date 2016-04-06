# Generated from vagrant-service-manager-0.0.4.gem by gem2rpm -*- rpm-spec -*-
%global vagrant_plugin_name vagrant-service-manager

Name: %{vagrant_plugin_name}
Version: 1.0.0
Release: 1%{?dist}
Summary: To provide the user a CLI to configure the ADB/CDK for different use cases and to provide glue between ADB/CDK and the user's developer environment.
Group: Development/Languages
License: GPLv2
URL: https://github.com/bexelbie/vagrant-service-manager
Source0: https://rubygems.org/gems/%{vagrant_plugin_name}-%{version}.gem
Requires(posttrans): vagrant
Requires(preun): vagrant
Requires: vagrant
BuildRequires: ruby(release)
BuildRequires: rubygems-devel >= 1.3.6
BuildRequires: ruby
BuildRequires: vagrant
BuildArch: noarch
Provides: vagrant(%{vagrant_plugin_name}) = %{version}

%description
To provide the user a CLI to configure the ADB/CDK for different use cases and to provide glue between ADB/CDK and the user's developer environment.

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
gem unpack %{SOURCE0}

%setup -q -D -T -n  %{vagrant_plugin_name}-%{version}

gem spec %{SOURCE0} -l --ruby > %{vagrant_plugin_name}.gemspec

%build
# Create the gem as gem install only works on a gem file
gem build %{vagrant_plugin_name}.gemspec

# %%vagrant_plugin_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%vagrant_plugin_install

%install
mkdir -p %{buildroot}%{vagrant_plugin_dir}
cp -a .%{vagrant_plugin_dir}/* \
        %{buildroot}%{vagrant_plugin_dir}/

# Run the test suite
%check
pushd .%{vagrant_plugin_instdir}

popd

%posttrans
%vagrant_plugin_register %{vagrant_plugin_name}

%preun
%vagrant_plugin_unregister %{vagrant_plugin_name}

%files
%dir %{vagrant_plugin_instdir}
%exclude %{vagrant_plugin_instdir}/.gitignore
%{vagrant_plugin_libdir}
%exclude %{vagrant_plugin_cache}
%{vagrant_plugin_spec}
%{vagrant_plugin_instdir}/plugins/guests/
%{vagrant_plugin_instdir}/locales/

%files doc
%doc %{vagrant_plugin_docdir}
%{vagrant_plugin_instdir}/Gemfile
%doc %{vagrant_plugin_instdir}/README.md
%{vagrant_plugin_instdir}/Rakefile
%{vagrant_plugin_instdir}/Vagrantfile
%{vagrant_plugin_instdir}/CONTRIBUTING.md
%{vagrant_plugin_instdir}/LICENSE
%{vagrant_plugin_instdir}/MAINTAINERS
%{vagrant_plugin_instdir}/vagrant-service-manager.gemspec
%{vagrant_plugin_instdir}/vagrant-service-manager.spec
%{vagrant_plugin_instdir}/CHANGELOG.md
%{vagrant_plugin_instdir}/TODO
%{vagrant_plugin_instdir}/.gitattributes

%changelog
* Tue Mar 29 2016 Navid Shaikh - 1.0.0-1
- Bumps the plugin version to 1.0.0
- Fix #132: vagrant-service-manager 1.0.0 release @navidshaikh
- Fix #133: Adds restart command for services @navidshaikh
- Fix #152: Makes plugin backward compatible with docker 1.8.2 for docker version API @navidshaikh
- Fix #150: Adds .gitattributes to fix the CHANGELOG.md merge conflicts @bexelbie
- Fix #142: Removes # before human readable output of openshift env info @navidshaikh
- Fix #75 and #141: Improves `vagrant service-manager env` output @navidshaikh
- Fix#146: Updates docker 1.9.1 API call for `docker version` @navidshaikh
- Updating CONTRIBUTING with note about entry loc @bexelbie
- Update IP detection routine and fix for libvirt @bexelbie
- Fix #50: Add --help @budhrg
- Fix #89: Improve help output for service-manager -h @budhrg
- Vagrant way of showing information using 'locale' @budhrg
- cygwin eval hint now removes colors and env uses export @bexelbie
- Fix #131: Fixes starting OpenShift service by default for CDK box @navidshaikh

* Tue Mar 29 2016 Navid Shaikh - 0.0.5-1
- Fix #127: vagrant-service-manager 0.0.5 release @navidshaikh
- Fix #122: Certs copied at the time of generation @budhrg
- Fix #121: Removes DOCKER_MACHINE_NAME from `env docker` command output @navidshaikh
- Fix #65: Adds --script-readable option for `env openshift` command @navidshaikh
- Fix #80: Check for correct TLS certs pair @budhrg
- Fix #113: Adds DOCKER_API_VERSION in env docker output @navidshaikh
- Adds SPEC file version 0.0.4 of the plugin @navidshaikh

* Tue Mar 15 2016 Navid Shaikh - 0.0.4-1
- Fix #101: vagrant-service-manager version 0.0.4 release @navidshaikh
- Remove manually scp for TLS keys and use machine.communicate.download @bexelbie
- Fix #87 #83: Supports starting OpenShift service as part of config @budhrg @bexelbie @navidshaikh
- Fix #95: Update hook code to call other middleware first @bexelbie
- Fix #94: Do not exit if box is not supported @navidshaikh
- Fixed missing word for plugin installation in README @budhrg
- Fix links, typos, formatting in CONTRIBUTING.md @budhrg
- Fix #16 and #72: Enable private networking for VirtualBox if not set @budhrg

* Tue Mar 01 2016 Navid Shaikh - 0.0.3-1
- Fix #74: vagrant-service-manager plugin version 0.0.3 release @navidshaikh
- Fix #12 and #21: Restart docker service on 'vagrant up' @budhrg
- Update CONTRIBUTING.md and README.md @bexelbie
- Fix #45: Adds exit status for commands and invalid commands @navidshaikh
- Enhanced the developer instructions for developing the plugin in README @budhrg
- Updated box versioning info @budhrg
- Fix #45: Adds exit status for commands and invalid commands @navidshaikh
- Renames the option machine-readable to script-readable @navidshaikh
- Fix #63: Adds --machine-readable option to box version command @navidshaikh
- Fix #66: Fixing gem build warning @lalatendumohanty
- Adds the filename as class constant @navidshaikh
- Fix #8: Adds subcommand for printing box version
- Fix #59: Prints the error message on stderr @navidshaikh
- Updates openshift connection information output @navidshaikh
- Extends help command with openshift example @navidshaikh
- Adds method to find if a service is running @navidshaikh
- Fix #23: Adds subcommand for displaying openshift information @navidshaikh
- Updates output docker info in README @navidshaikh

* Wed Feb 17 2016 Navid Shaikh - 0.0.2-1
- Bumps version to v0.0.2
- Fixed prompting for bringing machine up for help command
- Adds Lalatendu Mohanty as maintainer
- Fixed check for finding vagrant box state
- Adds version.rb to fetch the version of plugin
- Adds steps to build the plugin using bundler
- Updates README with quick start steps
- Fixed issue for private key not being sourced for libvirt provider
- Add notice when copying certificates
- `vagrant service-manager env` returns all info
- Adds running machine detection in plugin for better error reporting
- Updates README with objective
- Updates README with gemfile and copr builds
- Added SPEC file to the git repository of plugin

* Tue Feb 09 2016 Navid Shaikh - 0.0.1-1
- Initial build
