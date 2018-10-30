#!/bin/bash
# Automated build script
# Use at your own risk
#
# tested on:
#   * Debian 8.3 jessie (stable) x86_64
#   * Ubuntu 14.04 amd64
#   * Ubuntu 16.04 amd64
#
# Optionally:
# Set custom git url and branch e.g.:
# $ bash groestlcoindbuilder.sh --git-url="https://github.com/groestlcoin/groestlcoincoin.git"

set -e

GIT_URL="https://github.com/groestlcoin/groestlcoin.git"
GIT_BRANCH="2.16.3"
GIT_VERIFY="true"
DIR=$(pwd)
INSTALL_REQUIREMENTS="true"

# print usage help
function usage()
{
    echo "Groestlcoin build script, automates building the current version of groestlcoin-core."
    echo ""
    echo "${0}"
    echo -e "\t-h --help"
    echo -e "\t--git-url=${GIT_URL}"
    echo -e "\t--git-branch=${GIT_BRANCH}"
    echo -e "\t--git-verify=${GIT_VERIFY}"
    echo -e "\t--dir=${DIR}"
    echo -e "\t--install-requirements=${INSTALL_REQUIREMENTS}"
    echo ""
}

# install requirements for tool-chain on debian
function debian_install_toolchain()
{
	echo "BB: installing tool chain ..."
	sudo apt-get install \
	git \
	build-essential \
	g++ \
	libtool \
	autotools-dev \
	automake \
	pkg-config \
	bsdmainutils \
  ntp \
  make \
  gcc \
  autoconf \
  cpp \
  ngrep \
  iftop \
  sysstat \
  libminiupnpc-dev \
  libzmq3-dev
}

function debian_install_requirements()
{
	echo "BB: installing requirements ..."
	sudo apt-get install \
	libssl-dev \
	libevent-dev \
	libboost-all-dev \
	libdb5.3 \
	libdb5.3-dev \
	libdb5.3++-dev
}

### main ###
if [ "$1" == "" ]; then
    usage
    exit
fi

# parse command line args
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | sed 's/^[^=]*=//g'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --git-url)
            GIT_URL=${VALUE}
            ;;
        --git-branch)
            GIT_BRANCH=${VALUE}
            ;;
        --dir)
            DIR=${VALUE}
            ;;
        --git-verify)
            GIT_VERIFY=${VALUE}
            ;;
        --install-requirements)
            INSTALL_REQUIREMENTS=${VALUE}
            ;;
        *)
            echo "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

echo "BB: GIT_URL              = ${GIT_URL}";
echo "BB: GIT_BRANCH           = ${GIT_BRANCH}";
echo "BB: DIR 	               = ${DIR}";
echo "BB: GIT_VERIFY           = ${GIT_VERIFY}";
echo "BB: INSTALL_REQUIREMENTS = ${INSTALL_REQUIREMENTS}";

### start building ###

# installing prerequesits
if [ "${INSTALL_REQUIREMENTS}" == "true" ];
then
  debian_install_toolchain;
  debian_install_requirements;
fi

# Clone groestlcoin repository
cd ${DIR}
if [ -a "./groestlcoin" ];
then
	echo "git repository already cloned ... "
else
	git clone ${GIT_URL}
fi
cd ./groestlcoin
git fetch
git checkout ${GIT_BRANCH}

if [ "${GIT_VERIFY}" == "true" ];
then
	git verify-commit $(git log -n1 --pretty=format:%H)
fi

# Build groestlcoin core
cd "${DIR}"

./autogen.sh

echo "BB: autgen DONE ";
sleep 2


./configure
#--with-pic

#./configure \
#CXXFLAGS="-static" \
#CFLAGS="-static" \
#--disable-zmq \
#--without-gui \
#--without-miniupnpc \
#--disable-tests \
#--disable-shared \
#--enable-static \
#--enable-hardening \
#--with-pic

echo "BB: configure DONE ";
sleep 2

make clean
echo "BB: make clean DONE ";
sleep 2

make
echo "BB: make DONE ";

exit
