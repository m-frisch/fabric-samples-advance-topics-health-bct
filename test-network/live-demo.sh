
read -p "start recording with mic [Win+G]"

echo ""
read -p "# TC1 Patient registrieren"
# TC1 Patient registrieren

read -p "export socialSecId=123.456.789"
export socialSecId=123.456.789

read -p ". ./org3.sh"
. ./org3.sh

echo ""
read -p "# TC1.2 DHR registrieren"
# TC1.2 DHR registrieren

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\"]}' dhr"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'"]}' dhr

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\"]}' dhr"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'"]}' dhr

read -p "./query.sh '{\"function\":\"QueryAssetsBySocialSecId\",\"Args\":[\"'$socialSecId'\"]}' dhr channel3"
./query.sh '{"function":"QueryAssetsBySocialSecId","Args":["'$socialSecId'"]}' dhr channel3

read -p ". ./org4.sh"
. ./org4.sh

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\"]}' dhr"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'"]}' dhr

read -p "./query.sh '{\"function\":\"QueryAssetsBySocialSecId\",\"Args\":[\"'$socialSecId'\"]}' dhr channel3"
./query.sh '{"function":"QueryAssetsBySocialSecId","Args":["'$socialSecId'"]}' dhr channel3

read -p "./query.sh '{\"function\":\"QueryAssetsBySocialSecId\",\"Args\":[\"'$socialSecId'\"]}' dhr channel4"
./query.sh '{"function":"QueryAssetsBySocialSecId","Args":["'$socialSecId'"]}' dhr channel4

read -p "./query.sh '{\"function\":\"GetAssetHistory\",\"Args\":[\"a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b\"]}' dhr channel4"
./query.sh '{"function":"GetAssetHistory","Args":["a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b"]}' dhr channel4

echo ""
read -p "# TC2.2 Schreibvorgang registrieren"
# TC2.2 Schreibvorgang registrieren

read -p "export payload1=PHIentry1 && export payload2=PHIentry2"
export payload1=PHIentry1 && export payload2=PHIentry2

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\",\"'$payload1'\"]}' phi"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'","'$payload1'"]}' phi

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\",\"'$payload1'\"]}' phi"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'","'$payload1'"]}' phi

read -p ". ./org3.sh"
. ./org3.sh

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\",\"'$payload1'\"]}' phi"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'","'$payload1'"]}' phi

read -p "./invoke.sh '{\"function\":\"CreateAsset\",\"Args\":[\"'$socialSecId'\",\"'$payload2'\"]}' phi"
./invoke.sh '{"function":"CreateAsset","Args":["'$socialSecId'","'$payload2'"]}' phi

read -p "./query.sh '{\"function\":\"QueryAssetsByDhrId\",\"Args\":[\"a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b\"]}' phi channel3"
./query.sh '{"function":"QueryAssetsByDhrId","Args":["a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b"]}' phi channel3

read -p "./query.sh '{\"function\":\"GetAssetHistory\",\"Args\":[\"ac492377989b823b9603b75e15ebd909fa73fcfb\"]}' phi channel3"
./query.sh '{"function":"GetAssetHistory","Args":["ac492377989b823b9603b75e15ebd909fa73fcfb"]}' phi channel3

echo ""
read -p "# TC4.1 PII-Änderungen registrieren"
# TC4.1 PII-Änderungen registrieren

read -p "export fieldName=BirthYear && export fieldType=int && export fieldValue=2022"
export export fieldName=BirthYear && export fieldType=int && export fieldValue=2022

read -p ". ./org1.sh"
. ./org1.sh

read -p "CHANNEL_NAME=channel3"
CHANNEL_NAME=channel3

read -p "./invoke.sh '{\"function\":\"UpdateAsset\",\"Args\":[\"'$socialSecId'\",\"'$fieldName'\",\"'$fieldType'\",\"'$fieldValue'\"]}' dhr"
./invoke.sh '{"function":"UpdateAsset","Args":["'$socialSecId'","'$fieldName'","'$fieldType'","'$fieldValue'"]}' dhr

read -p "export fieldValue=2020"
export fieldValue=2020

read -p "./invoke.sh '{\"function\":\"UpdateAsset\",\"Args\":[\"'$socialSecId'\",\"'$fieldName'\",\"'$fieldType'\",\"'$fieldValue'\"]}' dhr"
./invoke.sh '{"function":"UpdateAsset","Args":["'$socialSecId'","'$fieldName'","'$fieldType'","'$fieldValue'"]}' dhr

read -p ". ./org3.sh"
. ./org3.sh

read -p "./invoke.sh '{\"function\":\"UpdateAsset\",\"Args\":[\"'$socialSecId'\",\"'$fieldName'\",\"'$fieldType'\",\"'$fieldValue'\"]}' dhr"
./invoke.sh '{"function":"UpdateAsset","Args":["'$socialSecId'","'$fieldName'","'$fieldType'","'$fieldValue'"]}' dhr

read -p "./query.sh '{\"function\":\"QueryAssetsBySocialSecId\",\"Args\":[\"'$socialSecId'\"]}' dhr channel3"
./query.sh '{"function":"QueryAssetsBySocialSecId","Args":["'$socialSecId'"]}' dhr channel3

read -p "export fieldValue=1980"
export fieldValue=1980

read -p "./invoke.sh '{\"function\":\"UpdateAsset\",\"Args\":[\"'$socialSecId'\",\"'$fieldName'\",\"'$fieldType'\",\"'$fieldValue'\"]}' dhr"
./invoke.sh '{"function":"UpdateAsset","Args":["'$socialSecId'","'$fieldName'","'$fieldType'","'$fieldValue'"]}' dhr

echo "sleep 5"
sleep 5

read -p "./query.sh '{\"function\":\"QueryAssetsBySocialSecId\",\"Args\":[\"'$socialSecId'\"]}' dhr channel3"
./query.sh '{"function":"QueryAssetsBySocialSecId","Args":["'$socialSecId'"]}' dhr channel3

read -p "./query.sh '{\"function\":\"GetAssetHistory\",\"Args\":[\"a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b\"]}' dhr channel3"
./query.sh '{"function":"GetAssetHistory","Args":["a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b"]}' dhr channel3

echo ""
read -p "# TC5 PHI abfragen"
# TC5 PHI abfragen

read -p "./init.sh 1"
./init.sh 1

read -p ". ./org1.sh"
. ./org1.sh

read -p "export pr_channels=\$(peer channel list|tail -n +2 | tr \"\n\" \",\" | sed 's/,$/ /' | tr \" \" \"\n\")"
export pr_channels=$(peer channel list|tail -n +2 | tr "\n" "," | sed 's/,$/ /' | tr " " "\n")

read -p "./query.sh '{\"function\":\"GetAllPhiAssets\",\"Args\":[\"'$pr_channels'\"]}' qry channel1"
./query.sh '{"function":"GetAllPhiAssets","Args":["'$pr_channels'"]}' qry channel1

read -p "export fieldName=Gender && export fieldType=bool && fieldValue=true"
export fieldName=Gender && export fieldType=bool && fieldValue=true

read -p "./query.sh '{\"function\":\"QueryDhrByCustomFields\",\"Args\":[\"'$fieldName'\",\"'$fieldType'\",\"'$fieldValue'\",\"'$pr_channels'\"]}' qry channel1"
./query.sh '{"function":"QueryDhrByCustomFields","Args":["'$fieldName'","'$fieldType'","'$fieldValue'","'$pr_channels'"]}' qry channel1

read -p "export fieldValue=false"
export fieldValue=false

read -p ". ./org2.sh"
. ./org2.sh

read -p "./query.sh '{\"function\":\"QueryDhrByCustomFields\",\"Args\":[\"'$fieldName'\",\"'$fieldType'\",\"'$fieldValue'\",\"'$pr_channels'\"]}' qry channel1"
./query.sh '{"function":"QueryDhrByCustomFields","Args":["'$fieldName'","'$fieldType'","'$fieldValue'","'$pr_channels'"]}' qry channel1

read -p "./query.sh '{\"function\":\"QueryAllPhiGeneric\",\"Args\":[\"QueryAssetsByDhrId\",\"a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b\",\"'$pr_channels'\"]}' qry channel1"
./query.sh '{"function":"QueryAllPhiGeneric","Args":["QueryAssetsByDhrId","a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b","'$pr_channels'"]}' qry channel1

read -p ". ./org3.sh"
. ./org3.sh

read -p "./query.sh '{\"function\":\"GetAllPhiAssets\",\"Args\":[\"'$pr_channels'\"]}' qry channel3"
./query.sh '{"function":"GetAllPhiAssets","Args":["'$pr_channels'"]}' qry channel3

echo ""
read -p "# TC3.2 DHR-Deaktivierung registrieren"
# TC3.2 DHR-Deaktivierung registrieren

read -p "./invoke.sh '{\"function\":\"DeleteAsset\",\"Args\":[\"'$socialSecId'\"]}' dhr"
./invoke.sh '{"function":"DeleteAsset","Args":["'$socialSecId'"]}' dhr

read -p "./query.sh '{\"function\":\"QueryAssetsByDhrId\",\"Args\":[\"a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b\"]}' phi channel3"
./query.sh '{"function":"QueryAssetsByDhrId","Args":["a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b"]}' phi channel3

read -p "./invoke.sh '{\"function\":\"DeleteAssets\",\"Args\":[\"'$socialSecId'\"]}' phi"
./invoke.sh '{"function":"DeleteAssets","Args":["'$socialSecId'"]}' phi

read -p ". ./org1.sh"
. ./org1.sh

read -p "CHANNEL_NAME=channel3"
CHANNEL_NAME=channel3

read -p "./invoke.sh '{\"function\":\"DeleteAsset\",\"Args\":[\"'$socialSecId'\"]}' dhr"
./invoke.sh '{"function":"DeleteAsset","Args":["'$socialSecId'"]}' dhr

read -p ". ./org3.sh"
. ./org3.sh

read -p "./invoke.sh '{\"function\":\"DeleteAsset\",\"Args\":[\"'$socialSecId'\"]}' dhr"
./invoke.sh '{"function":"DeleteAsset","Args":["'$socialSecId'"]}' dhr

read -p "./query.sh '{\"function\":\"QueryAssetsByDhrId\",\"Args\":[\"a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b\"]}' phi channel3"
./query.sh '{"function":"QueryAssetsByDhrId","Args":["a8a1f2e1067e87a50e42f1e943b86a1d12f3cb3b"]}' phi channel3

echo ""
read -p "# Visualisierungstools"
firefox

read -p "stop recording [Win+G]"
