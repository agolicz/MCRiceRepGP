import sys
import os

p_d={}

if(os.path.exists(sys.argv[1])):
    for l in open(sys.argv[1]):
        l_arr=l.rstrip().split("\t")
        g=l_arr[0]
        p_d[g]="\t".join(l_arr[1:-1])

for l in open(sys.argv[2]):
    l_arr=l.rstrip().split("\t")
    g=l_arr[0]
    if(g in p_d):
        print "\t".join(l_arr[:-1])+"\t"+p_d[g]
    else:
        print "\t".join(l_arr[:-1])+"\t.\t.\t.\t.\t.\t."
