import socket

HOST = '0.0.0.0'  
PORT = 1889        
blocksize = 4096
fp = open('bb2.txt', 'rb')
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    print('start listen...')
    s.listen()
    conn, addr = s.accept()
    with conn:
        while 1:
            buf = fp.read(blocksize)
            if not buf:
                fp.close()
                break
            conn.sendall(buf)
    print('end.')