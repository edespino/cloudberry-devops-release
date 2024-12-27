%define cloudberry_install_dir /usr/local/cloudberry-db

# Add at the top of the spec file
# Default to non-debug build
%bcond_with debug

# Conditional stripping based on debug flag
%if %{with debug}
%define __os_install_post %{nil}
%define __strip /bin/true
%define debug_package %{nil}
%endif

Name:           cloudberry-db
Version:        %{version}
# In the release definition section
%if %{with debug}
Release:        %{release}.debug%{?dist}
%else
Release:        %{release}%{?dist}
%endif
Summary:        High-performance, open-source data warehouse based on PostgreSQL/Greenplum

License:        ASL 2.0
URL:            https://cloudberrydb.org
Vendor:         Cloudberry Open Source
Group:          Applications/Databases
Prefix:         %{cloudberry_install_dir}

# Disabled as we are shipping GO programs (e.g. gpbackup)
%define _missing_build_ids_terminate_build 0

# Disable debugsource files
%define _debugsource_template %{nil}

# List runtime dependencies

Requires:       bash
Requires:       iproute
Requires:       iputils
Requires:       openssh
Requires:       openssh-clients
Requires:       openssh-server
Requires:       rsync

%if 0%{?rhel} == 8
Requires:       apr
Requires:       audit
Requires:       bzip2
Requires:       keyutils
Requires:       libcurl
Requires:       libevent
Requires:       libidn2
Requires:       libselinux
Requires:       libstdc++
Requires:       libuuid
Requires:       libuv
Requires:       libxml2
Requires:       libyaml
Requires:       libzstd
Requires:       lz4
Requires:       openldap
Requires:       pam
Requires:       perl
Requires:       python3
Requires:       readline
%endif

%if 0%{?rhel} == 9
Requires:       apr
Requires:       bzip2
Requires:       glibc
Requires:       keyutils
Requires:       libcap
Requires:       libcurl
Requires:       libidn2
Requires:       libpsl
Requires:       libssh
Requires:       libstdc++
Requires:       libxml2
Requires:       libyaml
Requires:       libzstd
Requires:       lz4
Requires:       openldap
Requires:       pam
Requires:       pcre2
Requires:       readline
Requires:       xz
%endif

%description

Cloudberry Database is an advanced, open-source, massively parallel
processing (MPP) data warehouse developed from PostgreSQL and
Greenplum. It is designed for high-performance analytics on
large-scale data sets, offering powerful analytical capabilities and
enhanced security features.

Key Features:

- Massively parallel processing for optimized performance
- Advanced analytics for complex data processing
- Integration with ETL and BI tools
- Compatibility with multiple data sources and formats
- Enhanced security features

Cloudberry Database supports both batch processing and real-time data
warehousing, making it a versatile solution for modern data
environments.

For more information, visit the official Cloudberry Database website
at https://cloudberrydb.org.

%prep
# No prep needed for binary RPM

%build
# No prep needed for binary RPM

%install
rm -rf %{buildroot}

# Create the versioned directory
mkdir -p %{buildroot}%{cloudberry_install_dir}-%{version}

cp -R %{cloudberry_install_dir}/* %{buildroot}%{cloudberry_install_dir}-%{version}

# Create the symbolic link
ln -sfn %{cloudberry_install_dir}-%{version} %{buildroot}%{cloudberry_install_dir}

%files
%{prefix}-%{version}
%{prefix}

%license %{cloudberry_install_dir}-%{version}/LICENSE

%post
# Change ownership to gpadmin.gpadmin if the gpadmin user exists
if id "gpadmin" &>/dev/null; then
    chown -R gpadmin:gpadmin %{cloudberry_install_dir}-%{version}
    chown gpadmin:gpadmin %{cloudberry_install_dir}
fi

%postun
if [ $1 -eq 0 ] ; then
  if [ "$(readlink -f "%{cloudberry_install_dir}")" == "%{cloudberry_install_dir}-%{version}" ]; then
    unlink "%{cloudberry_install_dir}" || true
  fi
fi
