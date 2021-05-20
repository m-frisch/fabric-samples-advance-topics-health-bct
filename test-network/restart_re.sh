CHANNEL_NAME="channel1"

./stop.sh
./network.sh up createChannel -c $CHANNEL_NAME

scripts/addOrderer.sh # ineffective

export ARG3=""
./prepCC.sh $CHANNEL_NAME qry
./prepCC.sh $CHANNEL_NAME # dhr & phi

cd ../explorer
docker-compose up -d
cd ../test-network