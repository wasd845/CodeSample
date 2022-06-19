# import urllib.request
import dns.resolver

for a in range(ord('a'), ord('z') + 1):
    for b in range(ord('a'), ord('z') + 1):
        for c in range(ord('a'), ord('z') + 1):
            for d in range(ord('a'), ord('z') + 1):
                name = chr(a) + chr(b) + chr(c) + chr(d) + '.usst.edu.cn'
                # f = urllib.request.urlopen(name)
                # if f.code ==200:
                #     print(name + ' exist!')
                try:
                    answer = dns.resolver.resolve(name, 'A', raise_on_no_answer=False)
                    # answer = dns.resolver.query('xxgk.usst.edu.cn', 'A', raise_on_no_answer=False)
                    if answer.rrset is not None:
                        print(answer.rrset)
                except dns.resolver.NXDOMAIN:
                    continue