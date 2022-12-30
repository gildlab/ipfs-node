import json
from python_graphql_client import GraphqlClient
import time
import requests
import logging
import os

logging.basicConfig(filename='pin.log', filemode='w', format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
entityCount = 0
skip = 100

IS_DOCKER = os.environ.get('INSIDE_DOCKER', False)

ipfsURL = "localhost"
if IS_DOCKER:
    ipfsURL = 'ipfs'


def initial_sync(client, deployer):
    global entityCount
    global skip
    logger.info("Initial Syncing")
    query = """
        {
            deployer(id: \"""" + deployer + """\"){
                hashes(first:100, skip: 0, orderBy:timestamp, orderDirection: asc){
                    hash
                }
                hashCount
            }
        }
    """

    try:
        response = client.execute(query=query)
    except:
        logger.critical("graphql api error")
    else:
        entityCount = int(response['data']['deployer']['hashCount'])
        hashes = response['data']['deployer']['hashes']
        for hash_ in hashes:
            _hash = hash_['hash']
            if len(_hash) == 46:
                pin(_hash)

        if entityCount > skip:
            while True:
                query = """
                    {
                       deployer(id: \"""" + deployer + """\"){
                            hashes(first:100, skip: """ + skip + """, orderBy:timestamp, orderDirection: asc){
                                hash
                            }
                            hashCount
                        }
                    }
                """
                try:
                    response = client.execute(query=query)
                except:
                    logger.critical("graphql api error")
                else:
                    hashes = response['data']['deployer']['hashes']
                    for hash_ in hashes:
                        _hash = hash_['hash']
                        if len(_hash) == 46:
                            pin(_hash)
                    if len(hashes) < skip:
                        break
                    else:
                        skip = skip + 100


def checkNewHashes(client, deployer):
    global entityCount
    global skip
    query = """
        {
            deployer(id: \"""" + deployer + """\"){
                hashes(first:100, skip: """ + str(entityCount) + """, orderBy:timestamp, orderDirection: asc){
                    hash
                }
                hashCount
            }
        }
    """

    try:
        response = client.execute(query=query)
    except:
        logger.critical("graphql api error")
    else:
        hashes = response['data']['deployer']['hashes']
        if len(hashes) == 0:
            logger.info("No new Hash.")
            return
        entityCount = int(response['data']['deployer']['hashCount'])
        for hash_ in hashes:
            _hash = hash_['hash']
            if len(_hash) == 46:
                pin(_hash)

def pin(_hash):
    try:
        params = {'arg': _hash, 'to-files': '/'}
        pin_response = requests.post(url="http://" + ipfsURL + ":5001/api/v0/pin", params=params)
        logger.info("pined : " + _hash)
    except:
        logger.critical("pin failed : " + _hash)


config = open('config.json', 'r')

data = json.load(config)

deployer = data["deployer"]

url = "https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault"
client = GraphqlClient(endpoint=url)

while True:
    try:
        r = requests.post(url="http://" + ipfsURL + ":5001/api/v0/version")
    except:
        logger.debug("IPFS daemon not running.")
        time.sleep(1)
    else:
        if r.status_code == 200:
            break

files = {'file': open('ReceiptMetadata.json', 'rb')}
file_upload = requests.post(url="http://" + ipfsURL + ":5001/api/v0/add?to-files=/", files=files);
logger.info("ReceiptMetadata pinned : " + file_upload.text)


initial_sync(client, deployer)

logger.info("regular syncing")
while True:
    checkNewHashes(client, deployer)
    time.sleep(10)
