#!/bin/bash

# filename: rpindividualrun.sh
# date: 2016.02.05
# modified: 
# author: Sampath Deegalla
# version: 1.26

set -e #brake if error


#starttime=`date`
#echo "start"
#echo $starttime


method=raw
numatt=$numberofattributes
nocla=50 # number of nearest neighbors is set to 50
skipcrefil=0 # skip file creation yes 1 no 0
#nothreads=24
skipcrerpfile=0 # skip rp file creation yes 1 no 0
skipgen1010cvresults=0 # skip 10 * 10cv results yes 1 no 0


ini=10
#inj=7
inidx=1

#for (( inj=8; inj<=10; inj++ )) # for inj
for (( inj=4; inj<=10; inj++ )) # for inj
do
starttime=`date`
echo "start"
echo $starttime

if [ $skipcrefil -ne 1 ]; then #skip creating files
  # Create files for 10CV and 10*10CV
  #
  # Divide current dataset as train and test
  mkdir -p ARFF/raw/
  cp ../datasets/$name/$name.arff ARFF/raw/raw_$name.arff || exit 1
  i=$ini
  #seed default 1
  (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name.arff -o ARFF/raw/raw_$name\_trainset$i.arff -c last -S 1 -N $NUMFOLDS -F $i -V) &
  (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name.arff -o ARFF/raw/raw_$name\_testset$i.arff -c last -S 1 -N $NUMFOLDS -F $i) &
  wait

  # make train and test files for internal cross validation
  i=$ini
  j=$inj  
  (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name\_trainset$i.arff -o ARFF/raw/raw_$name\_trainset$i\_trainfold$j.arff -c last -S 1 -N $NUMFOLDS -F $j -V) &
  (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name\_trainset$i.arff -o ARFF/raw/raw_$name\_trainset$i\_testfold$j.arff -c last -S 1 -N $NUMFOLDS -F $j) &
  wait
  echo "files created"
  echo $starttime
fi #skip creating files

if [ $skipcrerpfile -ne 1 ]; then # skip creating rp files
  # creating directories
  mkdir -p ARFF/rp10cv/
  mkdir -p ARFF/rp/
  mkdir -p Results/rp10cv/
  mkdir -p Results/rp/

  #
  # Creating 50 * 10 * 10 * 10 files using
  # Random Projection method
  #
  i=$ini
  j=$inj
  idx=$inidx
  while [ $idx -le 10 ]
  do
    att=$((  ($numatt * $idx) / 10 ))     
    #skip=1; if [ $skip -ne 1 ]; then

    # selecting random number of features 
    # for 50 nearest neighbor classifiers
    # in the training set
    for (( cla=1; cla<=$nocla; cla++ ))
    do
      # raw_AI_trainset1_trainfold1.arff 
      infile=$method\_$name\_trainset$i\_trainfold$j.arff
      testinfile=$method\_$name\_trainset$i\_testfold$j.arff
      outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
      testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
        
      #(java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomSubset -N $att -S $cla -c last -i ARFF/$method/$infile > ARFF/bay10cv/$outfile ) &
      (java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomProjection -N $att -D SPARSE1 -R $cla -c last -i ARFF/$method/$infile > ARFF/rp10cv/$outfile ) &
      (java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomProjection -N $att -D SPARSE1 -R $cla -c last -i ARFF/$method/$testinfile > ARFF/rp10cv/$testoutfile) &
    done
    wait
    idx=$(($idx + 1))
  done
fi # skip creating rp files

if [ $skipgen1010cvresults -ne 1 ]; then # skip 10 * 10cv results yes 1 no 0
  #
  # Generating KNN accuracies 
  # 
  i=$ini
  j=$inj
  idx=$inidx
  while [ $idx -le 10 ]
  do
    att=$(( ($numatt * idx) / 10 ))
    #
    # using 1KNN for the results  
    #
    for (( cla=1; cla<=$nocla; cla++ ))
    do
      infile=$method\_$name\_trainset$i\_trainfold$j.arff
      testinfile=$method\_$name\_trainset$i\_testfold$j.arff
      outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
      testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
        
      # accuracy
      (java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/rp10cv/$outfile -T ARFF/rp10cv/$testoutfile > Results/rp10cv/ResultsIB1_$outfile.txt) &
      (java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/rp10cv/$outfile -T ARFF/rp10cv/$testoutfile -p 0 > Results/rp10cv/ResultsIB1_$outfile\_predictions.txt) &
    done
    wait

    idx=$(($idx + 1))
  done # while idx
fi # skip 10 * 10cv results yes 1 no 0

echo "finished"
echo $starttime
date
rm -rf ARFF/rp10cv/*.arff
done # for inj
#10 10 102
#10 3 614
#10 4 102
#10 5 102
#10 6 102
#10 7 102
#10 8 102
#10 9 102
#7 10 102
#7 3 614
#7 4 102
#7 5 102
#7 6 102
#7 7 102
#7 8 102
#7 9 102
#8 3 614
#9 3 614
#9 4 102
#9 5 102
#9 6 102
#9 7 102
#9 8 102
#9 9 102
