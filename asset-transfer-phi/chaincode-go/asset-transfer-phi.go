==> Use ../chaincode-javascript/lib/assetTransfer.js

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"crypto/sha1"
  )

// SmartContract provides functions for managing an AssetPHI
type SmartContract struct {
	contractapi.Contract
}

// AssetPHI describes basic details of what makes up a simple asset
type AssetPHI struct {
	DocType        string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	ID             string `json:"ID"`      //the field tags are needed to keep case from bouncing around
	DhrID  			string      `json:"dhrID"`
	Payload  		string      `json:"payload"`
	PayloadHash  		string      `json:"payloadHash"`
}

// InitLedger adds a base set of assets to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
  }

  // CreateAssetPHI issues a new asset to the world state with given details.
func (s *SmartContract) CreateAssetPHI(ctx contractapi.TransactionContextInterface, dhrID string, payload string) error {
	//existsDhr, err := s.QueryAssetDHRsByID(ctx, dhrID)
	argsJSON := "'{\"Args\":[\"AssetDHRExists\",\"" + dhrID + "\"]}'"
	var arr []byte
	err := json.Unmarshal(argsJSON, &arr)
	response := ctx.GetStub().InvokeChaincode("asset-transfer-dhi", arr, "channel1")
	if response.Status != shim.OK {
		return fmt.Errorf(fmt.Sprintf("Failed to query chaincode: %s", response.Payload))
	}
	if !response.Payload {
	  return fmt.Errorf("the DHR %s does not exist", dhrID)
	}

	h := sha1.New()
	h.Write([]byte(payload))
	payloadHash := fmt.Sprintf("%x", h.Sum(nil))

	existsPayload, err := s.QueryAssetPHIsByDhrIDandPayloadHash(ctx, dhrID, payloadHash)

	if len(existsPayload) > 0 {
	  return fmt.Errorf("the asset for %s with payload %s already exists", dhrID, payloadHash)
	}

	exists, err := s.QueryAssetPHIsByDhrID(ctx, dhrID)
	id := dhrID + "/" + fmt.Sprintf("%d", len(exists))

	asset := AssetPHI{
	  DocType:			"PHI",
	  ID:             id,
	  DhrID:    	dhrID,
	  Payload: 		payload,
	  PayloadHash:	payloadHash,
	}
	assetJSON, err := json.Marshal(asset)
	if err != nil {
	  return err
	}
  
	return ctx.GetStub().PutState(id, assetJSON)
  }

// DeleteAssetPHI deletes an given asset from the world state.
func (s *SmartContract) DeleteAssetPHI(ctx contractapi.TransactionContextInterface, id string) error {
	exists, err := s.AssetPHIExists(ctx, id)
	if err != nil {
	  return err
	}
	if !exists {
	  return fmt.Errorf("the asset %s does not exist", id)
	}
  
	return ctx.GetStub().DelState(id)
  }

// AssetPHIExists returns true when asset with given ID exists in world state
func (s *SmartContract) AssetPHIExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	assetJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
	  return false, fmt.Errorf("failed to read from world state: %v", err)
	}
  
	return assetJSON != nil, nil
  }

// GetAllAssetPHIs returns all assets found in world state
func (s *SmartContract) GetAllAssetPHIs(ctx contractapi.TransactionContextInterface) ([]*AssetPHI, error) {
	// range query with empty string for startKey and endKey does an
	// open-ended query of all assets in the chaincode namespace.
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
	  return nil, err
	}
	defer resultsIterator.Close()
  
	var assets []*AssetPHI
	for resultsIterator.HasNext() {
	  queryResponse, err := resultsIterator.Next()
	  if err != nil {
		return nil, err
	  }
  
	  var asset AssetPHI
	  err = json.Unmarshal(queryResponse.Value, &asset)
	  if err != nil {
		return nil, err
	  }
	  assets = append(assets, &asset)
	}
  
	return assets, nil
  }

// QueryAssetPHIsByOwner queries for assets based on the owners name.
// This is an example of a parameterized query where the query logic is baked into the chaincode,
// and accepting a single query parameter (owner).
// Only available on state databases that support rich query (e.g. CouchDB)
// Example: Parameterized rich query
func (s *SmartContract) QueryAssetPHIsByDhrID(ctx contractapi.TransactionContextInterface, dhrID string) ([]*AssetPHI, error) {
	queryString := fmt.Sprintf(`{"selector":{"docType":"PHI","dhrID":"%s"}}`, dhrID)
	return getQueryResultForQueryString(ctx, queryString)
}

// QueryAssetPHIsByOwner queries for assets based on the owners name.
// This is an example of a parameterized query where the query logic is baked into the chaincode,
// and accepting a single query parameter (owner).
// Only available on state databases that support rich query (e.g. CouchDB)
// Example: Parameterized rich query
func (s *SmartContract) QueryAssetPHIsByDhrIDandPayloadHash(ctx contractapi.TransactionContextInterface, dhrID string, payloadHash string) ([]*AssetPHI, error) {
	queryString := fmt.Sprintf(`{"selector":{"docType":"PHI","dhrID":"%s","payloadHash":"%s"}}`, dhrID, payloadHash)
	return getQueryResultForQueryString(ctx, queryString)
}

// QueryAssetPHIsByOwner queries for assets based on the owners name.
// This is an example of a parameterized query where the query logic is baked into the chaincode,
// and accepting a single query parameter (owner).
// Only available on state databases that support rich query (e.g. CouchDB)
// Example: Parameterized rich query
func (s *SmartContract) QueryAssetDHRsByID(ctx contractapi.TransactionContextInterface, dhrID string) ([]*AssetPHI, error) {
	queryString := fmt.Sprintf(`{"selector":{"docType":"DHR","ID":"%s"}}`, dhrID)
	return getQueryResultForQueryString(ctx, queryString)
}

func main() {
	assetChaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
	  log.Panicf("Error creating asset-transfer-phi chaincode: %v", err)
	}
  
	if err := assetChaincode.Start(); err != nil {
	  log.Panicf("Error starting asset-transfer-phi chaincode: %v", err)
	}
  }

// constructQueryResponseFromIterator constructs a slice of assets from the resultsIterator
func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) ([]*AssetPHI, error) {
	var assets []*AssetPHI
	for resultsIterator.HasNext() {
		queryResult, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		var asset AssetPHI
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
func getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]*AssetPHI, error) {
	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	return constructQueryResponseFromIterator(resultsIterator)
}