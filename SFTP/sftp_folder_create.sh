#!/bin/bash

filename="folder.config"
username=$(grep -o '"username"= "[^"]*' connection.config | grep -o '[^"]*$')
Server=$(grep -o '"Server"= "[^"]*' connection.config | grep -o '[^"]*$')
keypath=$(grep -o '"keypath"= "[^"]*' connection.config | grep -o '[^"]*$')
path=$(grep -o '"path"= "[^"]*' connection.config | grep -o '[^"]*$')

{
    echo -cd $path
    while read line
    do 
        echo "-mkdir $line"
    done < $filename
    echo "exit"
} | sftp -b - -i $keypath "$username@$server" 


