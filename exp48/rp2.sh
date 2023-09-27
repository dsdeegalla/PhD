#!/bin/bash

# filename: rp2.sh
# date: 2019.03.07
# author: Sampath Deegalla
# version: 1.0

set -e #brake if error


starttime=`date`
echo "start"
echo $starttime


method=raw
numatt=$numberofattributes
nocla=100 # number of nearest neighbors is set to 50
not=10 # number of threads

# creating directories
mkdir -p ARFF/rp/
mkdir -p Results/rp/

for (( i=1; i<=$NUMFOLDS; i++ ))
do
  for nok in 1 3 5 7 9
  do
    rm -f $name\_rp$nok\_$method\_$i
  done
  # 10cv
  att=$(( $numatt / 10 )) # get 10% of the attributes for the kNN ensemble
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
    java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomProjection -N $att -D SPARSE1 -R $cla -c last -i ARFF/$method/$infile > ARFF/rp/$outfile
    java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomProjection -N $att -D SPARSE1 -R $cla -c last -i ARFF/$method/$testinfile > ARFF/rp/$testoutfile
  done # cla

  
  cla=1
  t=1
  while [ $cla -le $nocla ]
  do
    infile=$method\_$name\_trainset$i.arff
    testinfile=$method\_$name\_testset$i.arff
    outfile=$method\_$name\_trainset$i\_$att\_$cla.arff
    testoutfile=$method\_$name\_testset$i\_$att\_$cla.arff
  
    # accuracy
    for nok in 1 3 5 7 9
    do
      (java -classpath $wekajarpath weka.classifiers.lazy.IBk -K $nok -t ARFF/rp/$outfile -T ARFF/rp/$testoutfile -i > Results/rp/ResultsIB$nok\_$outfile\_withAUC.txt) &
      (java -classpath $wekajarpath weka.classifiers.lazy.IBk -K $nok -t ARFF/rp/$outfile -T ARFF/rp/$testoutfile -p 0 > Results/rp/ResultsIB$nok\_$outfile\_predictions.txt) &
    done
    if [ $t -eq $not ]
    then
      wait
      t=0
    fi
    cla=$[$cla+1]
    t=$[$t+1]
  done # cla

  for nok in 1 3 5 7 9
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
      paste -d',' $name\_rp$nok\_$method\_$i\_$att temp > ttemp && mv ttemp $name\_rp$nok\_$method\_$i\_$att
    else
      cat Results/rp/ResultsIB$nok\_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
      paste -d',' class temp > $name\_rp$nok\_$method\_$i\_$att
    fi 
    #rm temp class
  done # cla

  # majorith voting of 50 kNN classifiers built on random $att attributes
  python voting.py $name\_rp$nok\_$method\_$i\_$att $name\_rp$nok\_$method\_$i

  if [ $i -ne 1 ]; then
    paste -d',' $name\_rp$nok\_$method $name\_rp$nok\_$method\_$i > tempall && mv tempall $name\_rp$nok\_$method
  else
    cp $name\_rp$nok\_$method\_$i $name\_rp$nok\_$method
  fi
  done #nok
done #i:foldernumber


for nok in 1 3 5 7 9
do
awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_rp$nok\_$method > $name\_rp$nok\_$method\_avg
mv $name\_rp$nok\_$method Results/rp/
mv $name\_rp$nok\_$method\_avg Results/rp/
done

echo "finished"
echo $starttime
date
