if [ -z "$1" ]; then
  echo "Usage $0 <channelName> [<chainCodeName>]"
  echo "  Empty <chainCodeName> means \"dhr\" and \"phi\""
  exit 1
fi

CHANNEL_NAME=$1
LANG="javascript"

if [ -z "$2" ]; then
  CCN="dhr"
  ./network.sh deployCC -c $CHANNEL_NAME -ccn $CCN -ccp ../asset-transfer-$CCN/chaincode-$LANG -ccl $LANG
  CCN="phi"
  ./network.sh deployCC -c $CHANNEL_NAME -ccn $CCN -ccp ../asset-transfer-$CCN/chaincode-$LANG -ccl $LANG
else
  CCN=$2
  ./network.sh deployCC -c $CHANNEL_NAME -ccn $CCN -ccp ../asset-transfer-$CCN/chaincode-$LANG -ccl $LANG
fi
