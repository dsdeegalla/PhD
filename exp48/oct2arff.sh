#!/bin/bash
# ver 0.41
# Author: Sampath Deegalla
# Date: May 2012
# convert octave output to arff
# Modified to octave version 3.6
# Changed directory issue using awk

#source /cygdrive/c/SampathDeegalla/Experiments/exp43/functions.sh || exit
source /home/hpc-admin/exp44/functions.sh || exit

# Check number of arguments
if test $# -lt 5
then
echo Error: not enough arguments
echo Usage: sh oct2arff.sh \<octfile\> \<classfile\> \<numins\> \<numatt\> \<classinfo\>  \<splitflag\> \<desirednumberofattributes\> 
exit
fi

# internal directory issue is fixed
name=`ls $1 | awk 'BEGIN {FS="/"}{print $NF}' | cut -d'.' -f1` 
#name=`ls $1 | cut -d'.' -f1`
attprefix=`echo $name | cut -d'_' -f1`
#attprefix=`ls $1 | cut -d'_' -f1`
arfffile=$name.arff
#echo $arfffilename

#cat $1 | tr -d '\15\32' | tail -n $3 | tr ' ' ',' | sed 's/^,//g' > data
#octave v3.6 introduces two spaces
cat $1 | tr -d '\15\32' | grep -v '^$' | tail -n $3 | tr ' ' ',' | sed 's/^,//g' > data

print_relation_name $name > $arfffile
print_attribute_list $4 $attprefix >> $arfffile
print_attribute_class $5 >> $arfffile
print_data data $2 >> $arfffile


#index=1
#for args in "$@"
#do
#  echo "Arg #$index = $args"
#  let "index+=1"
#done

if test $7
then
  i=$7
  relationname=$name\_$i
  arfffile=$relationname.arff

  cat data | cut -d',' -f1-$i > newdata

  print_relation_name $relationname > $arfffile
  print_attribute_list $i $attprefix >> $arfffile
  print_attribute_class $5 >> $arfffile
  print_data newdata $2 >> $arfffile
  rm newdata
elif test $6
then
  for (( i=1; i<=$4; i++ ))
  do
    relationname=$name\_$i
    arfffile=$relationname.arff

    cat data | cut -d',' -f1-$i > newdata

    print_relation_name $relationname > $arfffile
    print_attribute_list $i $attprefix >> $arfffile
    print_attribute_class $5 >> $arfffile
    print_data newdata $2 >> $arfffile
    rm newdata
  done
fi

unset name relationname arfffile attprefix i
rm data 
