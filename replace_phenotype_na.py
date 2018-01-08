import sys

p_d={}

for l in open(sys.argv[1]):
    l_arr=l.rstrip().split("\t")
    p_d[l_arr[0]]=l_arr[5]

for l in open(sys.argv[2]):
    l_arr=l.rstrip().split("\t")
    g=l_arr[0]
    if(g not in p_d):
        l_arr[3]="NA"
    print "\t".join(l_arr)
