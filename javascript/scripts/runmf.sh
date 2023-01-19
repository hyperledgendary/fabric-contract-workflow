#!/bin/bash
set -e -o pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
export CFG="${DIR}/_cfg"
mkdir -p "${CFG}"

export CFG=$DIR/_cfg
export MICROFAB_CONFIG='{
    "endorsing_organizations":[
        {
            "name": "org1"
        }
    ],
    "channels":[
        {
            "name": "appchannel",
            "endorsing_organizations":[
                "org1"
            ]
        }

    ],
    "capability_level":"V2_0"
}'

mkdir -p $CFG
echo
echo "Stating microfab...."

docker kill microfab 1>/dev/null 2>&1 || true
docker run --name microfab -p 8080:8080 --add-host host.docker.internal:host-gateway --rm -d -e MICROFAB_CONFIG="${MICROFAB_CONFIG}"  ibmcom/ibp-microfab:0.0.16
sleep 5

curl -s http://console.127-0-0-1.nip.io:8080/ak/api/v1/components | weft microfab -w $CFG/_wallets -p $CFG/_gateways -m $CFG/_msp -f
cat << EOF > $CFG/org1admin.env
export CORE_PEER_LOCALMSPID=org1MSP
export CORE_PEER_MSPCONFIGPATH=$CFG/_msp/org1/org1admin/msp
export CORE_PEER_ADDRESS=org1peer-api.127-0-0-1.nip.io:8080
export FABRIC_CFG_PATH=$CWDIR/config
export CORE_PEER_CLIENT_CONNTIMEOUT=15s
export CORE_PEER_DELIVERYCLIENT_CONNTIMEOUT=15s
EOF

echo
echo "To get an peer cli environment run:"
echo
echo "source $(realpath --relative-to=$DIR $CFG)/org1admin.env"
