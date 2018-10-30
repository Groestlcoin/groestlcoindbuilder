#!/bin/bash
#
# Wrapper script for `groestlcoind` and `groestlcoin-cli`
#
# Use at own risk!
#
# Commands wrapped:
# ./groestlcoind -daemon -txindex -datadir="/home/groestlcoin/groestlcoin_datadirs/powerclient_0.12/"
# export GRS_DATA="${GRS_DATA}";
# ./groestlcoin-cli --datadir=$GRS_DATA getblockchaininfo
#
# Future work:
# Read password from command line and unlock wallet.
# In shell script pw can be handed over to groestlcoin-cli that way:
# echo -e "mysecretcode\n120" | src/groestlcoin-cli -stdin walletpassphrase

set -e

GROESTLCOIND="/home/groestlcoin/groestlcoin_bin/2.16.3/groestlcoind"
GRS_DATA="/home/groestlcoin/groestlcoin_data/2.16.3/"
WALLET="wallet.dat"
ACTION="start"
GROESTLCOINCLI="/home/groestlcoin/groestlcoin_bin/2.16.3/groestlcoin-cli"
PORT="1331"

function usage()
{
    echo "Local Groestlcoin core wrapper script"
    echo ""
    echo "${0}"
    echo -e "\t-h --help"
    echo -e "\t--groestlcoind=${GROESTLCOIND}"
    echo -e "\t--grs-data=${GRS_DATA}"
    echo -e "\t--wallet=${WALLET}"
    echo -e "\t--action=${ACTION}"
    echo -e "\t--port=${PORT}"
    echo ""
}

# main
if [ "$1" == "" ]; then
    usage
    #exit
fi

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | sed 's/^[^=]*=//g'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
	--groestlcoind)
	    GROESTLCOIND="${VALUE}"
	    ;;
        --grs-data)
            GRS_DATA="${VALUE}"
            ;;
        --action)
            ACTION="${VALUE}"
            ;;
        --wallet)
            WALLET="${VALUE}"
            ;;
        --groestlcoincli)
            GROESTLCOINCLI="${VALUE}"
            ;;
        --port)
            PORT="${VALUE}"
            ;;
	*)
            echo "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

echo "GROESTLCOIND   is ${GROESTLCOIND}";
echo "GRS_DATA       is ${GRS_DATA}";
echo "GROESTLCOINCLI is ${GROESTLCOINCLI}";
echo "ACTION         is ${ACTION}";
echo "PORT           is ${PORT}";

if [ "${ACTION}" == "start" ];
then
	${GROESTLCOIND} -daemon -txindex -datadir="${GRS_DATA}" -port="${PORT}" --wallet="${WALLET}";
	exit 0
fi

if [ "${ACTION}" != "" ];
then
	${GROESTLCOINCLI} --datadir=${GRS_DATA} ${ACTION};
fi
