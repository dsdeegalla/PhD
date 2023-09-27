#!/bin/bash

# filename: baypred.sh
# date: 2019.03.26
# author: Sampath Deegalla
# version: 1.0

set -e #brake if error


starttime=`date`
echo "start"
echo $starttime


method=raw
numatt=$numberofattributes
not=10 # number of threads

# creating directories
mkdir -p ARFF/rp/
mkdir -p Results/rp/nocla/

for (( i=1; i<=$NUMFOLDS; i++ ))
do
  for nok in 1 3 5 7 9
  do
    for nocla in 1 5 10 25 50 100
    do
      rm -f $name\_rp$nok\_cla$nocla\_$method\_$i
    done #nocla
  done

  # 10cv
  att=$(( $numatt / 10 )) # get 10% of the attributes for the kNN ensemble
  echo $att

  # get predictions for all  

  for nok in 1 3 5 7 9
  do
  for nocla in 1 5 10 25 50 100
  do
  for (( cla=1; cla<=$nocla; cla++ ))
  do
    echo $cla
    infile=$method\_$name\_trainset$i.arff
    testinfile=$method\_$name\_testset$i.arff
    outfile=$method\_$name\_trainset$i\_$att\_$cla.arff
    testoutfile=$method\_$name\_testset$i\_$att\_$cla.arff

    cat Results/rp/ResultsIB$nok\_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

    if [ $cla -ne 1 ]; then
      paste -d',' $name\_rp$nok\_cla$nocla\_$method\_$i\_$att temp > ttemp && mv ttemp $name\_rp$nok\_cla$nocla\_$method\_$i\_$att
    else
      cat Results/rp/ResultsIB$nok\_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
      paste -d',' class temp > $name\_rp$nok\_cla$nocla\_$method\_$i\_$att
    fi 
    #rm temp class
  done # cla

  # majorith voting of 50 kNN classifiers built on random $att attributes
  python voting.py $name\_rp$nok\_cla$nocla\_$method\_$i\_$att $name\_rp$nok\_cla$nocla\_$method\_$i

  if [ $i -ne 1 ]; then
    paste -d',' $name\_rp$nok\_cla$nocla\_$method $name\_rp$nok\_cla$nocla\_$method\_$i > tempall && mv tempall $name\_rp$nok\_cla$nocla\_$method
  else
    cp $name\_rp$nok\_cla$nocla\_$method\_$i $name\_rp$nok\_cla$nocla\_$method
  fi
  mv $name\_rp$nok\_cla$nocla\_$method\_$i Results/rp/nocla/
  mv $name\_rp$nok\_cla$nocla\_$method\_$i\_$att Results/rp/nocla/
  done #nocla
  done #nok
done #i:foldernumber


for nok in 1 3 5 7 9
do
  for nocla in 1 5 10 25 50 100
  do
    awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_rp$nok\_cla$nocla\_$method > $name\_rp$nok\_cla$nocla\_$method\_avg
    mv $name\_rp$nok\_cla$nocla\_$method Results/rp/nocla/
    mv $name\_rp$nok\_cla$nocla\_$method\_avg Results/rp/nocla/
  done #nocla
done

echo "finished"
echo $starttime
date
