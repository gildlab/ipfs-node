import json
from python_graphql_client import GraphqlClient
import time
import os

entityCount = 0
skip = 1000

def initial_sync(client, minter):
    print("Initial Syncing")
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
    response = client.execute(query=query)
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
            response = client.execute(query=query)
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

    response = client.execute(query=query)
    hashes = response['data']['accounts'][0]['hashes']
    if(len(hashes) == 0):
        print("No new Hash.")
        return
    entityCount = int(response['data']['accounts'][0]['hashCount'])
    for hash_ in hashes:
        _hash = hash_['hash']
        if(len(_hash) == 46):
            pin(_hash)

def pin(_hash):
    try:
        os.system("docker-compose exec ipfs ipfs pin add " + _hash)
        print("pinning : " + _hash)
    except:
        print("pin failed")
config = open('config.json', 'r')

data = json.load(config)

address = data["minter"]

url = "https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault"
client = GraphqlClient(endpoint=url)

initial_sync(client, address)

print("regular syncing")
while(True):
    checkNewHashes(client, address)
    time.sleep(10)

