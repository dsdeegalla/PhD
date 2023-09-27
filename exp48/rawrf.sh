#!/usr/bin/bash -x
# v1.0
# 
# classification for Random Forests
# Sampath Deegalla
# Last modified 2019.03.12

# equivelent to set -e
set -o nounset 



  # Results generation
  mkdir -p Results/raw
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    trainfilename=raw_$name\_trainset$i.arff
    testfilename=raw_$name\_testset$i.arff
    (java  -classpath $wekajarpath weka.classifiers.trees.RandomForest -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -i > Results/raw/Resultsrf_$trainfilename\_withAUC.txt) &
    (java  -classpath $wekajarpath weka.classifiers.trees.RandomForest -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -p 0 > Results/raw/Resultsrf_$trainfilename\_predictions.txt) &
    wait
  done

  # Results summarisation
  rm -f $name\_raw_rf
  rm -f $name\_raw_rf_precision
  rm -f $name\_raw_rf_recall
  rm -f $name\_raw_rf_auc
  rm -f $name\_raw_rf_avg
  rm -f $name\_raw_rf_precision_avg
  rm -f $name\_raw_rf_recall_avg
  rm -f $name\_raw_rf_auc_avg
  for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
  do
    grep "^Correctly" Results/raw/Resultsrf_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_rf_$foldernumber
    grep "^Weighted" Results/raw/Resultsrf_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_rf_precision_$foldernumber
    grep "^Weighted" Results/raw/Resultsrf_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $6 }' > $name\_raw_rf_recall_$foldernumber
    grep "^Weighted" Results/raw/Resultsrf_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $8 }' > $name\_raw_rf_auc_$foldernumber
    if [ $foldernumber -ne 1 ]
    then
      paste -d',' $name\_raw_rf $name\_raw_rf_$foldernumber > tempall && mv tempall $name\_raw_rf
      paste -d',' $name\_raw_rf_precision $name\_raw_rf_precision_$foldernumber > tempallp && mv tempallp $name\_raw_rf_precision
      paste -d',' $name\_raw_rf_recall $name\_raw_rf_recall_$foldernumber > tempallr && mv tempallr $name\_raw_rf_recall
      paste -d',' $name\_raw_rf_auc $name\_raw_rf_auc_$foldernumber > tempalla && mv tempalla $name\_raw_rf_auc
    else
      cat $name\_raw_rf_$foldernumber > $name\_raw_rf
      cat $name\_raw_rf_precision_$foldernumber > $name\_raw_rf_precision
      cat $name\_raw_rf_recall_$foldernumber > $name\_raw_rf_recall
      cat $name\_raw_rf_auc_$foldernumber > $name\_raw_rf_auc
    fi
    rm $name\_raw_rf_$foldernumber 
    rm $name\_raw_rf_precision_$foldernumber 
    rm $name\_raw_rf_recall_$foldernumber 
    rm $name\_raw_rf_auc_$foldernumber 
  done

  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_rf > $name\_raw_rf_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_rf_precision > $name\_raw_rf_precision_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_rf_recall > $name\_raw_rf_recall_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_rf_auc > $name\_raw_rf_auc_avg
  mv $name\_raw_rf Results/raw/
  mv $name\_raw_rf_precision Results/raw/
  mv $name\_raw_rf_recall Results/raw/
  mv $name\_raw_rf_auc Results/raw/
  mv $name\_raw_rf_avg Results/ 
  mv $name\_raw_rf_precision_avg Results/ 
  mv $name\_raw_rf_recall_avg Results/ 
  mv $name\_raw_rf_auc_avg Results/ 
exit
