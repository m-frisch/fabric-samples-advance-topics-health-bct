
if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage $0 <channelName> <orgNumber>"
  exit 1
fi

./network.sh createChannel -c $1
./addOrg.sh $1 $2

