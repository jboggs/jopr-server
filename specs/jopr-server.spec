%define	pbuild	%{_builddir}/%{name}-%{version}

Summary: 	Jopr
Name:  		jopr-server
Version: 	2.1.0.GA
Release: 	1%{?dist}
Group:  	Applications/Internet
License: 	LGPLv2+
URL: 		http://www.jboss.org
Source0: 	%{name}-%{version}.zip
BuildRoot: 	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: 	noarch
Requires: 	java-1.6.0-openjdk

%description
jopr

%setup -c -n
%build 

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/share/
cp -pr %{_sourcedir}/%{name}-%{version} %{buildroot}/usr/share/jopr-server

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%dir /usr/share/jopr-server
/usr/share/jopr-server/*

%changelog
* Wed Jan 7 2008 Joey Boggs <jboggs@redhat.com> 2.1.0-1
- Initial packaging

