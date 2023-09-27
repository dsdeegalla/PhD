#!/bin/bash

# filename: bay.sh
# date: 2012.10.23
# modified: 2016.01.21, 2015.01.26
# author: Sampath Deegalla
# version: 1.25

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

if [ $skipcrefil -ne 1 ]; then #skip creating files
# Create files for 10CV and 10*10CV
#
# Divide current dataset as train and test

  mkdir -p ARFF/raw/
  cp ../datasets/$name/$name.arff ARFF/raw/raw_$name.arff || exit 1

  # :: Making separate file for num folds ::
  echo making $NUMFOLDS folds
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    #seed default 1
    (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name.arff -o ARFF/raw/raw_$name\_trainset$i.arff -c last -S 1 -N $NUMFOLDS -F $i -V) &
    (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name.arff -o ARFF/raw/raw_$name\_testset$i.arff -c last -S 1 -N $NUMFOLDS -F $i) &
  #echo $i
  done
  wait

  # make train and test files for internal cross validation
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    for (( j=1; j<=$NUMFOLDS; j++ ))
    do
      #seed 1
      (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name\_trainset$i.arff -o ARFF/raw/raw_$name\_trainset$i\_trainfold$j.arff -c last -S 1 -N $NUMFOLDS -F $j -V) &
      (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name\_trainset$i.arff -o ARFF/raw/raw_$name\_trainset$i\_testfold$j.arff -c last -S 1 -N $NUMFOLDS -F $j) &
    done
  done
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
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  for (( j=1; j<=$NUMFOLDS; j++ ))
  do
    idx=1
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
  done # for j
done # for i
fi # skip creating bay files

if [ $skipgen1010cvresults -ne 1 ]; then # skip 10 * 10cv results yes 1 no 0
#
# Generating KNN accuracies
# 
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  for (( j=1; j<=$NUMFOLDS; j++ ))
  do
    idx=1
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
  done # for j
done # for i
fi # skip 10 * 10cv results yes 1 no 0

#
# Summarizing results
# 
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  for (( j=1; j<=$NUMFOLDS; j++ ))
  do
    idx=1
    while [ $idx -le 10 ]
    do
      att=$(( ($numatt * $idx) / 10 ))
      rm $name\_bay_$method\_$i\_$j
      #
      # Summarising accuracy for 50 Nearest Neighbors
      #
      for (( cla=1; cla<=$nocla; cla++ ))
      do
        infile=$method\_$name\_trainset$i\_trainfold$j.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
      
        cat Results/bay10cv/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

        if [ $cla -ne 1 ]; then
          paste -d',' $name\_bay_$method\_$i\_$j\_$att temp > ttemp && mv ttemp $name\_bay_$method\_$i\_$j\_$att
        else
          cat Results/bay10cv/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
          paste -d',' class temp > $name\_bay_$method\_$i\_$j\_$att
        fi 
        rm -f temp class
      done #cla
      #echo "summarisation done"
      #echo $starttime
      
      #
      # Majority Voting outside WEKA/ ? Boyer-Moore Majority Vote Algorithm ??? 
      # voting 50 kNN classifiers built on $att attributes
      python voting.py $name\_bay_$method\_$i\_$j\_$att $name\_bay_$method\_$i\_$j
      #echo "majority voting done"
      #echo $starttime

      idx=$(($idx + 1))
    done #idx
    wait
    ##echo "all the attributes done"
    #echo $starttime

    #skip=1; if [ $skip -ne 1 ]; then
    if [ $j -ne 1 ]; then
      paste -d',' $name\_bay_$method\_$i $name\_bay_$method\_$i\_$j > temp && mv temp $name\_bay_$method\_$i
    else
      cat $name\_bay_$method\_$i\_$j > $name\_bay_$method\_$i
    fi
    #fi #skip

  done #j
  mv $name\_bay_$method\_* Results/bay10cv/
  #rm ARFF/bay10cv/*.arff
  #fi #skip #j
done #i:foldernumber



#10cv
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  rm -f $name\_bay_$method\_$i
  # 10cv
  awk 'BEGIN {FS=","}{ print ($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10 }' Results/bay10cv/$name\_bay_$method\_$i > $name\_bay10cv_$method\_$i\_avg
  cat $name\_bay10cv_$method\_$i\_avg
  mindim=`awk '{ if ($1>maxacc) {maxacc=$1; ind=NR} } END{print ind}' $name\_bay10cv_$method\_$i\_avg`
  echo $mindim
  att=$(( ($numatt * $mindim) / 10 ))
  echo $att

  #skip=1; if [ $skip -ne 1 ]; then
  # building 50 kNN with $att random features
  # then combined them using majorith voting  

  for (( cla=1; cla<=$nocla; cla++ ))
  do
    echo $cla
    infile=$method\_$name\_trainset$i.arff
    testinfile=$method\_$name\_testset$i.arff
    outfile=$method\_$name\_trainset$i\_$att\_$cla.arff
    testoutfile=$method\_$name\_testset$i\_$att\_$cla.arff
        
    java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomSubset -N $att -S $cla -c last -i ARFF/$method/$infile > ARFF/bay/$outfile
    #cat ARFF/bay/$outfile
    attributelist=`cat ARFF/bay/$outfile | grep "@attribute" | awk '{ print $2 }' | head -n $att | tr '\n' ',' | sed 's/,$//g' | sed 's/[a-zA-Z]//g'`
    #echo $attributelist
    java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/$method/$testinfile > ARFF/bay/$testoutfile
    #cat ARFF/bay/$testoutfile
    
    # accuracy
    java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay/$outfile -T ARFF/bay/$testoutfile > Results/bay/ResultsIB1_$outfile.txt
    java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay/$outfile -T ARFF/bay/$testoutfile -p 0 > Results/bay/ResultsIB1_$outfile\_predictions.txt
    cat Results/bay/ResultsIB1_$outfile\_predictions.txt
    cat Results/bay/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

    if [ $cla -ne 1 ]; then
      paste -d',' $name\_bay_$method\_$i\_$att temp > ttemp && mv ttemp $name\_bay_$method\_$i\_$att
    else
      cat Results/bay/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
      paste -d',' class temp > $name\_bay_$method\_$i\_$att
    fi 
    #rm temp class
  done # cla
  #fi #skip


  # majorith voting of 50 kNN classifiers built on random $att attributes
  python voting.py $name\_bay_$method\_$i\_$att $name\_bay_$method\_$i

  if [ $i -ne 1 ]; then
    paste -d',' $name\_bay_$method $name\_bay_$method\_$i > tempall && mv tempall $name\_bay_$method
  else
    #cat $name\_bay_$method\_$i > $name\_bay_$method
    cp $name\_bay_$method\_$i $name\_bay_$method
  fi

done #i:foldernumber

awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_bay_$method > $name\_bay_$method\_avg

echo "finished"
echo $starttime
date
