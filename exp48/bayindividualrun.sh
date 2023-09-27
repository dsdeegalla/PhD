#!/bin/bash

# filename: bayindividualrun.sh
# date: 2016.01.26
# author: Sampath Deegalla
# version: 0.1

set -e #brake if error

starttime=`date`
echo "start"
echo $starttime

method=raw
numatt=$numberofattributes
nocla=50 # number of nearest neighbors is set to 50
skipcrefil=0 # skip file creation yes 1 no 0
#nothreads=24
skipcrebayfile=0 # skip bay file creation yes 1 no 0
skipgen1010cvresults=0 # skip 10 * 10cv results yes 1 no 0

###
# 1 10 3 # 2016.01.27
# 2 10 3 # 2016.01.27
# 3 10 2 # 2016.01.28
# 4 9 10 # 2016.01.28
# 4 10 1 # 2016.01.29
# 5 9 10 # 2016.02.05
# 5 10 1 # 2016.02.01
# 6 9 10 # 2016.02.05
# 6 10 1 # 2016.02.01
# 7 9 10 # 2016.02.05
# 7 10 1 # 2016.02.02
# 8 9 10 # 2016.02.05
# 8 10 1 # 2016.02.02
# 9 9 9 # 2016.02.05
# 9 10 1 # 2016.02.02
# 10 9 10
# 10 10 1 # 2016.02.04
###

ini=10
inj=9
inidx=9

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

if [ $skipcrebayfile -ne 1 ]; then #skip creating bay files
  # creating directories
  mkdir -p ARFF/bay10cv/
  mkdir -p ARFF/bay/
  mkdir -p Results/bay10cv/
  mkdir -p Results/bay/

  #
  # Creating 50 * 10 * 10 * 10 files using
  # Random subset method
  #
  #skip=1; if [ $skip -ne 1 ]; then #skip #i
  i=$ini
  j=$inj
  idx=$inidx
  while [ $idx -le 10 ]
  do
    att=$(( ($numatt * $idx) / 10 ))
    #echo "no of attributes" $att
    #rm $name\_baymodified_$att
    #totacc=0
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
      #
      # random feature selection
      # 
      (java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomSubset -N $att -S $cla -c last -i ARFF/$method/$infile > ARFF/bay10cv/$outfile ) &
      #let "w=$cla%$nothreads"; if [ $w -eq 0 ]; then wait; fi
    done
    wait
    #echo "selecting randome features done"
    #echo $starttime


    #
    # selecting same no of attributes
    # from the test set
    #
    for (( cla=1; cla<=$nocla; cla++ ))
    do
    
      infile=$method\_$name\_trainset$i\_trainfold$j.arff
      testinfile=$method\_$name\_trainset$i\_testfold$j.arff
      outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
      testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff

      attributelist=`cat ARFF/bay10cv/$outfile | grep "@attribute" | awk '{ print $2 }' | head -n $att | tr '\n' ',' | sed 's/,$//g' | sed 's/[a-zA-Z]//g'`
      (java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/$method/$testinfile > ARFF/bay10cv/$testoutfile) &
      #let "w=$cla%$nothreads"; if [ $w -eq 0 ]; then wait; fi
    done
    wait
    #echo "selecting the same from the testfiles done"
    #echo $starttime
    idx=$(($idx + 1))
  done # while idx
fi # skip creating bay files

if [ $skipgen1010cvresults -ne 1 ]; then # skip 10 * 10cv results yes 1 no 0
  #
  # Generating KNN accuracies
  #
  i=$ini
  j=$inj
  idx=$inidx 
  while [ $idx -le 10 ]
  do
    att=$(( ($numatt * $idx) / 10 ))
    #
    # 1KNN for the results
    #    
    for (( cla=1; cla<=$nocla; cla++ ))
    do
      infile=$method\_$name\_trainset$i\_trainfold$j.arff
      testinfile=$method\_$name\_trainset$i\_testfold$j.arff
      outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
      testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
      
      # accuracy
      (java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay10cv/$outfile -T ARFF/bay10cv/$testoutfile > Results/bay10cv/ResultsIB1_$outfile.txt) &
      (java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay10cv/$outfile -T ARFF/bay10cv/$testoutfile -p 0 > Results/bay10cv/ResultsIB1_$outfile\_predictions.txt) &
      #let "w=$cla%($nothreads/2)"; if [ $w -eq 0 ]; then wait; fi
    done
    wait
    #echo "knn done"
    #echo $starttime
    idx=$(($idx + 1))
  done # while idx
fi # skip 10 * 10cv results yes 1 no 0

echo "finished"
echo $starttime
date
