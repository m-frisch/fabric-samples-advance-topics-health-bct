cd ../explorer
docker-compose down -v
cd ../test-network
./network.sh down
docker rm -f $(docker ps -aq)
docker volume prune
rm *.json *.pb *.tar.gz