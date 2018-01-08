import sys

repw=[]
for l in open(sys.argv[1]):
    repw.append(l.rstrip())

outw=[]
for l in open(sys.argv[2]):
    outw.append(l.rstrip())

for l in open(sys.argv[3]):
    l_arr=l.rstrip().split("\t")
    a=l_arr[1].split(";")
    ta=set()
    for x in a:
        for i in repw:
            if i.lower() in x.lower():
                ta.add(x)
    ta2=set()
    for j in ta:
        for h in outw:
            if h.lower() in j.lower():
                ta2.add(j)
    td=ta-ta2
    if(len(td)>0):
        print l.rstrip()+"\tyes\t"+",".join(td)
    else:
        print l.rstrip()+"\tnon\t"+",".join(td)
