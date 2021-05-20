# Fabric Advance Topics - Health BCT

The basic contents are based on the implementation of Aditya Joshi's Fabric Advanced Topics.

https://adityaajoshi.medium.com

https://github.com/adityajoshi12/fabric-samples-advance-topics

# Preparation of environment in Ubuntu

## Software installation
```
sudo apt-get -y install git curl docker docker-compose jq nodejs npm
```

## Docker configuration
```
sudo systemctl start docker && sudo systemctl enable docker
sudo usermod -a -G docker bct
sudo chmod +x /usr/bin/docker-compose
sudo reboot
```

## Hyperledger Fabric Samples & binaries latest download
```
sudo curl -sSL https://bit.ly/2ysbOFE | bash -s
export PATH=~/fabric-samples/bin:$PATH
```

## Clone repository
```
git clone https://github.com/m-frisch/fabric-samples-advance-topics-health-bct
```

## Start network
```
cd fabric-samples-advance-topics-health-bct/test-network/
./restart_re.sh && ./prepare_pr.sh
```
