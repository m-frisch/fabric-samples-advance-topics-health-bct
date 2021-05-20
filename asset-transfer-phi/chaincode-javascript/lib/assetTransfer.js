/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');
const crypto = require('crypto');

class AssetTransfer extends Contract {

    async InitLedger(ctx) {
        // not neccessary
    }

    // CreateAsset issues a new asset to the world state with given details.
    async CreateAsset(ctx, socialSecId, payload) {        
        const dhrId = await this.createDhrId(socialSecId);
        
        const existsDhr = await this.AssetDhrExists(ctx, dhrId);
        if (!existsDhr) {
            throw new Error(`The DHR asset for ${socialSecId} does not exist`);
        }
        
        const id = await this.createPhiId(dhrId, payload);
        const exists = await this.AssetExists(ctx, id);
        if (exists) {
            throw new Error(`The asset for ${dhrId} with identical payload does already exist`);
        }
        const callerMspId = await this.getCallerMspId(ctx);
        const asset = {
            DocType: "PHI",
            ID: id,
            DhrId: dhrId,
            Payload: payload,
            Owner: callerMspId,
        };
        ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    // ReadAsset returns the asset stored in the world state with given id.
    async ReadAsset(ctx, id) {
        const assetJSON = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return assetJSON.toString();
    }

    // DeleteAsset deletes an given asset from the world state.
    async DeleteAsset(ctx, id) {
        const exists = await this.AssetExists(ctx, id);
        if (!exists) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return ctx.stub.deleteState(id);
    }

    // DeleteAsset deletes all assets of given socialSecId from the world state.
    async DeleteAssets(ctx, socialSecId) {
        const dhrId = await this.createDhrId(socialSecId);

        let assets = await this.QueryAssetsByDhrId(ctx, dhrId);
        let deleted = [];
        for (const [key, value] of Object.entries(JSON.parse(assets))) {
            let phiId = value.Key;
            let result = await this.DeleteAsset(ctx, phiId);
            deleted.push({ PhiId: phiId, Record: result });
        }
        return JSON.stringify(deleted);
    }

    // AssetExists returns true when asset with given ID exists in world state.
    async AssetExists(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    // AssetExists returns true when asset with given ID exists in world state.
    async AssetDhrExists(ctx, dhrId) {
        const assetJSON = await ctx.stub.invokeChaincode("dhr", ["AssetExists", dhrId], null);
        return eval(Buffer.from(assetJSON.payload).toString().toLowerCase());
    }

	// QueryAssetsByDhrId queries for assets based on a passed in dhrId.
	// This is an example of a parameterized query where the query logic is baked into the chaincode,
	// and accepting a single query parameter (dhrId).
	// Only available on state databases that support rich query (e.g. CouchDB)
	async QueryAssetsByDhrId(ctx, dhrId) {
		let queryString = {};
		queryString.selector = {};
		queryString.selector.DocType = "PHI";
		queryString.selector.DhrId = dhrId;
        queryString.use_index = ["indexIdsDoc", "indexIdsIndex"];
		return await this.GetQueryResultForQueryString(ctx, JSON.stringify(queryString)); //shim.success(queryResults);
	}

	// Example: Ad hoc rich query
	// QueryAssets uses a query string to perform a query for assets.
	// Query string matching state database syntax is passed in and executed as is.
	// Supports ad hoc queries that can be defined at runtime by the client.
	// If this is not desired, follow the QueryAssetsForOwner example for parameterized queries.
	// Only available on state databases that support rich query (e.g. CouchDB)
	async QueryAssets(ctx, queryString) {
		return await this.GetQueryResultForQueryString(ctx, queryString);
	}

	// GetQueryResultForQueryString executes the passed in query string.
	// Result set is built and returned as a byte array containing the JSON results.
	async GetQueryResultForQueryString(ctx, queryString) {

		let resultsIterator = await ctx.stub.getQueryResult(queryString);
		let results = await this.GetAllResults(resultsIterator, false);

		return JSON.stringify(results);
	}

	// GetAssetHistory returns the chain of custody for an asset since issuance.
	async GetAssetHistory(ctx, assetName) {

		let resultsIterator = await ctx.stub.getHistoryForKey(assetName);
		let results = await this.GetAllResults(resultsIterator, true);

		return JSON.stringify(results);
	}

	async GetAllResults(iterator, isHistory) {
		let allResults = [];
		let res = await iterator.next();
		while (!res.done) {
			if (res.value && res.value.value.toString()) {
				let jsonRes = {};
				console.log(res.value.value.toString('utf8'));
				if (isHistory && isHistory === true) {
					jsonRes.TxId = res.value.tx_id;
					jsonRes.Timestamp = res.value.timestamp;
					try {
						jsonRes.Value = JSON.parse(res.value.value.toString('utf8'));
					} catch (err) {
						console.log(err);
						jsonRes.Value = res.value.value.toString('utf8');
					}
				} else {
					jsonRes.Key = res.value.key;
					try {
						jsonRes.Record = JSON.parse(res.value.value.toString('utf8'));
					} catch (err) {
						console.log(err);
						jsonRes.Record = res.value.value.toString('utf8');
					}
				}
				allResults.push(jsonRes);
			}
			res = await iterator.next();
		}
		iterator.close();
		return allResults;
	}

    // GetAllAssets returns all assets found in the world state.
    async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        let result = await iterator.next();
        while (!result.done) {
            const strValue = Buffer.from(result.value.value.toString()).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: result.value.key, Record: record });
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
    }

    // getCallerMspId returns the caller of the chaincode
    async getCallerMspId(ctx) {
        return ctx.stub.getCreator().mspid;
    }

    // createId returns the id to the given dhr number
    async createPhiId(dhrId, payload) {
        return crypto.createHash('sha1').update(dhrId + "__" + payload).digest('hex');
    }

    // createId returns the id to the given social security number
    async createDhrId(socialSecId) {
        return crypto.createHash('sha1').update(socialSecId).digest('hex');
    }
}

module.exports = AssetTransfer;
