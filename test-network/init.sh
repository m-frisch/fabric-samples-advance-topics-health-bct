if [ -z "$1" ]; then
  echo "Usage $0 <setsOf8dhrCount> [<ordererNumber>]"
  exit 1
fi

# create 2 DHR records containing 2 CustomFields and 2 PHI records
initDHR() {
    SLEEP_SEC=5
    
    DHRID=$1
    ./invoke.sh '{"function":"CreateAsset","Args":["'$DHRID'"]}' dhr $2
    sleep $SLEEP_SEC
    NUM=$(( ( RANDOM % 3 ) + 1 ))
    ./invoke.sh '{"function":"UpdateAsset","Args":["'$DHRID'","test","int","'$NUM'"]}' dhr $2
    sleep $SLEEP_SEC
    BOOL=$(( ( RANDOM % 2 ) ))
    ./invoke.sh '{"function":"UpdateAsset","Args":["'$DHRID'","test","bool","'$BOOL'"]}' dhr $2
    sleep $SLEEP_SEC

    LEN=$(( ( RANDOM % 50 ) + 10 ))
    PAYLOAD=`openssl rand -hex $LEN`
    ./invoke.sh '{"function":"CreateAsset","Args":["'$DHRID'","'$PAYLOAD'"]}' phi $2
    sleep $SLEEP_SEC
    LEN=$(( ( RANDOM % 50 ) + 10 ))
    PAYLOAD=`openssl rand -hex $LEN`
    ./invoke.sh '{"function":"CreateAsset","Args":["'$DHRID'","'$PAYLOAD'"]}' phi $2
    sleep $SLEEP_SEC
}

COUNTER=1
while [ $COUNTER -le $1 ]
do
    set -x

    . ./org3.sh channel3
    initDHR `openssl rand -hex 12` $2
    initDHR `openssl rand -hex 12` $2
    ./query.sh '{"function":"GetAllAssets","Args":[""]}' dhr channel3

    . ./org4.sh channel4
    initDHR $DHRID $2 #write identical DHR as in previous channel
    initDHR `openssl rand -hex 12` $2
    ./query.sh '{"function":"GetAllAssets","Args":[""]}' dhr channel4

    { set +x; } 2>/dev/null
    ((COUNTER++))
done

. ./org1.sh channel1
set -x
PR_CHANNELS=$(peer channel list|tail -n +2 | tr "\n" "," | sed 's/,$/ /' | tr " " "\n")
./query.sh '{"function":"GetAllPhiAssets","Args":["'$PR_CHANNELS'"]}' qry channel1
{ set +x; } 2>/dev/null