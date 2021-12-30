#!/usr/bin/python3

import threading
import json
import socket
import random
import sys

BUFFER_SIZE = 2048

nbGet = 0
nbPut = 0
nbGestion = 0

table_voisinage = {"precedent" : [],"suivant" : []}
data = {}
my_key = None
my_ip = None
my_port = None
is_first = False
quit = False
firstQuit = True

def send(data, ip, port):
    connexion_serveur = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        connexion_serveur.connect((ip, port))
    except socket.error as e:
        try:
            connexion_serveur.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            connexion_serveur.connect((ip, port))
        except socket.error as e:
            print("Erreur send")
            connexion_serveur.close()
            return
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
        if is_between(key):
            new_data[cle] = valeur
    for keys in new_data.keys():
        data.pop(keys)
    return new_data

def gestionJoin(payload):
    global my_key, table_voisinage, is_first,nbGestion
    nbGestion += 1
    if payload["key"] == my_key:
        print("reject sent")
        jsonFrame = { "type" : "reject", "key" : payload["key"] }
        nbGestion += 1
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
        nbGestion += 1
        send(jsonInitFrame, payload["ip"], payload["port"])

    else:
        print("envoie au précedent")
        print(payload)
        nbGestion += 1
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])


def gestionPut(payload):
    global nbPut, nbGestion
    nbPut += 1
    if payload["key"] == my_key:
        data[my_key] = payload["val"]
        jsonFrame = {"type" : "ack", "ok": "ok", "idUniq" : payload["idUniq"]}
        nbGestion += 1
        send(jsonFrame, payload["ip"], payload["port"])
    elif is_between(payload["key"]):
        data[payload["key"]] = payload["val"]
        print(data)
        jsonFrame = {"type" : "ack", "ok": "ok", "idUniq" : payload["idUniq"]}
        nbGestion += 1
        send(jsonFrame, payload["ip"], payload["port"])
    else:
        print("envoie au précedent")
        print(payload)
        nbPut += 1
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])


def gestionGet(payload):
    global nbGet,nbGestion
    nbGet += 1
    if payload["key"] == my_key:
        val = None
        for cle, valeur in data.items():
            if cle == payload["key"]:
                val = valeur
                break
        jsonFrame = {"type" : "answer", "key" : my_key, "val" : val}
        nbGestion += 1
        send(jsonFrame, payload["ip"], payload["port"])
    elif is_between(payload["key"]):
        val = None
        for cle, valeur in data.items():
            if cle == payload["key"]:
                val = valeur
                break
        jsonFrame = {"type" : "answer", "key" : payload["key"], "val" : val}
        nbGestion += 1
        send(jsonFrame, payload["ip"], payload["port"])
    
    else:
        print("envoie au précedent")
        print(payload)
        nbGet += 1
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])

    
def gestionNew(payload):
    global nbGestion
    nbGestion += 1
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
        nbGestion += 1
        send(payload, table_voisinage["precedent"][1], table_voisinage["precedent"][2])

def gestionQuit(payload):
    global firstQuit, nbGestion, nbGet, nbPut
    if payload["msgGet"] == 0 and payload["msgPut"] == 0 and payload["msgGest"] == 0:
        jsonQuit = {"type" : "quit", "msgGet" : nbGet, "msgPut" : nbPut, "msgGest" : nbGestion}
        firstQuit = False
        send(jsonQuit,table_voisinage["precedent"][1], table_voisinage["precedent"][2])
        return False
    else:
        newMsgGet = payload["msgGet"] + nbGet
        newMsgPut = payload["msgPut"] + nbPut
        newMsgGest = payload["msgGest"] + nbGestion
        if firstQuit:
            jsonQuit = {"type" : "quit", "msgGet" : newMsgGet, "msgPut" : newMsgPut, "msgGest" : newMsgGest}
            send(jsonQuit, table_voisinage["precedent"][1], table_voisinage["precedent"][2])
            return True
        else:
            print("Total messages : ")
            print("MsgGet : " + str(payload["msgGet"]))
            print("MsgPut : " + str(payload["msgPut"]))
            print("MsgGest : " + str(payload["msgGest"]))
            return True


def traitementPayload(payload):
    global my_key, table_voisinage, is_first
    command = payload["type"]
    if command == 'join':
        gestionJoin(payload)
        return False
    if command == 'reject':
        print("reject reçu")
        test_key = random.randint(0,65535)
        payload = {"type" : "join", "key" : test_key, "ip" : my_ip, "port" : my_port }
        send(payload, sys.argv[2], int(sys.argv[3]))
        return False
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
        return False
    if command == 'new':
        gestionNew(payload)
        return False
    if command == 'put':
        gestionPut(payload)
        return False
    if command == 'get':
        gestionGet(payload)
        return False
    if command == 'quit':
        return gestionQuit(payload)
        



        
        


def receive():
    global quit
    s      = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(('', my_port))
    except socket.error as e:
        try:
            s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            s.bind(('', my_port))
        except socket.error as e:
            print("Erreur écoute sur le port de base")
            s.close()
            return
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
    quit = traitementPayload(payload)
    s.close()
    



def main():
    global my_port, my_ip, my_key, is_first,quit
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
    while(not quit):
        receive()
        print(table_voisinage)


if __name__ == '__main__':
    main()
