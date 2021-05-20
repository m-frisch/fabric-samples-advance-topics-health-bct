if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage $0 <channelName> <orgNumber>"
  exit 1
fi

CHANNEL_NAME=$1
export ARG3=$2

./network.sh createChannel -c $CHANNEL_NAME
./addOrg.sh $CHANNEL_NAME $ARG3
./prepCC.sh $CHANNEL_NAME # dhr & phi
