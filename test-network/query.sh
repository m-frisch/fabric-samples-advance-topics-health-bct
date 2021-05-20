if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Usage $0 <functionArgs> <chainCodeName> <channelName>"
  echo "  Example of <functionArgs>:"
  echo "    '{\"function\":\"GetAllAssets\",\"Args\":[\"channel4,channel3\"]}'"
  echo "    Query all channels as follows:"
  echo "    . ./org1.sh channel1 && peer channel list|tail -n +2 | tr \"\n\" \",\" | sed 's/,$/ /' | tr \" \" \"\n\""
  exit 1
fi

set -x
peer chaincode query -C $3 -n $2 -c $1 |jq .
{ set +x; } 2>/dev/null
