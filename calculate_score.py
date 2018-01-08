import sys
import math
import numpy
import os.path

#1 file with expression profile
#2 file with phenotypes
#3 file wirth signle homologs
#4 fiel with communities
#5 file with SNP density
#6 file with id map
#7 expression and mutant type, either "rep" or "veg"
#8 parameter values coding
#9 parameter values non-coding

t_category=sys.argv[7]

pvals_cod=[]

for x in sys.argv[8].split(","):
    pvals_cod.append(float(x))

pvals_nc=[]

for x in sys.argv[9].split(","):
    pvals_nc.append(float(x))
 
#Expression values
g_d={}
mct_d={}

for l in open(sys.argv[1]):
    l_arr=l.rstrip().split("\t")
    if(l_arr[0]=="GENE"):
        imc=l_arr.index("HIGHEST_TYPE")
        imct=l_arr.index("HIGHEST")
        imcvr=l_arr.index("VALUE")
        continue
    g=l_arr[0]
    mc=l_arr[imc]
    mct=l_arr[imct]
    mct_d[g]=mct
    if(l_arr[imcvr]=="NA"):
        mcvr=0
    else:
        mcvr=float(l_arr[imcvr])
    mcv=mcvr
    g_d[g]=[]
    if(mc==t_category):
        g_d[g].append(1)
    else:
        g_d[g].append(0)
    g_d[g].append(mcv)

#Mutant phenotype
p_d={}
if(os.path.exists(sys.argv[2])):
    for l in open(sys.argv[2]):
        l_arr=l.rstrip().split("\t")
        gn=l_arr[0]
        pt=l_arr[5]
        pta=pt.split(",")
        if(len(pta)==1 and pt.startswith(t_category)):
            p_d[gn]=t_category
for x in g_d:
    if(x in p_d):
        g_d[x].append(1)
    else:
        g_d[x].append(0)

#Homology analysis
h_d={}

for l in open(sys.argv[3]):
    l_arr=l.rstrip().split("\t")
    gn=l_arr[0]
    hy=l_arr[2]
    if(hy=="yes"):
        h_d[gn]="yes"
for x in g_d:
    if(x in h_d):
        g_d[x].append(1)
    else:
        g_d[x].append(0)

#Coexpression analysis
cg_s=set()
cgrep_s=set()

for l in open(sys.argv[4]):
    l_arr=l.rstrip().split("\t")
    gl=l_arr[1]
    ot=l_arr[3]
    for x in gl.split(","):
        cg_s.add(x)
    if(ot == "yes"):
        for x in gl.split(","):
            cgrep_s.add(x)
for x in g_d:
    if(x in cg_s):
        g_d[x].append(1)
    else:
        g_d[x].append(0)
    if(x in cgrep_s):
        g_d[x].append(1)
    else:
        g_d[x].append(0)

#SNP density
da=[]

for l in open(sys.argv[5]):
    l_arr=l.rstrip().split("\t")
    da.append(float(l_arr[1]))

coff=0.5*numpy.median(da)

ld_d={}
for l in open(sys.argv[5]):
    l_arr=l.rstrip().split("\t")
    gn=l_arr[0]
    sden=float(l_arr[1])
    if(sden < coff):
        ld_d[gn]=sden
for x in g_d:
    if(x in ld_d):
        g_d[x].append(1)
    else:
        g_d[x].append(0)

#MSU annot
of_d={}

for l in open(sys.argv[6]):
    l_arr=l.rstrip().split("\t")
    g1=l_arr[0]
    g2=l_arr[1]
    if(g1 not in of_d):
        of_d[g1]=set()
    of_d[g1].add(g2)

#expressioin type, expression  value, mutant, hom, hub, rep hub, snp den
for x in sorted(list(g_d.keys())):
    et=g_d[x][0]
    ev=g_d[x][1]
    mp=g_d[x][2]
    hop=g_d[x][3]
    hup=g_d[x][4]
    rhubp=g_d[x][5]
    lowd=g_d[x][6]
    if(x.startswith("NC")):
        s=et*(pvals_nc[0]*mp+pvals_nc[1]*hup+pvals_nc[2]*rhubp+pvals_nc[3]*lowd+pvals_nc[4]*ev)
    else:
        s=et*(pvals_cod[0]*mp+pvals_cod[1]*hop+pvals_cod[2]*hup+pvals_cod[3]*rhubp+pvals_cod[4]*lowd+pvals_cod[5]*ev)
    vals=[str(et),str(round(ev,2)),str(mp),str(hop),str(hup),str(rhubp),str(lowd)]
    ttype=mct_d[x]
    #if(ttype.startswith("SP") or ttype.startswith("EC") or ttype.startswith("VE")):
    #ttype=ttype[0:2]
    print x +"\t"+",".join(vals)+"\t"+str(s)+"\t"+str(",".join(sorted(list(of_d[x]))))+"\t"+ttype
