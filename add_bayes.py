import sys
r_s=set()
for l in open(sys.argv[1]):
    r_s.add(l.rstrip())

for l in open(sys.argv[2]):
    l_arr=l.rstrip().split("\t")
    if(l_arr[0] in r_s):
        print l.rstrip()+"\tpos"
    else:
        print l.rstrip()+"\tnon"

