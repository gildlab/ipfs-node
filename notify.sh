#!/bin/sh

SCRIPTDIR=`cd "$(dirname "$0")" && pwd`

tnotify(){
    . $SCRIPTDIR/.env
    message=$1
    token=$TELEGRAM_BOT_TOKEN
    chatid=$TELEGRAM_CHAT_ID
    curl -s -X POST https://api.telegram.org/bot$token/sendMessage?parse_mode=HTML -d chat_id=$chatid -d text="$message"
}

getNgrokEndpoints(){
    . $SCRIPTDIR/.env
    sleep 10s
    # Making API call
    response=$(curl -s -H "Authorization: Bearer $NGROK_API_KEY" -H "Ngrok-Version: 2" https://api.ngrok.com/endpoints)
    echo $response
    # loop over json array and send to telegram
    for i in $(jq -n "$response" | jq -rc '.endpoints[] | {public_url, proto}')
    do
        tnotify $i
    done
}

getNgrokEndpoints
