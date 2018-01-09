import sys
import re

def string_found(string1, string2):
   if re.search(r"\b" + re.escape(string1) + r"\b", string2):
      return True
   return False

repw=[]
for l in open(sys.argv[1]):
    repw.append(l.rstrip())

outw=[]
for l in open(sys.argv[2]):
    outw.append(l.rstrip())

repw = filter(None, repw)
outw = filter(None, outw)

for l in open(sys.argv[3]):
    l_arr=l.rstrip().split("\t")
    a=l_arr[1].split(";")
    a = filter(None, a)
    ta=set()
    for x in a:
        for i in repw:
            if string_found(i.lower(), x.lower()):
                ta.add(x)
    ta2=set()
    for j in ta:
        for h in outw:
            if string_found(h.lower(), j.lower()):
                ta2.add(j)
    td=ta-ta2
    if(len(td)>0):
        print l.rstrip()+"\tyes\t"+",".join(td)
    else:
        print l.rstrip()+"\tnon\t"+",".join(td)
