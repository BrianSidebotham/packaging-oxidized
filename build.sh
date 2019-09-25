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

if [ $# -lt 2 ]; then
    echo "usage: ${0} OS_TYPE OS_VERSION" >&2
    exit 1
fi

ostype="${1}"
osversion="${2}"

mkdir -p ${builddir} 2>&1

scriptdir=${basedir}/${ostype}${osversion}
installdir=${scriptdir}/rpm

source ${scriptdir}/build.sh

exit $?
