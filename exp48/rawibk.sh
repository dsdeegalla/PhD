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
    #echo $wekajarpath
    #read
    #(java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename > Results/raw/ResultsIB1_$trainfilename.txt) &
    #(java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -i > Results/raw/ResultsIB1_$trainfilename\_withAUC.txt) &
    #(java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -p 0 > Results/raw/ResultsIB1_$trainfilename\_predictions.txt) &
    
    #(java  -classpath $wekajarpath weka.classifiers.lazy.IBk -K $nok  -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename > Results/raw/ResultsIB$nok\_$trainfilename.txt) &
    for nok in 1 3 5 7 9
    do
      echo $nok
      (java  -classpath $wekajarpath weka.classifiers.lazy.IBk -K $nok -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -i > Results/raw/ResultsIB$nok\_$trainfilename\_withAUC.txt) &
      (java  -classpath $wekajarpath weka.classifiers.lazy.IBk -K $nok -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename -p 0 > Results/raw/ResultsIB$nok\_$trainfilename\_predictions.txt) &
    done
    wait
  done

  # Results summarisation
  #rm -f $name\_raw
  #rm -f $name\_raw_precision
  #rm -f $name\_raw_recall
  #rm -f $name\_raw_auc
  #rm -f $name\_raw_avg
  #rm -f $name\_raw_precision_avg
  #rm -f $name\_raw_recall_avg
  #rm -f $name\_raw_auc_avg
  
  for nok in 1 3 5 7 9
  do
  rm -f $name\_raw_IB$nok
  rm -f $name\_raw_IB$nok\_precision
  rm -f $name\_raw_IB$nok\_recall
  rm -f $name\_raw_IB$nok\_auc
  rm -f $name\_raw_IB$nok\_avg
  rm -f $name\_raw_IB$nok\_precision_avg
  rm -f $name\_raw_IB$nok\_recall_avg
  rm -f $name\_raw_IB$nok\_auc_avg
  for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
  do
    grep "^Correctly" Results/raw/ResultsIB$nok\_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_IB$nok\_$foldernumber
    grep "^Weighted" Results/raw/ResultsIB$nok\_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_IB$nok\_precision_$foldernumber
    grep "^Weighted" Results/raw/ResultsIB$nok\_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $6 }' > $name\_raw_IB$nok\_recall_$foldernumber
    grep "^Weighted" Results/raw/ResultsIB$nok\_raw_$name\_trainset$foldernumber.arff\_withAUC.txt | tail -n 1 | awk '{ print $8 }' > $name\_raw_IB$nok\_auc_$foldernumber
    if [ $foldernumber -ne 1 ]
    then
      paste -d',' $name\_raw_IB$nok $name\_raw_IB$nok\_$foldernumber > tempall && mv tempall $name\_raw_IB$nok
      paste -d',' $name\_raw_IB$nok\_precision $name\_raw_IB$nok\_precision_$foldernumber > tempallp && mv tempallp $name\_raw_IB$nok\_precision
      paste -d',' $name\_raw_IB$nok\_recall $name\_raw_IB$nok\_recall_$foldernumber > tempallr && mv tempallr $name\_raw_IB$nok\_recall
      paste -d',' $name\_raw_IB$nok\_auc $name\_raw_IB$nok\_auc_$foldernumber > tempalla && mv tempalla $name\_raw_IB$nok\_auc
    else
      cat $name\_raw_IB$nok\_$foldernumber > $name\_raw_IB$nok
      cat $name\_raw_IB$nok\_precision_$foldernumber > $name\_raw_IB$nok\_precision
      cat $name\_raw_IB$nok\_recall_$foldernumber > $name\_raw_IB$nok\_recall
      cat $name\_raw_IB$nok\_auc_$foldernumber > $name\_raw_IB$nok\_auc
    fi
    rm $name\_raw_IB$nok\_$foldernumber 
    rm $name\_raw_IB$nok\_precision_$foldernumber 
    rm $name\_raw_IB$nok\_recall_$foldernumber 
    rm $name\_raw_IB$nok\_auc_$foldernumber 
  done

  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_IB$nok > $name\_raw_IB$nok\_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_IB$nok\_precision > $name\_raw_IB$nok\_precision_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_IB$nok\_recall > $name\_raw_IB$nok\_recall_avg
  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw_IB$nok\_auc > $name\_raw_IB$nok\_auc_avg
  mv $name\_raw_IB$nok Results/raw/
  mv $name\_raw_IB$nok\_precision Results/raw/
  mv $name\_raw_IB$nok\_recall Results/raw/
  mv $name\_raw_IB$nok\_auc Results/raw/
  mv $name\_raw_IB$nok\_avg Results/ 
  mv $name\_raw_IB$nok\_precision_avg Results/ 
  mv $name\_raw_IB$nok\_recall_avg Results/ 
  mv $name\_raw_IB$nok\_auc_avg Results/ 
  done
  exit
