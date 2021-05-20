if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage $0 <functionArgs> <chainCodeName> [<ordererNumber>]"
  echo "  Example of <functionArgs>:"
  echo "    '{\"function\":\"CreateAsset\",\"Args\":[\"c21a0fee7d2a1f4c1824384t\"]}'"
  exit 1
fi

set -x
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer$3.bct.mat \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer$3.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem \
  -C $CHANNEL_NAME -n $2 \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/ca.crt \
  -c $1
{ set +x; } 2>/dev/null