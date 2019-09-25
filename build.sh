#!/bin/sh

# (c)2019 Brian Sidebothan <brian.sidebotham@gmail.com>

# Set up our enviorment
basedir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
builddir=${basedir}/build

# The version of Ruby to build
ruby_version=2.6.4
ruby_url="https://cache.ruby-lang.org/pub/ruby/2.6/ruby-${ruby_version}.tar.gz"

if [ "$(id -u)" != "0" ]; then
    echo "You must run this as root" >&2
    exit 1
fi

system_release=$(cat /etc/system-release)

mkdir -p ${builddir} 2>&1

if [ "$(cat /etc/system-release 2>&1 | grep 'CentOS')X" != "X"  ]; then
    if [ "$(cat /etc/system-release 2>&1 | grep 'release 7')X" != "X" ]; then
        scriptdir=${basedir}/centos7
        installdir=${scriptdir}/rpm
    fi
fi

source ${scriptdir}/build.sh

exit $?
