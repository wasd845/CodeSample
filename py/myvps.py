import socket

HOST = '0.0.0.0'
PORT = 1890
blocksize = 4096
fp = open('config.txt', 'rb+')
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        while 1:
            data = conn.recv(blocksize)
            # print(data)
            fp.write(data)
            if not data:
                break
    print('end.')