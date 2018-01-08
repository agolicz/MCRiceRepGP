import sys

p_s=set()

for l in open(sys.argv[1]):
    p_s.add(l.rstrip())

for l in open(sys.argv[2]):
    l_arr=l.rstrip().split("\t")
    g=l_arr[0]
    if(g in p_s):
        l_arr[1]="NA"
        l_arr[2]="NA"
    print "\t".join(l_arr)
