#!/usr/bin/bash -x
  NUMFOLDS=10
  name=colontumor
  wekajarpath="../weka-3-6-12/weka.jar"
  for (( i=1; i<=10; i++ ))
  do
    trainfilename=raw_$name\_trainset$i.arff
    testfilename=raw_$name\_testset$i.arff
    #echo $wekajarpath
    #read
    (java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t $name/ARFF/raw/$trainfilename -T $name/ARFF/raw/$testfilename -i > $name/Results/raw/ResultsIB1_$trainfilename\_withAUC.txt) &
    wait
  done

  # Results summarisation
  rm -f $name\_raw_auc
  rm -f $name\_raw_auc_avg
  for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
  do
    grep "^Correctly" Results/raw/ResultsIB1_raw_$name\_trainset$foldernumber.arff\_withAUC.txt #| tail -n 1 | awk '{ print $5 }' > $name\_raw_$foldernumber
    #if [ $foldernumber -ne 1 ]
    #then
    #  paste -d',' $name\_raw $name\_raw_$foldernumber > tempall && mv tempall $name\_raw
    #else
    #  cat $name\_raw_$foldernumber > $name\_raw
    #fi
    #rm $name\_raw_$foldernumber 
  done

  #awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw > $name\_raw_avg
  #mv $name\_raw Results/raw/
  #mv $name\_raw_avg Results/ 
  exit
