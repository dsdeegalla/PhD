#!/bin/bash

# filename: bay.new.sh
# date: 2012.10.23
# modified: 2019.02.22, 2016.01.21, 2015.01.26
# author: Sampath Deegalla
# version: 1.3

set -e #brake if error


starttime=`date`
echo "start"
echo $starttime


method=raw
numatt=$numberofattributes
nocla=50 # number of nearest neighbors is set to 50
#nothreads=24
path="../../exp47/$name"

#10cv
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  rm -f $name\_bay_$method\_$i
  # 10cv
  #awk 'BEGIN {FS=","}{ print ($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10 }' $path/Results/bay10cv/$name\_bay_$method\_$i > $name\_bay10cv_$method\_$i\_avg
  #cat $name\_bay10cv_$method\_$i\_avg
  #mindim=`awk '{ if ($1>maxacc) {maxacc=$1; ind=NR} } END{print ind}' $name\_bay10cv_$method\_$i\_avg`
  mindim=1 
  echo $mindim
  att=$(( ($numatt * $mindim) / 10 ))
  echo $att

  #skip=1; if [ $skip -ne 1 ]; then
  # building 50 kNN with $att random features
  # then combined them using majorith voting  
  echo $nocla
  for (( cla=1; cla<=$nocla; cla++ ))
  do
    echo $cla
    infile=$method\_$name\_trainset$i.arff
    testinfile=$method\_$name\_testset$i.arff
    outfile=$method\_$name\_trainset$i\_$att\_$cla.arff
    testoutfile=$method\_$name\_testset$i\_$att\_$cla.arff
        
    #java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomSubset -N $att -S $cla -c last -i ARFF/$method/$infile > ARFF/bay/$outfile
    #attributelist=`cat ARFF/bay/$outfile | grep "@attribute" | awk '{ print $2 }' | head -n $att | tr '\n' ',' | sed 's/,$//g' | sed 's/[a-zA-Z]//g'`
    #java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/$method/$testinfile > ARFF/bay/$testoutfile
    
    # accuracy
    #java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay/$outfile -T ARFF/bay/$testoutfile > Results/bay/ResultsIB1_$outfile.txt
    java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay/$outfile -T ARFF/bay/$testoutfile -i > Results/bay/ResultsIB1_$outfile\_withAUC.txt
    #java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bay/$outfile -T ARFF/bay/$testoutfile -p 0 > Results/bay/ResultsIB1_$outfile\_predictions.txt
    cat $path/Results/bay/ResultsIB1_$outfile\_predictions.txt
    cat $path/Results/bay/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

    if [ $cla -ne 1 ]; then
      paste -d',' $name\_bay_$method\_$i\_$att temp > ttemp && mv ttemp $name\_bay_$method\_$i\_$att
    else
      cat $path/Results/bay/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
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
