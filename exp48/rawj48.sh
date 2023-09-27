#!/usr/bin/bash -x
# v1.0
# 
# classification for IBk
# Sampath Deegalla
# Last modified 2019.02.28

# equivelent to set -e
set -o nounset 



  # Results generation
  mkdir -p Results/raw
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    trainfilename=raw_$name\_trainset$i.arff
    testfilename=raw_$name\_testset$i.arff
    (java  -classpath $wekajarpath weka.classifiers.trees.J48 -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -i > Results/raw/Resultsj48_$trainfilename\_withAUC.txt) &
    (java  -classpath $wekajarpath weka.classifiers.trees.J48 -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -p 0 > Results/raw/Resultsj48_$trainfilename\_predictions.txt) &
    wait
  done

  # Results summarisation
  rm -f $name\_raw_j48
  rm -f $name\_raw_j48_precision
  rm -f $name\_raw_j48_recall
  rm -f $name\_raw_j48_auc
  rm -f $name\_raw_j48_avg
  rm -f $name\_raw_j48_precision_avg
  rm -f $name\_raw_j48_recall_avg
  rm -f $name\_raw_j48_auc_avg
  for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
  do
    grep "^Correctly" Results/raw/Resultsj48_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_j48_$foldernumber
    grep "^Weighted" Results/raw/Resultsj48_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_j48_precision_$foldernumber
    grep "^Weighted" Results/raw/Resultsj48_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $6 }' > $name\_raw_j48_recall_$foldernumber
    grep "^Weighted" Results/raw/Resultsj48_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $8 }' > $name\_raw_j48_auc_$foldernumber
    if [ $foldernumber -ne 1 ]
    then
      paste -d',' $name\_raw_j48 $name\_raw_j48_$foldernumber > tempall && mv tempall $name\_raw_j48
      paste -d',' $name\_raw_j48_precision $name\_raw_j48_precision_$foldernumber > tempallp && mv tempallp $name\_raw_j48_precision
      paste -d',' $name\_raw_j48_recall $name\_raw_j48_recall_$foldernumber > tempallr && mv tempallr $name\_raw_j48_recall
      paste -d',' $name\_raw_j48_auc $name\_raw_j48_auc_$foldernumber > tempalla && mv tempalla $name\_raw_j48_auc
    else
      cat $name\_raw_j48_$foldernumber > $name\_raw_j48
      cat $name\_raw_j48_precision_$foldernumber > $name\_raw_j48_precision
      cat $name\_raw_j48_recall_$foldernumber > $name\_raw_j48_recall
      cat $name\_raw_j48_auc_$foldernumber > $name\_raw_j48_auc
    fi
    rm $name\_raw_j48_$foldernumber 
    rm $name\_raw_j48_precision_$foldernumber 
    rm $name\_raw_j48_recall_$foldernumber 
    rm $name\_raw_j48_auc_$foldernumber 
  done

  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_j48 > $name\_raw_j48_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_j48_precision > $name\_raw_j48_precision_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_j48_recall > $name\_raw_j48_recall_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_j48_auc > $name\_raw_j48_auc_avg
  mv $name\_raw_j48 Results/raw/
  mv $name\_raw_j48_precision Results/raw/
  mv $name\_raw_j48_recall Results/raw/
  mv $name\_raw_j48_auc Results/raw/
  mv $name\_raw_j48_avg Results/ 
  mv $name\_raw_j48_precision_avg Results/ 
  mv $name\_raw_j48_recall_avg Results/ 
  mv $name\_raw_j48_auc_avg Results/ 
exit
