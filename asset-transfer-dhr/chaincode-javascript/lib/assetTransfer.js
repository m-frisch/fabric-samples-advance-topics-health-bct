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
    async CreateAsset(ctx, socialSecId) {
        const id = await this.createDhrId(socialSecId);
        const exists = await this.AssetExists(ctx, id);
        if (exists) {
            throw new Error(`The asset from ${socialSecId} does already exist`);
        }
        const callerMspId = await this.getCallerMspId(ctx);
        const asset = {
            DocType: "DHR",
            ID: id,
            SocialSecId: socialSecId,
            Owner: callerMspId,
        };
        ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
        return JSON.stringify(asset);
    }

    // ReadAssetCustomField returns a CustomFields of the asset stored in the world state with given id and fieldName.
    async ReadAssetCustomField(ctx, id, fieldName) {
        fieldName = fieldName.toLowerCase();
        
        const assetJSON = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }
        return assetJSON.CustomFields[fieldName];
    }

    // DeleteAsset deletes an given asset from the world state, if no related PHI exist anymore and caller is owner.
    async DeleteAsset(ctx, socialSecId) {
        const id = await this.createDhrId(socialSecId);

        const assetsJSON = await ctx.stub.invokeChaincode("phi", ["QueryAssetsByDhrId", id], null);
        const assets = JSON.parse(Buffer.from(assetsJSON.payload).toString('utf8'));
        for (const [key, value] of Object.entries(assets)) {
            throw new Error(`The DHR asset ${id} still contains PHI assets`);
        }

        const exists = await this.AssetExists(ctx, id);
        if (!exists) {
            throw new Error(`The asset ${id} does not exist`);
        }
        
        await this.CheckCallerIsOwner(ctx, id);
        return ctx.stub.deleteState(id);
    }

    // AssetExists returns true when asset with given ID exists in world state.
    async AssetExists(ctx, id) {
        const assetJSON = await ctx.stub.getState(id);
        return assetJSON && assetJSON.length > 0;
    }

    // UpdateAsset updates an arbitrary CustomField in the world state if caller is owner.
    async UpdateAsset(ctx, socialSecId, fieldName, fieldType, value) {
        const id = await this.createDhrId(socialSecId);
        fieldName = fieldName.toLowerCase();
        fieldType = fieldType.toLowerCase();

        value = await this.EvaluateField(fieldType, value);

        // special check in case of birth year
        if (fieldName == "birthyear") {
            value = parseInt(value);
            if (value < 1900 || value > new Date().getFullYear()) {
                throw new Error(`The birth year ${value} is not accepted`);
            }
        }        

        const asset = await this.CheckCallerIsOwner(ctx, id);

        // overwrite CustomFields.fieldName with given value
        asset.CustomFields = asset.CustomFields || {};
        const fieldFullName = await this.createFieldFullName(fieldName, fieldType);
        asset.CustomFields[fieldFullName] = value;

        return ctx.stub.putState(id, Buffer.from(JSON.stringify(asset)));
    }

	// QueryAssetsByCustomField queries for assets based on a passed in custom field and value.
	// This is an example of a parameterized query where the query logic is baked into the chaincode,
	// and accepting a single query parameter (custom field and value).
	// Only available on state databases that support rich query (e.g. CouchDB)
	async QueryAssetsByCustomField(ctx, fieldName, fieldType, value) {
        const fieldFullName = await this.createFieldFullName(fieldName, fieldType);

        value = await this.EvaluateField(fieldType, value);        
        
        let queryString = {};
		queryString.selector = {};
		queryString.selector.DocType = "DHR";
		queryString.selector.CustomFields = {};
        queryString.selector.CustomFields[fieldFullName] = value;
		return await this.GetQueryResultForQueryStringCustomFieldsOnly(ctx, JSON.stringify(queryString)); //shim.success(queryResults);
	}

	// QueryAssetsBySocialSecId queries for assets based on a passed in socialSecId.
	// This is an example of a parameterized query where the query logic is baked into the chaincode,
	// and accepting a single query parameter (socialSecId).
	// Only available on state databases that support rich query (e.g. CouchDB)
	// Example: Parameterized rich query
	async QueryAssetsBySocialSecId(ctx, socialSecId) {
        let queryString = {};
		queryString.selector = {};
        queryString.selector.Owner = await this.getCallerMspId(ctx);
		queryString.selector.DocType = "DHR";
		queryString.selector.SocialSecId = socialSecId;
        queryString.use_index = ["indexIdsDoc", "indexIdsIndex"];

		let resultsIterator = await ctx.stub.getQueryResult(JSON.stringify(queryString));
		let results = await this.GetAllResults(resultsIterator, false);
		return JSON.stringify(results);        
	}

	// GetQueryResultForQueryStringCustomFieldsOnly executes the passed in query string on CustomFields only.
	async GetQueryResultForQueryStringCustomFieldsOnly(ctx, queryString) {

		let resultsIterator = await ctx.stub.getQueryResult(queryString);
		let results = await this.GetAllResults(resultsIterator, false);

		let customFieldsAssets = [];
        for (const asset of results) {
            let customFieldsAsset = {
                DocType: "DHR_c",
                ID: asset.Key,
                CustomFields: asset.Record.CustomFields,
            };
            customFieldsAssets.push(customFieldsAsset);
		}        
        return JSON.stringify(customFieldsAssets);
	}

	// GetAssetHistory returns the chain of custody for an asset since issuance.
	async GetAssetHistory(ctx, assetName) {

		let resultsIterator = await ctx.stub.getHistoryForKey(assetName);
		let results = await this.GetAllResults(resultsIterator, true);

		return JSON.stringify(results);
	}

    // GetAllAssets returns all owned assets found in the world state.
    async GetAllAssets(ctx) {
        const allResults = [];
        // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
        const iterator = await ctx.stub.getStateByRange('', '');
        const callerMspId = await this.getCallerMspId(ctx);
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
            if (record.Owner == callerMspId || record == strValue) {
                allResults.push({ Key: result.value.key, Record: record });
            }
            result = await iterator.next();
        }
        return JSON.stringify(allResults);
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

    // EvaluateField checks if given value corresponds to given fieldType, and converts it
    async EvaluateField(fieldType, value) {
        switch (fieldType) {
            case "float":
                value = parseFloat(value);
                if (isNaN(value))
                    throw new Error(`The value ${value} is not of type ${fieldType}`);
                break;
            case "int":
                value = parseInt(value);
                if (isNaN(value))
                    throw new Error(`The value ${value} is not of type ${fieldType}`);
                break;
            case "date":
                value = Date.parse(value);
                if (isNaN(value))
                    throw new Error(`The value ${value} is not of type ${fieldType}. See https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/Date/parse for more info.`);
                break;
            case "bool":
                if (value == "true" || value == "1")
                    value = true;
                else if (value == "false" || value == "0")
                    value = false;
                else
                    throw new Error(`The value ${value} is not of type boolean, only true and false or 1 and 0 are allowed.`);
                break;
            case "string": break;
            default: throw new Error(`Type ${fieldType} is unknown. Allowed types: float, int, date, bool, string`);
        }
        return value;
    }

    // get existing asset and check if caller is owner
    async CheckCallerIsOwner(ctx, id) {
        const assetJSON = await ctx.stub.getState(id); // get the asset from chaincode state
        if (!assetJSON || assetJSON.length === 0) {
            throw new Error(`The asset ${id} does not exist`);
        }        
        const asset = JSON.parse(assetJSON.toString());

        const callerMspId = await this.getCallerMspId(ctx);
        if (asset.Owner != callerMspId) {
            throw new Error(`${callerMspId} is not owner of given asset`);
        }
        return asset;
    }

    // getCallerMspId returns the caller of the chaincode
    async getCallerMspId(ctx) {
        return ctx.stub.getCreator().mspid;
    }

    // createId returns the id to the given social security number
    async createDhrId(socialSecId) {
        return crypto.createHash('sha1').update(socialSecId).digest('hex');
    }

    async createFieldFullName(fieldName, fieldType) {
        return fieldName.toLowerCase() + "_" + fieldType.toLowerCase();
    }
}

module.exports = AssetTransfer;
