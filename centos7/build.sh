#!/bin/sh

# Go crazy and get the whole development tool set
yum group install -y "Development Tools"
yum install -y wget openssl-devel zlib-devel cmake libicu-devel readline-devel gdbm-devel tree

if [ "${ruby_url}X" = "X" ]; then
    echo "ERROR: Need ruby_url so we know where to download the ruby source code." >&2
    exit 1
fi

wget -P ${builddir} ${ruby_url}
if [ "$?" -ne 0 ]; then
    echo "ERROR: Could not download ruby from ${ruby_url}" >&2
    exit 1
fi

cd ${builddir} && tar xf ruby-${ruby_version}.tar.gz
if [ $? -ne 0 ]; then
    echo "ERROR: Could not extract the ruby source code" >&2
    exit 1
fi

cd ${builddir}/ruby-${ruby_version}
./configure --prefix /opt/oxidized
if [ $? -ne 0 ]; then
    echo "ERROR: Could not configure the ruby build" >&2
    exit 1
fi

make -j $(nproc)

if [ $? -ne 0 ]; then
    echo "ERROR: Could not build ruby" >&2
    exit 1
fi

# Put ruby in place, but into the temporary install location
make install

if [ $? -ne 0 ]; then
    echo "ERROR: Could not install ruby into packaging dir" >&2
    exit 1
fi

cd /opt/oxidized/bin

echo "Installing oxidized gem"
./gem install oxidized --verbose --no-document
if [ $? -ne 0 ]; then
    echo "ERROR: Could not install oxidized gem" >&2
    exit 1
fi

echo "Installing oxidized-web gem"
./gem install oxidized-web --verbose --no-document
tree /opt/oxidized/lib/ruby/gems/2.6.0/gems/charlock_holmes-0.7.6
cat /opt/oxidized/lib/ruby/gems/2.6.0/gems/charlock_holmes-0.7.6/ext/mkmf.log

if [ $? -ne 0 ]; then
    echo "ERROR: Could not install oxidized-web gem" >&2
    exit 1
fi

oxidized_version=$(/opt/oxidized/bin/oxidized --version)

mkdir -p -m 755 ${installdir}/INSTALL/oxidized-${oxidized_version}/opt
mv /opt/oxidized ${installdir}/INSTALL/oxidized-${oxidized_version}/opt/

mkdir -p -m 755 ${installdir}/INSTALL/oxidized-${oxidized_version}/usr/lib/systemd/system

cat << EOF > ${installdir}/INSTALL/oxidized-${oxidized_version}/usr/lib/systemd/system/oxidized.service
[Unit]
Description=Oxidized Network Configuration Manager
After=syslog.target network.target

[Service]
Environment=OXIDIZED_HOME=/opt/oxidized
ExecStart=/opt/oxidized/bin/oxidized

[Install]
WantedBy=multi-user.target
EOF

mkdir -p -m 755 ${installdir}/SOURCES
cd ${installdir}/INSTALL
tar czf "${installdir}/SOURCES/oxidized-${oxidized_version}.tar.gz" *

cp -r ${scriptdir}/SPECS ${installdir}/
rpmbuild --define "_topdir ${installdir}" -ba "${installdir}/SPECS/oxidized.spec"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build RPM" >&2
    exit 1
fi
