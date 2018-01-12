#!/bin/bash 

##################################################################################
# This script implements MCGPlannotator using command line.                      #
# ScriptName: runMCGPlannotator.sh                                               #
# Written by Agnieszka A. Golicz (agnieszka.golicz@unimelb.edu.au)               #
# Last modified date: 08/01/2018                                                 #
# Note:                                                                          #
#       1. Please execute the this script in the directory where                 #
#	all the other scripts are found or modify your path accordingly          #
#                                                                                #
#       2. For a test-run place all the files found on: https://osf.io/78axs/ 	 #
#	and the scripts	in a single directory and run: bash runMCGPlannotator.sh #
#                                                                                #
##################################################################################


###MODIFY SETTINGS VALUES BELOW

#These values need to be provided in order to run the pipeline.
#Sample files can be downloaded from: https://osf.io/78axs/.
#Sample files can be repalced with any files conformign to the format.
#If you haave any probelms please email agnieszka.golicz#gmail.com with the error message.
#I will do my best to help.

#File with expression values, provided as FPKM or TPM or similar, 
#the values need to be log transformed and no negative values
#are allowed. It is recommended to used log1p().Tab separated,
#first column gene IDs, followed by one column per sample. 
#Includes header with column names.
fpkm="logFPKM.values"

#File with classification of all the samples as reproductive ("rep") 
#or vegetative ("veg"). Two tab separated columns, first sample,
#second classification.  No header.
ex_classify="expression.classify"

#File with phenotype information. The phenotype information needs to 
#conform to a specific format. The file is tab separated with the following columns: 
#1. gene ID, 2. number of mutant lines, 3. comma separated list of line names,
#4. comma separated list of most common phenotype, 5. comma separated list of the 
#most common phenotype count, #6. comma separated list of most common phenotype type,
#7. comma separated list of the most common phenotype type count, 
#8. alternative ID, if does not exist repeat column 1. 
#No header This file is NOT NECESSARY. 
#If does not exist please supply name of non-existent file, for example: null.phenotypes
pheno="pheno.info"

#File with homology information. Tab separated. Two columns: 1. Gene id, 
#2. ";" separated list of GO term descriptions. 
#No header. If no annotation second column should have NA.
hom="gene.go.annot"

#File with community information. Tab separated. Three columns: 
#1. Community id, 2. "," separated list of genes in community, 
#3. ";" separated list of GO term descriptions. 
#No header. If no annotation third column should have NA.
comm="comm.go.annot"

#File with gene sequence diversity. Tab separated. Two columns: 1. Gene id,
#2. SNP density, SNP/Kbp. No header
div="SNPs.density"

#File with key words to be included. Key words of phrases (single space separated). 
#One per line. No header.
key_yes="key.positive"

#File with key words to be excluded. Key words of phrases (single space separated).
#One per line. No header.
key_no="key.negative"

#If you have second annotation, ID mapping can be provided, in two tab separated column format,
#if no ID mapping repeat the same id twice. No header.
id_map="gene.id.map"

#Trait type, either reproductive ("rep") or vegetative ("veg"). No header.
ptype="rep"

#Values of parameters to use for PI score calculation
param_vals_coding="0.6,0.6,0.4,0.3,0.2,0.1"

param_vals_noncoding="0.6,0.4,0.3,0.2,0.1"

#Choose if you want to run in coding or non-coding mode: either "coding" or "non-coding". 
#Non-coding genes have to start with prefix "NC_".
#If you want results for both, you will need to run the script twice.
mode="non-coding"

#Size of the positive training set. Please be mindful of the total number of genes.
pset=200

#Size od the negative training set. Please be mindful of the total number of genes.
nset=500

#Percentage cutoff dividing positive and nevgative training set pools. 
#Please be midfull of the total number of genes, pset and nset chosen.
pcctoff=5

#Featues to be included in classifer
feats="ET,EV,P,H,CP,CF,D"

#Output directory
output="MCGPlannotator_out"

###THE END OF SETTINGS

###Settings summary

echo "Expression data file: $fpkm"
echo "Sample classification file: $ex_classify"
echo "Phenotypic information file: $pheno"
echo "Gene homology information file: $hom"
echo "Gene community information file: $comm"
echo "Sequence diversity file: $div"
echo "Positive keywords file: $key_yes"
cat $key_yes
echo "Negative keywords file: $key_no"
cat $key_no
echo "Id1 to Id2 map file: $id_map"
echo "Expression/phenotype type: $ptype"
echo "PI parameter values for coding genes: $param_vals_coding"
echo "PI parameter values for non-coding genes: $param_vals_noncoding"
echo "Gene type mode: $mode"
echo "Positive training set size: $pset"
echo "Negative training set size: $nset"
echo "Cut-off between positive and negative training sets: $pcctoff"
echo "Features: $feats"


###BEGIN EXECUTION

#Create output directory

d=$(date +%Y%m%d%H%M%S)
outdir="${output}_${d}_${mode}"
echo "Output folder: $outdir"

mkdir $outdir

echo "Preparing files..."

#Parse the FPKM file to get highest expressed tissue and tissue type

python get_highest_expressed.py ${ex_classify} ${fpkm} > $outdir/${fpkm}.highest

#Parse the GO annotation of individual genes to see if they contain the key words

python assign_go_type.singleGenes.py ${key_yes} ${key_no} ${hom} > $outdir/${hom}.type

#Parse the GO annotation of communities to see if they contain the key words

python assign_go_type.py ${key_yes} ${key_no} ${comm} > $outdir/${comm}.type

echo "Calculating PI score..."

#Calculate process involvement score

python calculate_score.py $outdir/${fpkm}.highest ${pheno} $outdir/${hom}.type $outdir/${comm}.type ${div} ${id_map} ${ptype} $param_vals_coding $param_vals_noncoding | sort -k 3,3gr > $outdir/PI.scores

echo "Preparing files for classifier..."

grep NA $outdir/${fpkm}.highest | cut -f 1 | sort | uniq > $outdir/${fpkm}.highest.na
cut -f 1 ${div} | sort | uniq > $outdir/${div}.genes

cut -f 1,2,6 $outdir/PI.scores | tr ',' '\t' > $outdir/PI.scores.forBayes
python replace_phenotype_na.py ${pheno} $outdir/PI.scores.forBayes > $outdir/PI.scores.forBayes.na
python replace_expression_na.py $outdir/${fpkm}.highest.na $outdir/PI.scores.forBayes.na > $outdir/PI.scores.forBayes.na.na
python replace_diversity_na.py $outdir/${div}.genes $outdir/PI.scores.forBayes.na.na > $outdir/PI.scores.forBayes.na.na.na
python replace_01.py $outdir/PI.scores.forBayes.na.na.na > $outdir/PI.scores.forBayes.na.yn
rm $outdir/PI.scores.forBayes.na $outdir/PI.scores.forBayes.na.na $outdir/PI.scores.forBayes.na.na.na

if [ "$mode" == "coding" ]
then
	echo "Coding genes mode..."

	grep -v "^NC" $outdir/PI.scores.forBayes.na.yn > $outdir/PI.scores.forBayes.na.yn.cod
        grep -v "^NC"  $outdir/PI.scores > $outdir/PI.scores.cod
	lines=`wc $outdir/PI.scores.cod | awk '{print $1}'`
	neg=`awk -v var=$lines -v var2=$pcctoff 'BEGIN {printf "%3.0f\n", var-(var*(var2/100))}'`
	echo $neg
	COUNTER=3
	PASS=""
	while [ "$PASS" != "SUCCESS" ]; do
		head -n $pset $outdir/PI.scores.cod | awk '{print $0, "pos"}' | tr ' ' '\t' > $outdir/PI.scores.cod.top
		tail -n $neg $outdir/PI.scores.cod | shuf | head -n $nset | awk '{print $0, "non"}' | tr ' ' '\t' > $outdir/PI.scores.cod.non
		cat $outdir/PI.scores.cod.top $outdir/PI.scores.cod.non > $outdir/PI.scores.cod.both
		cut -f 1,2,6 $outdir/PI.scores.cod.both | tr ',' '\t'| shuf > $outdir/PI.scores.cod.both.bayes
		python replace_phenotype_na.py ${pheno} $outdir/PI.scores.cod.both.bayes > $outdir/PI.scores.cod.both.bayes.na
		python replace_expression_na.py $outdir/${fpkm}.highest.na $outdir/PI.scores.cod.both.bayes.na > $outdir/PI.scores.cod.both.bayes.na.na
		python replace_diversity_na.py $outdir/${div}.genes $outdir/PI.scores.cod.both.bayes.na.na > $outdir/PI.scores.cod.both.bayes.na.na.na
		python replace_01.py $outdir/PI.scores.cod.both.bayes.na.na.na > $outdir/PI.scores.cod.both.bayes.na.yn
		rm $outdir/PI.scores.cod.both.bayes.na $outdir/PI.scores.cod.both.bayes.na.na $outdir/PI.scores.cod.both.bayes.na.na.na

		echo "Running classifer with features... $feats"
        	Rscript --vanilla bayes.classifier.cod.R $outdir $feats
		echo "Running classifer control - scrambled lables with features... $feats"
		Rscript --vanilla bayes.classifier.cod.scram.R $outdir $feats

		let COUNTER-=1
		PASS=`cat $outdir/error.txt`
		if [ "$COUNTER" -eq "0" ]
		then
			break
		fi
	done
	if [ "$PASS" == "SUCCESS" ]
	then
		rm $outdir/${div}.genes $outdir/${fpkm}.highest.na
		echo "RUN SUCCESS"
	else
		echo "Classifier could not be built. Please try different settings!"
		echo "RUN FAILED"
		exit 1
	fi
	grep pos $outdir/bayes.cod.tsv | cut -f 1 | sort | uniq > $outdir/bayes.cod.tsv.pos.genes
        python add_bayes.py $outdir/bayes.cod.tsv.pos.genes $outdir/PI.scores.cod | grep pos > $outdir/PI.scores.cod.bayes.pos
        python add_phenotype.py ${pheno} $outdir/PI.scores.cod.bayes.pos  | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' > $outdir/pos.cod.table
	echo "GeneID,ET,EV,P,H,CP,CF,D,PI,GeneID2,HighestExpression,MutantLinesCount,MutantIDs,MostCommonPheno,MostCommonPhenoCount,MostCommonPhenoCategory,MostCommonPhenoCategoryCount" | sed 's/,/\t/g' > $outdir/header.txt
	cp $outdir/PI.scores.cod.top $outdir/PI.scores.cod.top.tsv
	cp $outdir/PI.scores.cod.non $outdir/PI.scores.cod.non.tsv
	cat $outdir/header.txt $outdir/pos.cod.table > $outdir/prediction.results.cod.tsv
	cp results.readme.txt $outdir/results.readme.txt
elif [  "$mode" == "non-coding" ]
then
	echo "Non-coding genes mode..."

        grep "^NC" $outdir/PI.scores.forBayes.na.yn > $outdir/PI.scores.forBayes.na.yn.nc
        grep "^NC"  $outdir/PI.scores > $outdir/PI.scores.nc
        lines=`wc $outdir/PI.scores.nc | awk '{print $1}'`
        neg=`awk -v var=$lines -v var2=$pcctoff 'BEGIN {printf "%3.0f\n", var-(var*(var2/100))}'`
        echo $neg
	COUNTER=3
        PASS=""
        while [ "$PASS" != "SUCCESS" ]; do
        	head -n $pset $outdir/PI.scores.nc | awk '{print $0, "pos"}' | tr ' ' '\t' > $outdir/PI.scores.nc.top
        	tail -n $neg $outdir/PI.scores.nc | shuf | head -n $nset | awk '{print $0, "non"}' | tr ' ' '\t' > $outdir/PI.scores.nc.non
        	cat $outdir/PI.scores.nc.top $outdir/PI.scores.nc.non > $outdir/PI.scores.nc.both
        	cut -f 1,2,6 $outdir/PI.scores.nc.both | tr ',' '\t' | shuf > $outdir/PI.scores.nc.both.bayes
        	python replace_phenotype_na.py ${pheno} $outdir/PI.scores.nc.both.bayes > $outdir/PI.scores.nc.both.bayes.na
		python replace_expression_na.py $outdir/${fpkm}.highest.na $outdir/PI.scores.nc.both.bayes.na > $outdir/PI.scores.nc.both.bayes.na.na
        	python replace_diversity_na.py $outdir/${div}.genes $outdir/PI.scores.nc.both.bayes.na.na > $outdir/PI.scores.nc.both.bayes.na.na.na
        	python replace_01.py $outdir/PI.scores.nc.both.bayes.na.na.na > $outdir/PI.scores.nc.both.bayes.na.yn
		rm $outdir/PI.scores.nc.both.bayes.na $outdir/PI.scores.nc.both.bayes.na.na $outdir/PI.scores.nc.both.bayes.na.na.na
        
		echo "Running classifer with features... $feats"
        	Rscript --vanilla bayes.classifier.nc.R $outdir $feats
		echo "Running classifer control - scrambled lables with features... $feats"
		Rscript --vanilla bayes.classifier.nc.scram.R $outdir $feats

                let COUNTER-=1
		PASS=`cat $outdir/error.txt`
		if [ "$COUNTER" -eq "0" ]
                then
                        break
                fi
	done
	if [ "$PASS" == "SUCCESS" ]
        then
		rm $outdir/${div}.genes $outdir/${fpkm}.highest.na
		echo "RUN SUCCESS"
	else
                echo "Classifier could not be built. Please try different settings!"
		echo "RUN FAILED"
                exit 1
        fi
	grep pos $outdir/bayes.nc.tsv | cut -f 1 | sort | uniq > $outdir/bayes.nc.tsv.pos.genes
        python add_bayes.py $outdir/bayes.nc.tsv.pos.genes $outdir/PI.scores.nc | grep pos > $outdir/PI.scores.nc.bayes.pos
        python add_phenotype.py ${pheno} $outdir/PI.scores.nc.bayes.pos  | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' | sed 's/,/\t/' > $outdir/pos.nc.table
	echo "GeneID,ET,EV,P,H,CP,CF,D,PI,GeneID2,HighestExpression,MutantLinesCount,MutantIDs,MostCommonPheno,MostCommonPhenoCount,MostCommonPhenoCategory,MostCommonPhenoCategoryCount" | sed 's/,/\t/g' > $outdir/header.txt
	cp $outdir/PI.scores.nc.top $outdir/PI.scores.nc.top.tsv
        cp $outdir/PI.scores.nc.non $outdir/PI.scores.nc.non.tsv
	cat $outdir/header.txt $outdir/pos.nc.table > $outdir/prediction.results.nc.tsv
	cp results.readme.txt $outdir/results.readme.txt
else
	echo "Unrecognized mode - check parameter settings..."
fi
