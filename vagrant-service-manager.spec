# Generated from vagrant-service-manager-0.0.4.gem by gem2rpm -*- rpm-spec -*-
%global vagrant_plugin_name vagrant-service-manager

Name: %{vagrant_plugin_name}
Version: 0.0.2
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

%changelog
* Tue Feb 17 2016 Navid Shaikh - 0.0.2-1
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

* Thu Feb 09 2016 Navid Shaikh - 0.0.1-1
- Initial build
