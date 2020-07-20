# Ethereum-docker
Build Ethereum Private Network in Production with Docker, and without cluster.
Documentation used:
- https://github.com/ethereum/go-ethereum
- https://geth.ethereum.org/docs/
## Install prerequisites (nodes & local)
To enable the launchpad repository run:
```shell
sudo add-apt-repository -y ppa:ethereum/ethereum
```
After that you can install the stable version of Go Ethereum:
```shell
sudo apt-get update
sudo apt-get -y install ethereum
```

## Install prerequisites (local only)

__Clone the repo in the same folder than _blockchain-generator_ !__

Install pip
```shell
sudo apt-get install python3-pip
```
Then install virtualenv using pip
```shell
sudo pip install virtualenv
```
Now create a virtual environment
```shell
virtualenv venv
```
>  you can use any name insted of venv

Active your virtual environment:
```shell
source venv/bin/activate
```
then install requirements
```shell
pip install -r requirements.txt
```

## Required parameters

> Node_number: the number of node needed for the network.
2

> Network_path: The path from where nodes will be copied/
nodes

> Network_Id: the blockchain identifiant.
1234

> IP_Address: Enter the public/private ip address:
127.0.0.1 (it must be a private ip or public ip accessible in all nodes)

## install docker

## Usage:

From `https://get.docker.com`:
```shell
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

From `https://test.docker.com`:
```shell
curl -fsSL https://test.docker.com -o test-docker.sh
sh test-docker.sh
```
Start the script

```shell
sh start.sh
```
## Run nodes
```shell
docker-compose up
```
## Run nodes in separate terminal
For 2 nodes cases
Open first ternminal
```shell
docker-compose run node_1
```
Open second ternminal
```shell
docker-compose run node_2
```
To verify if it works, launch this command in local :

```bash
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":67}' http://[IP private/public address]:8503
```
