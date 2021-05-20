#!/bin/bash

source scriptUtils.sh

function createOrg1() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/org1.bct.mat/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.bct.mat/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org1.bct.mat/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org1.bct.mat/peers
  mkdir -p organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/msp --csr.hosts peer0.org1.bct.mat --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls --enrollment.profile tls --csr.hosts peer0.org1.bct.mat --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.bct.mat/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.bct.mat/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.bct.mat/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.bct.mat/tlsca/tlsca.org1.bct.mat-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.bct.mat/ca
  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/peers/peer0.org1.bct.mat/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.bct.mat/ca/ca.org1.bct.mat-cert.pem

  mkdir -p organizations/peerOrganizations/org1.bct.mat/users
  mkdir -p organizations/peerOrganizations/org1.bct.mat/users/User1@org1.bct.mat

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.bct.mat/users/User1@org1.bct.mat/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.bct.mat/users/User1@org1.bct.mat/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org1.bct.mat/users/Admin@org1.bct.mat

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.bct.mat/users/Admin@org1.bct.mat/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.bct.mat/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.bct.mat/users/Admin@org1.bct.mat/msp/config.yaml

}

function createOrg2() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/org2.bct.mat/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.bct.mat/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org2.bct.mat/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org2.bct.mat/peers
  mkdir -p organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/msp --csr.hosts peer0.org2.bct.mat --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls --enrollment.profile tls --csr.hosts peer0.org2.bct.mat --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.bct.mat/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.bct.mat/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.bct.mat/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.bct.mat/tlsca/tlsca.org2.bct.mat-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.bct.mat/ca
  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/peers/peer0.org2.bct.mat/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.bct.mat/ca/ca.org2.bct.mat-cert.pem

  mkdir -p organizations/peerOrganizations/org2.bct.mat/users
  mkdir -p organizations/peerOrganizations/org2.bct.mat/users/User1@org2.bct.mat

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.bct.mat/users/User1@org2.bct.mat/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.bct.mat/users/User1@org2.bct.mat/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org2.bct.mat/users/Admin@org2.bct.mat

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.bct.mat/users/Admin@org2.bct.mat/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.bct.mat/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.bct.mat/users/Admin@org2.bct.mat/msp/config.yaml

}

function createOrderer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/ordererOrganizations/bct.mat

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/bct.mat
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/bct.mat/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/bct.mat/orderers
  mkdir -p organizations/ordererOrganizations/bct.mat/orderers/bct.mat

  mkdir -p organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp --csr.hosts orderer.bct.mat --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bct.mat/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls --enrollment.profile tls --csr.hosts orderer.bct.mat --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/keystore/* ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/bct.mat/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/bct.mat/orderers/orderer.bct.mat/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/bct.mat/msp/tlscacerts/tlsca.bct.mat-cert.pem

  mkdir -p organizations/ordererOrganizations/bct.mat/users
  mkdir -p organizations/ordererOrganizations/bct.mat/users/Admin@bct.mat

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/bct.mat/users/Admin@bct.mat/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/bct.mat/msp/config.yaml ${PWD}/organizations/ordererOrganizations/bct.mat/users/Admin@bct.mat/msp/config.yaml

}
