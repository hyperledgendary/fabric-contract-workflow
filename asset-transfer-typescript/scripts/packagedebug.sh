#!/bin/bash
set -e -o pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

ASSET_NAME=asset-transfer
CHANNEL=appchannel

# this is the ip address the peer will use to talk to the CHAINCODE_ID
# remember this is relative from where the peer is running.
export CHAINCODE_SERVER_ADDRESS=host.docker.internal:9999
export CHAINCODE_ID=$(weft chaincode package caas --path . --label asset-transfer --address ${CHAINCODE_SERVER_ADDRESS} --archive asset-transfer.tgz --quiet)    
export CORE_PEER_LOCALMSPID=org1MSP

export CORE_PEER_MSPCONFIGPATH=$DIR/_cfg/_msp/org1/org1admin/msp
export CORE_PEER_ADDRESS=org1peer-api.127-0-0-1.nip.io:8080
export CORE_PEER_CLIENT_CONNTIMEOUT=15s
export CORE_PEER_DELIVERYCLIENT_CONNTIMEOUT=15s

echo "CHAINCODE_ID=${CHAINCODE_ID}"

set -x && peer lifecycle chaincode install $ASSET_NAME.tgz &&     { set +x; } 2>/dev/null
echo
set -x && peer lifecycle chaincode approveformyorg --channelID $CHANNEL --name $ASSET_NAME -v 0 --package-id $CHAINCODE_ID --sequence 1 --connTimeout 15s && { set +x; } 2>/dev/null
echo
set -x && peer lifecycle chaincode commit --channelID $CHANNEL --name $ASSET_NAME -v 0 --sequence 1  --connTimeout 15s && { set +x; } 2>/dev/null
echo
set -x && peer lifecycle chaincode querycommitted --channelID=$CHANNEL && { set +x; } 2>/dev/null
echo


cat << CC_EOF >> $DIR/_cfg/org1admin.env
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
export CHAINCODE_ID=${CHAINCODE_ID}
CC_EOF
