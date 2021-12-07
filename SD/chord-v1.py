#!/usr/bin/python3

import threading
import json
import socket
import random
import sys

BUFFER_SIZE = 2048

nbGet = 0
nbPut = 0
nbJoin = 0
nbGestion = 0

table_voisinage = {"precedent" : [],"suivant" : []}
data = {}
my_key = None
my_ip = None
my_port = None
is_first = False

def send(data, ip, port):
    connexion_serveur = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    connexion_serveur.connect((ip, port))
    connexion_serveur.send(bytes(json.dumps(data),"utf-8"))
    connexion_serveur.close()


def is_resp(key):
    if is_between(key):
        True
    else:
        False


def get_resp(key,ip,port):
    resp = is_resp(key)
    if resp:
        jsonFrame = { "type":"accept", "key":key }
        send(jsonFrame, ip, port)
    else:
        jsonFrame = { "type":"get_resp", "key":key, "ip":ip, "port":port }
        send(jsonFrame, ip, port)

def is_between(key):
    if table_voisinage["precedent"][0] > my_key:
        if key > table_voisinage["precedent"][0] or key < my_key:
            return True
        else:
            return False
    else:
        if key > table_voisinage["precedent"][0] and key < my_key:
            return True
        else:
            return False
def is_between_suivant(key):
    if table_voisinage["suivant"][0] < my_key:
        if key < table_voisinage["suivant"][0] or key > my_key:
            return True
        else:
            return False
    else:
        if key < table_voisinage["suivant"][0] and key > my_key:
            return True
        else:
            return False


def creation_data(key):
    new_data = {}
    for cle, valeur in data.items():
        if is_between(cle):
            new_data[cle] = valeur
    for keys in new_data.keys():
        data.pop(keys)
    return new_data

def gestionJoin(payload):
    global my_key, table_voisinage, is_first
    '''key = payload["key"]
    get_resp(key, payload["ip"], payload["port"])'''
    if payload["key"] == my_key:
        print("reject sent")
        jsonFrame = { "type" : "reject", "key" : payload["key"] }
        send(jsonFrame, payload["ip"], payload["port"])
    elif is_between(payload["key"]) or is_first:
        print("accept et init")
        # jsonFrame = { "type" : "accept", "key" : payload["key"] }
        # send(jsonFrame, payload["ip"], payload["port"])
        new_data_table = creation_data(payload["key"])
        new_table_voisinage = {"precedent" : table_voisinage["precedent"], "suivant" : [my_key, my_ip, my_port]}
        print(new_table_voisinage)
        jsonInitFrame = { "type" : "init", "key" : payload["key"], "data" : new_data_table, "tv": new_table_voisinage }
        if is_first:
            table_voisinage["precedent"] = [payload["key"], payload["ip"], payload["port"]]
            table_voisinage["suivant"] = [payload["key"], payload["ip"], payload["port"]]
        else:
            table_voisinage["precedent"] = [
                payload["key"], payload["ip"], payload["port"]]
        print("ma table")
        print(table_voisinage)
        is_first = False
        send(jsonInitFrame, payload["ip"], payload["port"])

    else:
        print("envoie au précedent")
        print(payload)
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])


def gestionPut(payload):
    if payload["key"] == my_key:
        data[my_key] = payload["val"]
        jsonFrame = {"type" : "ack", "ok": "ok", "idUniq" : payload["idUniq"]}
        send(jsonFrame, payload["ip"], payload["port"])
    elif is_between(payload["key"]):
        data[payload["key"]] = payload["val"]
        print(data)
        jsonFrame = {"type" : "ack", "ok": "ok", "idUniq" : payload["idUniq"]}
        send(jsonFrame, payload["ip"], payload["port"])
    else:
        print("envoie au précedent")
        print(payload)
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])


def gestionGet(payload):
    if payload["key"] == my_key:
        val = None
        for cle, valeur in data.items():
            if cle == payload["key"]:
                val = valeur
                break
        jsonFrame = {"type" : "answer", "key" : my_key, "val" : val}
        send(jsonFrame, payload["ip"], payload["port"])
    elif is_between(payload["key"]):
        val = None
        for cle, valeur in data.items():
            if cle == payload["key"]:
                val = valeur
                break
        jsonFrame = {"type" : "answer", "key" : my_key, "val" : val}
        send(jsonFrame, payload["ip"], payload["port"])
    
    else:
        print("envoie au précedent")
        print(payload)
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])

    
def gestionNew(payload):
    if is_between_suivant(payload["key"]):
        table_voisinage["suivant"][0] = payload["key"]
        table_voisinage["suivant"][1] = payload["ip"]
        table_voisinage["suivant"][2] = payload["port"]
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])
    elif is_between(payload["key"]):
        table_voisinage["precedent"][0] = payload["key"]
        table_voisinage["precedent"][1] = payload["ip"]
        table_voisinage["precedent"][2] = payload["port"]
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])
    elif payload["key"] == my_key:
        pass
    else:
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])



def traitementPayload(payload):
    global my_key, table_voisinage, is_first
    command = payload["type"]
    if command == 'join':
        gestionJoin(payload)
    if command == 'reject':
        print("reject reçu")
        test_key = random.randint(0,65535)
        payload = {"type" : "join", "key" : test_key, "ip" : my_ip, "port" : my_port }
        send(payload, sys.argv[2], int(sys.argv[3]))
    if command == 'init':
        print("init reçu")
        my_key = payload["key"]
        data = payload["data"]
        table_voisinage = payload["tv"]
        print("data :")
        print(data)
        print("table de vosinage :")
        print(table_voisinage)
        jsonFrame = { "type" : "new", "key": my_key, "ip" : my_ip, "port" : my_port}
        send(jsonFrame, table_voisinage["precedent"][1], table_voisinage["precedent"][2])
    if command == 'new':
        gestionNew(payload)
    if command == 'put':
        gestionPut(payload)
    if command == 'get':
        gestionGet(payload)



        
        


def receive():
    s      = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(('', my_port))
    except socket.error as e:
        print("Erreur écoute sur le port de base")
    s.listen(2)
    try:
        client, addr = s.accept()
    except socket.error:
        print("Erreur accept")
    rec = ''
    allReceived = False
    try:
        while(not allReceived):
            incomingData = client.recv(BUFFER_SIZE).decode()
            if(incomingData == ''):
                allReceived = True
            else:
                rec += incomingData
    except socket.error as e:
        print("Erreur réception donnée")
        s.close()
        return
    print("payload reçu : ")
    print(rec)
    payload = json.loads(rec)
    traitementPayload(payload)



def main():
    global my_port, my_ip, my_key, is_first
    my_port = int(sys.argv[1])
    hostname = socket.gethostname()
    local_ip = socket.gethostbyname(hostname)
    my_ip = local_ip
    test_key = random.randint(0,65535)
    if len(sys.argv) == 2:
        is_first = True
        my_key = test_key
    if is_first:
        print(my_key)
        table_voisinage["precedent"].append(my_key)
        table_voisinage["precedent"].append(my_ip)
        table_voisinage["precedent"].append(my_port)
        table_voisinage["suivant"].append(my_key)
        table_voisinage["suivant"].append(my_ip)
        table_voisinage["suivant"].append(my_port)
        print(table_voisinage)
    else:
        print(test_key)
        payload = {"type" : "join", "key" : test_key, "ip" : my_ip, "port" : my_port }
        send(payload, sys.argv[2], int(sys.argv[3]))
    while(True):
        receive()
        print(table_voisinage)


if __name__ == '__main__':
    main()
