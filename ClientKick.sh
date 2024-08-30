#!/usr/bin/env bash
# trying to drop & block clients after 5 mins, which is hopefully enough time to get cred hashes, ideal for wpa enterprise and open portal
# curl -X POST http://172.16.42.1:1471/api/login -d '{"username": "root", "password": "pazz"}'
token="gen from line above"
timeout="300"

clients=$(curl -X GET http://172.16.42.1:1471/api/pineap/clients -H "Authorization: Bearer $token" | grep -Po '.*(?=...$)' | cut -c 3- | sed 's/},{/\n/g' | sed 's/,/ /g' | awk '{print $1$3$6}')

for client in $clients; do 
        time=$(echo $client | sed 's/ /\n/g' | sed 's/""/ /g' | sed 's/"//g' | awk '{print $2}' | cut -c 11-)
        if (($time >= $timeout)); then
            mac=$(echo $client | sed 's/ /\n/g' | sed 's/""/ /g' | sed 's/"//g' | awk '{print $1}' | cut -c 5-)
            curl -X PUT http://172.16.42.1:1471/api/pineap/filters/client/list -H "Accept:application/json" -H "Authorization: Bearer $token" -d '{"mac": "'"$mac"'"}'
            curl -X DELETE http://172.16.42.1:1471/api/pineap/clients/kick -H "Accept:application/json" -H "Authorization: Bearer $token" -d '{"mac": "'"$mac"'"}'
        fi
    done
