import socket
import requests
import sys

def isOpen(ip,port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(2)
    try:
        result = sock.connect_ex((ip,port))
        if result == 0:
            return True
    except:
        return False
    return False

for num in range(1, 255):
    ip = f"192.168.0.{num}"
    connected = isOpen(ip, 80)
    sys.stdout.write(ip + ": ")
    try:
        res = requests.get(f"http://{ip}/", allow_redirects=True, verify=False, timeout=1)
        print(len(res.content))
    except:
        print("")
        pass