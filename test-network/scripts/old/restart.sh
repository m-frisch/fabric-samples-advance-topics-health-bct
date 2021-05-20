if [ -z "$1" ]; then
  echo "Usage $0 <channelName> [<orgNumber>]"
  exit 1
fi

./stop.sh
./start.sh $1 $2
