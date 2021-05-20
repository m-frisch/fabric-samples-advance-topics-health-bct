/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class AssetTransfer extends Contract {

    async InitLedger(ctx) {
        // not neccessary
    }

    // GetAllPhiAssets returns all the PHI assets stored in the world state 
    // in given comma-separated channels.
    async GetAllPhiAssets(ctx, channels) {
        let allResults = [];
		for (const ch of channels.split(',')) {
            const assetJSON = await ctx.stub.invokeChaincode("phi", ["GetAllAssets", ""], ch.trim());
            allResults.push({ ChannelID: ch.trim(), Record: JSON.parse(Buffer.from(assetJSON.payload).toString('utf8'))});
		}
        return JSON.stringify(allResults);
    }

    // QueryAllPhiGeneric returns all the PHI assets in the world state
    // returned by given PHI-method in given comma-separated channels.
    async QueryAllPhiGeneric(ctx, chainCodeFunc, funcArgs, channels) {
        let allResults = [];
		for (const ch of channels.split(',')) {
            const assetJSON = await ctx.stub.invokeChaincode("phi", [chainCodeFunc, funcArgs], ch.trim());
            allResults.push({ ChannelID: ch.trim(), Record: JSON.parse(Buffer.from(assetJSON.payload).toString('utf8'))});
		}
        return JSON.stringify(allResults);
    }

    // QueryDhrByCustomFields returns all the CustomFields in DHR assets in the world state 
    // corresponding to the given field attributes in given comma-separated channels.
    async QueryDhrByCustomFields(ctx, fieldName, fieldType, value, channels) {
        let allResults = [];
		for (const ch of channels.split(',')) {
            const assetJSON = await ctx.stub.invokeChaincode("dhr", ["QueryAssetsByCustomField", fieldName, fieldType, value], ch.trim());
            allResults.push({ ChannelID: ch.trim(), Record: JSON.parse(Buffer.from(assetJSON.payload).toString('utf8'))});
		}
        return JSON.stringify(allResults);
    }
}

module.exports = AssetTransfer;
