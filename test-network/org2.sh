export FABRIC_CFG_PATH=../config/
export CHANNEL_NAME=${1:-"channel1"}

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.bct.mat/users/Admin@org2.bct.mat/msp
export CORE_PEER_ADDRESS=localhost:9051
