#!/bin/bash
set -e -o pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"

ASSET_NAME=asset-private-transfer
CHANNEL=mychannel

# this is the ip address the peer will use to talk to the CHAINCODE_ID
# remember this is relative from where the peer is running.
export CHAINCODE_SERVER_ADDRESS=host.docker.internal:9999
CHAINCODE_ID=$(weft chaincode package caas --path . --label asset-private-transfer --address ${CHAINCODE_SERVER_ADDRESS} --archive asset-private-transfer-org1.tgz --quiet)    
export CHAINCODE_ID

export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=$DIR/_cfg/_msp/Org1/org1admin/msp
export CORE_PEER_ADDRESS=org1peer-api.127-0-0-1.nip.io:8080

export CORE_PEER_CLIENT_CONNTIMEOUT=15s
export CORE_PEER_DELIVERYCLIENT_CONNTIMEOUT=15s

echo "CHAINCODE_ID=${CHAINCODE_ID}"

set -x && peer lifecycle chaincode install  asset-private-transfer-org1.tgz &&     { set +x; } 2>/dev/null
echo
set -x && peer lifecycle chaincode approveformyorg --channelID $CHANNEL --name $ASSET_NAME -v 0 --package-id $CHAINCODE_ID --sequence 1 --connTimeout 15s --collections-config collections_config.json && { set +x; } 2>/dev/null
echo

export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_MSPCONFIGPATH=$DIR/_cfg/_msp/Org2/org2admin/msp
export CORE_PEER_ADDRESS=org2peer-api.127-0-0-1.nip.io:8080

export CHAINCODE_SERVER_ADDRESS=host.docker.internal:9990
CHAINCODE_ID=$(weft chaincode package caas --path . --label asset-private-transfer --address ${CHAINCODE_SERVER_ADDRESS} --archive asset-private-transfer-org2.tgz --quiet)    
export CHAINCODE_ID

set -x && peer lifecycle chaincode install asset-private-transfer-org2.tgz &&     { set +x; } 2>/dev/null
echo
set -x && peer lifecycle chaincode approveformyorg --channelID $CHANNEL --name $ASSET_NAME -v 0 --package-id $CHAINCODE_ID --sequence 1 --connTimeout 15s --collections-config collections_config.json && { set +x; } 2>/dev/null
echo


set -x && peer lifecycle chaincode commit --channelID $CHANNEL --name $ASSET_NAME -v 0 --sequence 1 --collections-config collections_config.json --connTimeout 15s && { set +x; } 2>/dev/null
echo
set -x && peer lifecycle chaincode querycommitted --channelID=$CHANNEL && { set +x; } 2>/dev/null
echo


cat << CC_EOF >> $DIR/_cfg/org1admin.env
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
export CHAINCODE_ID=${CHAINCODE_ID}
CC_EOF

cat << CC_EOF >> $DIR/_cfg/org2admin.env
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9990
export CHAINCODE_ID=${CHAINCODE_ID}
CC_EOF