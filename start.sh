#!/usr/local/bin/bash
echo $BASH_VERSION    
#title           : start.sh
#description     : Build private containerized ethereum blockchain.
#author		     : ET-TAOUSY Zouhair
#date            : 20111101
#version         : 0.4    
#usage		     : sh start.sh
#bash_version    : 4.1.5(1)-release
#==========================================================================

nodes_path="./"
number_node=4
chain_id="1234"
declare -A addresses
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
getIpAddress(){
    for i in `seq 1 $number_node`;
    do
        echo "Enter the public/private ip address of node $i:"
        read ip_address
        addresses[$i]=$ip_address 
    done
}
getNumberNodes number_node
getNodesPath nodes_path
getChainId chain_id
getIpAddress addresses

# Generate the cryptographic material for all nodes
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
        cat $keys_path/key | grep pub -A 5 | tail -n +2 | tr -d "\n[:space:]:" | sed "s/^04//" > $keys_path/pub.key
        cat $keys_path/key | grep priv -A 3 | tail -n +2 | tr -d "\n[:space:]:" | sed "s/^00//" > $keys_path/priv.key
    done
    python3 py/genesisGen.py "$nodes_path" "$number_node" "$chain_id"
}
# Import the generated nodes cryptographics materials to the blockchain network
importNodes(){
    for i in `seq 1 $number_node`;
    do
        path="$nodes_path/node_$i"
        geth --nousb account import  --datadir "$path/data" --password "$path/keys/password" "$path/keys/priv.key"
    done
}
# Initialise the nodes data folder with genesis block configuration
initBC(){
    for i in `seq 1 $number_node`;
    do
        path="$nodes_path/node_$i"
        geth --nousb --datadir  "$path/data" init "$nodes_path/genesis.json"
    done
}

# Generate the enodes keys to sync nodes each others
getEnodesByIndex(){
    enodes=()
    for i in `seq 1 $number_node`;
    do
        if [ "$i" != "$1" ]
        then
            port=$((30312+$i))
            data_path="$nodes_path/node_$i/data"
            path="$nodes_path/node_$i/keys/pub.key"
            line=$(head -n 1  "$path")
            lf="$(($number_node-1))"
            read ip_address
            if [ "$i" -eq "$number_node" ]
            then
                enodes+='"enode://'$line'@'${addresses[${i}]}':'$port'"'$'\r'
            elif [ "$number_node" -eq "$1" ] && [ "$i" -eq "$lf" ]
            then
                enodes+='"enode://'$line'@'${addresses[${i}]}':'$port'"'$'\r'   
            else
                enodes+='"enode://'$line'@'${addresses[${i}]}':'$port'",'$'\r'
            fi    
        fi    
    done
    echo "${enodes[@]}"
}
# Save enodes in every node's data folder & export docker-compose file
saveEnodes(){
    for i in `seq 1 $number_node`;
    do
        data_path="$nodes_path/node_$i/data"
        echo "[" > "$data_path/static-nodes.json"
        enodes=$(getEnodesByIndex $i)
        printf "%s\n" "${enodes[@]}" >> "$data_path/static-nodes.json"
        echo "]" >> "$data_path/static-nodes.json"
    done
    python3 py/yamlGen.py "$nodes_path" "$number_node" "$chain_id"

}

createNodes
importNodes
initBC
echo "Type nodes ip addresses: node1_ipaddress enter...node2_ipaddress..."
saveEnodes
