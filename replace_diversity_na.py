import sys

p_s=set()

for l in open(sys.argv[1]):
    p_s.add(l.rstrip())

for l in open(sys.argv[2]):
    l_arr=l.rstrip().split("\t")
    g=l_arr[0]
    if(g not in p_s):
        l_arr[7]="NA"
    print "\t".join(l_arr)
