import json
from python_graphql_client import GraphqlClient
import time
import requests
import logging
import os

logging.basicConfig(filename='pinning.log', filemode='w', format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger()
logger.setLevel(logging.DEBUG) 
entityCount = 0
skip = 1000

ipfsRPCurl = "http://ipfs.aish.xyz:5001/api/v0/pin/add"

def initial_sync(client, minter):
    global entityCount
    global skip
    logger.info("Initial Syncing")
    query = """{
            accounts(where: {address: \"""" + minter + """\"}){
                hashCount
                hashes(first: 1000, skip: """ + str(entityCount) + """, orderby: timestamp){
                    hash
                }
            }
        }
    """
    try:
        response = client.execute(query=query)
    except:
        logger.critical("graphql api error")
    else:
        entityCount = int(response['data']['accounts'][0]['hashCount'])
        hashes = response['data']['accounts'][0]['hashes']
        for hash_ in hashes:
            _hash = hash_['hash']
            if(len(_hash) == 46):
                pin(_hash)

        if(entityCount > skip):
            while(True):
                query = """{
                            accounts(where: {address: \"""" + minter + """\"}){
                                hashes(first: 1000, skip: """ + str(skip) + """, orderby: timestamp){
                                    hash
                                }
                            }
                        }
                    """
                try:
                    response = client.execute(query=query)
                except:
                    logger.critical("graphql api error")
                else:
                    hashes = response['data']['accounts'][0]['hashes']
                    for hash_ in hashes:
                        _hash = hash_['hash']
                        if(len(_hash) == 46):
                            pin(_hash)
                    if(len(hashes) < skip):
                        break
            
def checkNewHashes(client, minter):
    global entityCount
    global skip
    query = """{
            accounts(where: {address: \"""" + minter + """\"}){
                hashCount
                hashes(first: 1000, skip: """ + str(entityCount) + """, orderby: timestamp){
                    hash
                }
            }
        }
    """

    try:
        response = client.execute(query=query)
    except:
        logger.critical("graphql api error")
    else:
        hashes = response['data']['accounts'][0]['hashes']
        if(len(hashes) == 0):
            logger.info("No new Hash.")
            return
        entityCount = int(response['data']['accounts'][0]['hashCount'])
        for hash_ in hashes:
            _hash = hash_['hash']
            if(len(_hash) == 46):
                pin(_hash)

def pin(_hash):
    global ipfsRPCurl
    try:
        params = {'arg': _hash}
        r = requests.post(url=ipfsRPCurl, params=params)
        logger.info("pined : " + _hash)
    except:
        logger.info("pin failed : " + _hash)

config = open('config.json', 'r')

data = json.load(config)

address = data["minter"]

url = "https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault"
client = GraphqlClient(endpoint=url)

while(True):
    try:
        r = requests.post(url="http://ipfs.aish.xyz:5001/api/v0/version")
    except:
        logger.debug("IPFS daemon not running.")
        time.sleep(1)
    else:
        if(r.status_code == 200):
            break
        
initial_sync(client, address)

logger.info("regular syncing")
while(True):
    checkNewHashes(client, address)
    time.sleep(10)
