#
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
#

Name:       harbour-sailcron

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Manage your crontabs
Version:    0.8
Release:    1
Group:      Qt/Qt
License:    GPLv2
URL:        https://github.com/a-dekker/sailcron
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Suggests:   cronie
Requires:   pyotherside-qml-plugin-python3-qt5 >= 1.5.0
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
App to manage your crontab entries (user and root)


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(644,root,root,755)
%attr(755,root,root) %{_bindir}/harbour-sailcron
%{_datadir}/%{name}/qml
%{_datadir}/%{name}/helper
%{_datadir}/%{name}/python
%{_datadir}/%{name}/python/cron_descriptor
%attr(700,root,root) %{_datadir}/%{name}/helper/sailcronhelper.sh
%attr(4755,root,root) %{_datadir}/%{name}/helper/sailcronhelper
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%{_datadir}/%{name}/translations
/usr/bin/harbour-sailcron
/usr/share/harbour-sailcron
/usr/share/applications
/usr/share/icons/hicolor/*/apps
