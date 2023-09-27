#!/usr/bin/bash -x
# v1.0
# 
# classification for IBk
# Sampath Deegalla
# Last modified 2021.06.09

# equivelent to set -e
set -o nounset 

  # Results generation
  mkdir -p Results/raw
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    trainfilename=raw_$name\_trainset$i.arff
    testfilename=raw_$name\_testset$i.arff

    (java  -classpath $wekajarpath weka.classifiers.functions.SMO -C 1.0 -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0" -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -i > Results/raw/Resultssvm_$trainfilename\_withAUC.txt) &
    
    wait
  done

  # Results summarisation
  rm -f $name\_raw_svm
  rm -f $name\_raw_svm_avg
  for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
  do
    grep "^Correctly" Results/raw/Resultssvm_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_svm_$foldernumber
    if [ $foldernumber -ne 1 ]
    then
      paste -d',' $name\_raw_svm $name\_raw_svm_$foldernumber > tempall && mv tempall $name\_raw_svm
    else
      cat $name\_raw_svm_$foldernumber > $name\_raw_svm
    fi
  done

  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_svm > $name\_raw_svm_avg
  mv $name\_raw_svm Results/raw/
  mv $name\_raw_svm_avg Results/ 
exit
