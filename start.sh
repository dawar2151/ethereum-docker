#!/bin/bash
nodes_path="./"
number_node=4
chain_id="1114"

getNumberNodes(){
    echo "Enter number of nodes:"
    read number_node
    eval  "$1=$number_node" 
}
getNodesPath(){
    echo "Enter the path where nodes will be created:"
    read nodes_path
    eval  "$1=$nodes_path" 
    
}
getChainId(){
    echo "Enter the chain ID:"
    read chain_id
    eval  "$1=$chain_id" 
    
}
getNumberNodes number_node
getNodesPath nodes_path
getChainId chain_id
createNodes(){
    if [ -d "$nodes_path" ]; then rm -Rf $nodes_path; fi
    for i in `seq 1 $number_node`;
    do
        mkdir -p "$nodes_path/node_$i"
        mkdir -p "$nodes_path/node_$i/keys"
        mkdir -p "$nodes_path/node_$i/data"
        keys_path="$nodes_path/node_$i/keys"
        openssl ecparam -name secp256k1 -genkey -noout | openssl ec -text -noout > $keys_path/key
        echo "node_$i" > $keys_path/password
        cat $keys_path/key | grep pub -A 5 | tail -n +2 | tr -d '\n[:space:]:' | sed 's/^04//' > $keys_path/pub.key
        cat $keys_path/key | grep priv -A 3 | tail -n +2 | tr -d '\n[:space:]:' | sed 's/^00//' > $keys_path/priv.key
    done
    python3 genesisGen.py "$nodes_path" "$number_node" "$chain_id"
}
importNodes(){
    for i in `seq 1 $number_node`;
    do
        path="$nodes_path/node_$i"
        geth --nousb account import  --datadir "$path/data" --password "$path/keys/password" "$path/keys/priv.key"
    done
}
initBC(){
    for i in `seq 1 $number_node`;
    do
        path="$nodes_path/node_$i"
        geth --nousb --datadir  "$path/data" init "$nodes_path/genesis.json"
    done
}
initBootNode(){
    bootnode -genkey "$nodes_path/boot.key"
    bootnode -nodekey "$nodes_path/boot.key" -writeaddress > "$nodes_path/bootEnode.key"
}

saveStartNodes(){
    for i in `seq 1 $number_node`;
    do
        path="$nodes_path/node_$i"
        line=$(head -n 1  "$nodes_path/bootEnode.key")
        port=$((30312+$i))
        rpc_port=$((8501+$i))
        echo $port
        cmd="geth --nousb --datadir node_$i/data --syncmode full --port $port --rpc --rpcaddr \"0.0.0.0\" --rpccorsdomain \"*\" --gasprice 0 --rpcport $rpc_port --rpcapi db,eth,net,web3,admin,personal,miner,signer:insecure_unlock_protect --bootnodes enode://$line@10.0.101.4:30310 --networkid $chain_id  --unlock 0 --password node_$i/keys/password --mine --allow-insecure-unlock"
        if [ $i = 1 ]
        then
            echo $cmd > "$nodes_path/startNodes"
        else
            echo $cmd >> "$nodes_path/startNodes"
        fi
    done
}
createNodes
importNodes
initBC
initBootNode
saveStartNodes
