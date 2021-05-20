

function createOrg4 {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p ../organizations/peerOrganizations/org4.bct.mat/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/org4.bct.mat/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12054 --caname ca-org4 --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-org4.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-org4.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-org4.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-org4.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/../organizations/peerOrganizations/org4.bct.mat/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org4 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org4 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org4 --id.name org4admin --id.secret org4adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

	mkdir -p ../organizations/peerOrganizations/org4.bct.mat/peers
  mkdir -p ../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-org4 -M ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/msp --csr.hosts peer0.org4.bct.mat --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/msp/config.yaml ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-org4 -M ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls --enrollment.profile tls --csr.hosts peer0.org4.bct.mat --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null


  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/ca.crt
  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/signcerts/* ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/server.crt
  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/keystore/* ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/server.key

  mkdir ${PWD}/../organizations/peerOrganizations/org4.bct.mat/msp/tlscacerts
  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/org4.bct.mat/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../organizations/peerOrganizations/org4.bct.mat/tlsca
  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/org4.bct.mat/tlsca/tlsca.org4.bct.mat-cert.pem

  mkdir ${PWD}/../organizations/peerOrganizations/org4.bct.mat/ca
  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/peers/peer0.org4.bct.mat/msp/cacerts/* ${PWD}/../organizations/peerOrganizations/org4.bct.mat/ca/ca.org4.bct.mat-cert.pem

  mkdir -p ../organizations/peerOrganizations/org4.bct.mat/users
  mkdir -p ../organizations/peerOrganizations/org4.bct.mat/users/User1@org4.bct.mat

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:12054 --caname ca-org4 -M ${PWD}/../organizations/peerOrganizations/org4.bct.mat/users/User1@org4.bct.mat/msp --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/msp/config.yaml ${PWD}/../organizations/peerOrganizations/org4.bct.mat/users/User1@org4.bct.mat/msp/config.yaml

  mkdir -p ../organizations/peerOrganizations/org4.bct.mat/users/Admin@org4.bct.mat

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org4admin:org4adminpw@localhost:12054 --caname ca-org4 -M ${PWD}/../organizations/peerOrganizations/org4.bct.mat/users/Admin@org4.bct.mat/msp --tls.certfiles ${PWD}/fabric-ca/org4/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/org4.bct.mat/msp/config.yaml ${PWD}/../organizations/peerOrganizations/org4.bct.mat/users/Admin@org4.bct.mat/msp/config.yaml

}
