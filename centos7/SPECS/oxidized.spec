%define pgroup oxidized
%define puser oxidized

Name: oxidized
Summary: Oxidized Network Configuration Management
Version: 0.26.3
License: ASL 2.0
Release: 1
BuildRoot:%{_tmppath}/${name}-root
Source0:oxidized-%{version}.tar.gz
Requires: libicu,openssl,readline,gdbm

%description
Oxidized Network Configuration Management

%clean
rm -rf %{buildroot}

%pre
getent group %{pgroup} >/dev/null || groupadd -r %{pgroup}
getent passwd %{puser} >/dev/null || /usr/sbin/useradd --shell /bin/false -m -r -g %{pgroup} %{puser}

%prep

%setup

%build

%install
cp -rv %{_builddir}/oxidized-%{version}/* %{buildroot}/

%post

%files
%defattr(-,%{puser},%{pgroup})
/opt/oxidized/*
/usr/lib/systemd/system/oxidized.service
