import sys

for l in open(sys.argv[1]):
    l_arr=l.rstrip().split("\t")
    tl=[]
    for x in l_arr:
        if(x=="1"):
            tl.append("yes")
        elif(x=="0"):
            tl.append("no")
        else:
            tl.append(x)
    print "\t".join(tl)
