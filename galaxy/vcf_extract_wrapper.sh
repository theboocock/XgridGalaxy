#Author: Edward Hills
#Date: 30/11/11
#
# A wrapper that wraps all the functions that need to be called by 
# extract_vcf.xml for Galaxy.
#
# Params:
# $1 = input1
# $2 = output1
# $3 = err_output
# $4 = dbsnp
# $5 = variants_annotated
# $6 = region
REGIONS=""
if [ $# == 6 ]
#if [ $3 == "true" ]
then
    REGIONS=$6
    python ~/galaxy-dist/tools/vcf_tools/vcfPytools.py extract --in=$1 --out $2 --region=$REGIONS
#else 
 #   $REGIONS=./getRegion.sh $1 
 #   python ~/galaxy-dist/tools/vcf_tools/vcfPytools.py extract --in=$1 --out $2 --region=$REGIONS
#fi
else
    REGIONS=`~/galaxy-dist/tools/SOER1000genes/galaxy/getRegion.sh $1`
    python ~/galaxy-dist/tools/vcf_tools/vcfPytools.py extract --in=$1 --out $2 --region=$REGIONS
fi

echo $REGIONS
tabix -h ~/galaxy-dist/tools/SOER1000genes/data/dbSNP.vcf.gz $REGIONS > $4

java -jar ~/galaxy-dist/tool-data/shared/jars/snpEff/SnpSift.jar annotate $4 $2 1> $5 2> $3
