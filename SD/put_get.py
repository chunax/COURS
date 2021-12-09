
import threading
import json
import socket
import random
import sys
BUFFER_SIZE = 2048
port = int(sys.argv[1])

def send(data, ip, port):
    connexion_serveur = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    connexion_serveur.connect((ip, port))
    connexion_serveur.send(bytes(json.dumps(data),"utf-8"))
    connexion_serveur.close()


def receive():
    s      = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.bind(('', port))
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
    msg = json.loads(rec)
    if msg["type"] == "ack":
        print("put reussi")
    else:
        print("put fail")
    if msg["type"] == "answer":
        print("get reussi")
    else:
        print("get fail")
def main():
    if sys.argv[2] == 'put':
        command = sys.argv[2]
        key = int(sys.argv[3])
        val = int(sys.argv[4])
        idUniq = random.randint(0,65535)
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        ip = local_ip
        payload = {"type" : command, "key" : key, "val" : val, "idUniq" : idUniq, "ip" : ip, "port" : port }
        send(payload, sys.argv[5], int(sys.argv[6]))
    elif sys.argv[2] == 'get':
        command = sys.argv[2]
        key = int(sys.argv[3])
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        ip = local_ip
        payload = {"type" : command, "key" : key, "ip" : ip, "port" : port }
        send(payload, sys.argv[4], int(sys.argv[5]))
    while(receive()):
        print("en écoute")
    


if __name__ == '__main__':
    main()