==> Use ../chaincode-javascript/lib/assetTransfer.js

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"sort"
	"crypto/sha1"
  )

// SmartContract provides functions for managing an Asset
type SmartContract struct {
	contractapi.Contract
}

// Asset describes basic details of what makes up a simple asset
type Asset struct {
	DocType        string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	ID             string `json:"ID"`      //the field tags are needed to keep case from bouncing around
	SocialSecID  string      `json:"socialSecID"`
	Providers      []string `json:"providers"`
}

// InitLedger adds a base set of assets to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
  }

  // CreateAsset issues a new asset to the world state with given details.
func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, socialSecID string) error {
	exists, err := s.QueryAssetsBySocialSecID(ctx, socialSecID)
	if err != nil {
	  return err
	}
	if len(exists) > 0 {
	  return fmt.Errorf("the asset for %s already exists", socialSecID)
	}
	
	provider, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
	  return err
	}

	h := sha1.New()
	h.Write([]byte(socialSecID))
	id := fmt.Sprintf("%x", h.Sum(nil))

	asset := Asset{
	  DocType:			"DHR",
	  ID:             id,
	  SocialSecID:    socialSecID,
	  Providers: 		[]string{provider},
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
	  return err
	}
  
	return ctx.GetStub().PutState(id, assetJSON)
  }
  
// AddProvider
func (s *SmartContract) AddProvider(ctx contractapi.TransactionContextInterface, id string) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
	  return err
	}
	if !exists {
	  return fmt.Errorf("the asset %s does not exist", id)
	}

	origAssetJSON, err := ctx.GetStub().GetState(id)
	var origAsset Asset
	err = json.Unmarshal(origAssetJSON, &origAsset)
	if err != nil {
	  return err
	}
	
	provider, err := ctx.GetClientIdentity().GetMSPID()
	if err != nil {
	  return err
	}
	
	if sort.SearchStrings(origAsset.Providers, provider) < len(origAsset.Providers) {
	  return fmt.Errorf("the provider %s exists already", provider)
	}

	providers := append(origAsset.Providers, provider)
	sort.Strings(providers)
	
	// overwriting original asset with new asset
	asset := Asset{
	  DocType:		origAsset.DocType,
	  ID:             id,
	  SocialSecID:	origAsset.SocialSecID,
	  Providers:      providers,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
	  return err
	}

	return ctx.GetStub().PutState(id, assetJSON)
}

// DeleteAsset deletes an given asset from the world state.
func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error {
	exists, err := s.AssetExists(ctx, id)
	if err != nil {
	  return err
	}
	if !exists {
	  return fmt.Errorf("the asset %s does not exist", id)
	}
  
	return ctx.GetStub().DelState(id)
  }

// AssetExists returns true when asset with given ID exists in world state
func (s *SmartContract) AssetExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
	  return false, fmt.Errorf("failed to read from world state: %v", err)
	}
  
	return assetJSON != nil, nil
  }

// GetAllAssets returns all assets found in world state
func (s *SmartContract) GetAllAssets(ctx contractapi.TransactionContextInterface) ([]*Asset, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
	  return nil, err
	}
	defer resultsIterator.Close()
  
	var assets []*Asset
	for resultsIterator.HasNext() {
	  queryResponse, err := resultsIterator.Next()
	  if err != nil {
		return nil, err
	  }
  
	  var asset Asset
	  err = json.Unmarshal(queryResponse.Value, &asset)
	  if err != nil {
		return nil, err
	  }
	  assets = append(assets, &asset)
	}
  
	return assets, nil
  }

// QueryAssetsByOwner queries for assets based on the owners name.
// This is an example of a parameterized query where the query logic is baked into the chaincode,
// and accepting a single query parameter (owner).
// Only available on state databases that support rich query (e.g. CouchDB)
// Example: Parameterized rich query
func (s *SmartContract) QueryAssetsBySocialSecID(ctx contractapi.TransactionContextInterface, socialSecID string) ([]*Asset, error) {
	queryString := fmt.Sprintf(`{"selector":{"docType":"DHR","socialSecID":"%s"}}`, socialSecID)
	return getQueryResultForQueryString(ctx, queryString)
}

func main() {
	assetChaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
	  log.Panicf("Error creating asset-transfer-dhr chaincode: %v", err)
	}
  
	if err := assetChaincode.Start(); err != nil {
	  log.Panicf("Error starting asset-transfer-dhr chaincode: %v", err)
	}
  }

// constructQueryResponseFromIterator constructs a slice of assets from the resultsIterator
func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) ([]*Asset, error) {
	var assets []*Asset
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var asset Asset
		err = json.Unmarshal(queryResult.Value, &asset)
		if err != nil {
			return nil, err
		}
		assets = append(assets, &asset)
	}

	return assets, nil
}

// getQueryResultForQueryString executes the passed in query string.
// The result set is built and returned as a byte array containing the JSON results.
func getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]*Asset, error) {
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	return constructQueryResponseFromIterator(resultsIterator)
}