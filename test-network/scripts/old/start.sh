if [ -z "$1" ]; then
  echo "Usage $0 <channelName> [<orgNumber>]"
  exit 1
fi

export ARG1=""
export ARG2=""
export CHANNEL_PROFILE=""
export CONSORTIUM_PROFILE=""

CCN="ledger"

./network.sh up createChannel -c ${1:-"mychannel"} -i 2.2
./network.sh deployCC -c ${1:-"mychannel"} -ccn $CCN -ccv 1
#docker-compose -f docker/docker-compose-cli.yaml up -d

. ./org1.sh ${1:-"mychannel"}
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.bct.mat --tls --cafile ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem -C $CHANNEL_NAME -n $CCN --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
peer chaincode query -C $1 -n $CCN -c '{"Args":["GetAssetHistory","asset5"]}' | jq .


if [ -z "$2" ]; then
  exit 0
fi

CCN="basic"

./addch.sh channel$2 $2
. ./org$2.sh channel$2
./network.sh deployCC -c channel$2 -ccn $CCN -ccv 1
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.bct.mat --tls --cafile ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem -C channel$2 -n $CCN --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
peer chaincode query -C channel$2 -n $CCN -c '{"Args":["GetAllAssets"]}' | jq .
