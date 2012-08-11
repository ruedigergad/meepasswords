# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.24.1
# 

Name:       meepasswords

# >> macros
# << macros

Summary:    MeePasswords -- Keep your passwords protected.
Version:    1.9.3
Release:    1
Group:      Applications/Productivity
License:    GPLv3
URL:        http://meepasswords.garage.maemo.org/
Source0:    %{name}_%{version}.tar.gz
Source100:  meepasswords.yaml
Requires:   libdeclarative-connectivity
Requires:   libdeclarative-systeminfo
Requires:   qca-ossl
BuildRequires:  pkgconfig(QtCore) >= 4.7.0
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtConnectivity)
BuildRequires:  pkgconfig(qca2)
BuildRequires:  pkgconfig(qdeclarative-boostable)
BuildRequires:  desktop-file-utils

%description
MeePasswords is a simple tool to securely store short snippets of sensible or confidential data such as passwords and the like.


%prep
%setup -q -n %{name}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qmake 

make %{?jobs:-j%jobs}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
/usr/share/applications/%{name}.desktop
/opt/%{name}
/usr/share/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
