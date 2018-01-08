import sys

#1 file with mappings
#2 file with expression values

s_l=[]
c_l=[]
for l in open(sys.argv[1]):
    l_arr=l.rstrip().split("\t")
    s_l.append(l_arr[0])
    c_l.append(l_arr[1])

for l in open(sys.argv[2]):
    l_arr=l.rstrip().split("\t")
    if(l_arr[0]=="GENE"):
        print l.rstrip()+"\tHIGHEST\tHIGHEST_TYPE\tVALUE"
        continue
    n=[]
    for x in l_arr[1:]:
        n.append(float(x))
    mx=max(n)
    if(mx <0.1):
        print l.rstrip()+"\tNA\tNA\tNA"
        continue
    idx=n.index(mx)
    print l.rstrip()+"\t"+s_l[idx]+"\t"+c_l[idx]+"\t"+str(round(mx,2))
    
