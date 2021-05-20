if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage $0 <channelName> <orgNumber>"
  exit 1
fi
PORT=$(expr $2 + 8)

set -x

## based on https://hyperledger-fabric.readthedocs.io/en/latest/channel_update_tutorial.html

# Generate the Org$2 Crypto Material
cd addOrg$2
../../bin/cryptogen generate --config=org$2-crypto.yaml --output="../organizations"
export FABRIC_CFG_PATH=$PWD
../../bin/configtxgen -printOrg Org$2MSP > ../organizations/peerOrganizations/org$2.bct.mat/org$2.json

./ccp-generate.sh

# Bring up Org$2 components
docker-compose -f docker/docker-compose-org$2.yaml -f docker/docker-compose-couch-org$2.yaml up -d 2>&1

# Fetch the Configuration
cd ..
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.bct.mat/users/Admin@org1.bct.mat/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.bct.mat -c $1 --tls --cafile "${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem"

# Convert the Configuration to JSON and Trim It Down
cd channel-artifacts
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq .data.data[0].payload.data.config config_block.json > config.json

# Add the Org$2 Crypto Material
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org'$2'MSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/org$2.bct.mat/org$2.json > modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $1 --original config.pb --updated modified_config.pb --output org$2_update.pb
configtxlator proto_decode --input org$2_update.pb --type common.ConfigUpdate --output org$2_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$1'", "type":2}},"data":{"config_update":'$(cat org$2_update.json)'}}}' | jq . > org$2_update_in_envelope.json
configtxlator proto_encode --input org$2_update_in_envelope.json --type common.Envelope --output org$2_update_in_envelope.pb

# Sign and Submit the Config Update
cd ..
peer channel signconfigtx -f channel-artifacts/org$2_update_in_envelope.pb
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.bct.mat/users/Admin@org2.bct.mat/msp
export CORE_PEER_ADDRESS=localhost:9051

peer channel update -f channel-artifacts/org$2_update_in_envelope.pb -c $1 -o localhost:7050 --ordererTLSHostnameOverride orderer.bct.mat --tls --cafile "${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem"

# docker logs -f peer0.org1.bct.mat

# Join Org$2 to the Channel
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org$2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org$2.bct.mat/peers/peer0.org$2.bct.mat/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org$2.bct.mat/users/Admin@org$2.bct.mat/msp
export CORE_PEER_ADDRESS=localhost:${PORT}051

sleep 10

peer channel fetch 0 channel-artifacts/$1.block -o localhost:7050 --ordererTLSHostnameOverride orderer.bct.mat -c $1 --tls --cafile "${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem"
peer channel join -b channel-artifacts/$1.block

{ set +x; } 2>/dev/null
