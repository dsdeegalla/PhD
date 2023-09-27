#!/bin/bash

# filename: modifiedbay.sh
# date: 2012.09.20
# modified: 2013.02.12
# author: Sampath Deegalla

set -e #brake if error

method=$3


# liming number of attributes in the reduced space
#
if [[ "$method" = "pls" || "$method" = "pca" ]]; then
  numatt=15
elif [[ "$method" = "ig" || "$method" = "relieff" ]]; then
  numatt=100
fi

# number of nearest neighbor classifiers for fusion
nocla=50

# creating directories
mkdir -p ARFF/bm10cv/
mkdir -p ARFF/bm/
mkdir -p Results/bm10cv/
mkdir -p Results/bm/



starttime=`date`
#skip=1; if [ $skip -ne 1 ]; then #skip #i
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  #skip=1; if [ $skip -ne 1 ]; then #skip #j
  for (( j=1; j<=$NUMFOLDS; j++ ))
  do
    #skip=1; if [ $skip -ne 1 ]; then #skip 
    idx=1
    while [ $idx -le 10 ]
    do
      att=$(( ($numatt * $idx) / 10 ))
      #skip=1; if [ $skip -ne 1 ]; then
      for (( cla=1; cla<=$nocla; cla++ ))
      do
    
        infile=$method\_$name\_trainset$i\_trainfold$j\_$numatt.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j\_$numatt.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
        
        (java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomSubset -N $att -S $cla -c last -i ARFF/$method"10cv"/$infile > ARFF/bm10cv/$outfile ) &
      done
      wait
      #fi # skip

      for (( cla=1; cla<=$nocla; cla++ ))
      do
    
        infile=$method\_$name\_trainset$i\_trainfold$j\_$numatt.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j\_$numatt.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
        
        # updated 17.10.2012 to work with attribute selection methods
                
        attributelist=`cat ARFF/bm10cv/$outfile | grep "@attribute" | awk '{ print $2 }' | head -n $att | tr '\n' ',' | sed 's/,$//g' | sed 's/[a-zA-Z]//g'`
        #echo $attributelist

        (java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/$method"10cv"/$testinfile > ARFF/bm10cv/$testoutfile) &
      done
      wait
    

      for (( cla=1; cla<=$nocla; cla++ ))
      do
        infile=$method\_$name\_trainset$i\_trainfold$j\_$numatt.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j\_$numatt.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
        
        # accuracy
        (java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bm10cv/$outfile -T ARFF/bm10cv/$testoutfile -p 0 > Results/bm10cv/ResultsIB1_$outfile\_predictions.txt) &
      done
      wait
      #fi #skip

      for (( cla=1; cla<=$nocla; cla++ ))
      do
        infile=$method\_$name\_trainset$i\_trainfold$j\_$numatt.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j\_$numatt.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
      
        cat Results/bm10cv/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

        if [ $cla -ne 1 ]; then
          paste -d',' $name\_baymodified_$method\_$i\_$j\_$att temp > ttemp && mv ttemp $name\_baymodified_$method\_$i\_$j\_$att
        else
          cat Results/bm10cv/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
          paste -d',' class temp > $name\_baymodified_$method\_$i\_$j\_$att
        fi 
        rm -f temp class
      done #cla
      #fi #skip
      
      # voting 50 kNN classifiers built on $att attributes
      python voting.py $name\_baymodified_$method\_$i\_$j\_$att $name\_baymodified_$method\_$i\_$j
      idx=$(($idx + 1))
    done #idx
    wait
    #fi #skip

    #skip=1; if [ $skip -ne 1 ]; then
    if [ $j -ne 1 ]; then
      paste -d',' $name\_baymodified_$method\_$i $name\_baymodified_$method\_$i\_$j > temp && mv temp $name\_baymodified_$method\_$i
    else
      cp $name\_baymodified_$method\_$i\_$j $name\_baymodified_$method\_$i
    fi
    #fi #skip

  done #j
  #echo "Checkthefiles?"
  #read
  mv $name\_baymodified_$method\_* Results/bm10cv/
  #fi #skip #j
done #i:foldernumber
#fi #skip #i

#10cv
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  # 10cv
  awk 'BEGIN {FS=","}{ print ($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10 }' Results/bm10cv/$name\_baymodified_$method\_$i > $name\_baymodified10cv_$method\_$i\_avg
  cat $name\_baymodified10cv_$method\_$i\_avg
  #read
  mindim=`awk '{ if ($1>maxacc) {maxacc=$1; ind=NR} } END{print ind}' $name\_baymodified10cv_$method\_$i\_avg`
  echo $mindim
  att=$(( ($numatt * $mindim) / 10 ))
  echo $att
  
  # building 50 kNN with $att random features
  # then combined them using majorith voting  

  for (( cla=1; cla<=$nocla; cla++ ))
  do
    
    infile=$method\_$name\_trainset$i\_$numatt.arff
    testinfile=$method\_$name\_testset$i\_$numatt.arff
    outfile=$method\_$name\_trainset$i\_$att\_$cla.arff
    testoutfile=$method\_$name\_testset$i\_$att\_$cla.arff
        
    java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomSubset -N $att -S $cla -c last -i ARFF/$method/$infile > ARFF/bm/$outfile
    cat ARFF/bm/$outfile
    attributelist=`cat ARFF/bm/$outfile | grep "@attribute" | awk '{ print $2 }' | head -n $att | tr '\n' ',' | sed 's/,$//g' | sed 's/[a-zA-Z]//g'`
    echo $attributelist
    java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/$method/$testinfile > ARFF/bm/$testoutfile
    cat ARFF/bm/$testoutfile
    
    # accuracy
    #java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bm/$outfile -T ARFF/bm/$testoutfile > Results/bm/ResultsIB1_$outfile.txt
    java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/bm/$outfile -T ARFF/bm/$testoutfile -p 0 > Results/bm/ResultsIB1_$outfile\_predictions.txt
    cat Results/bm/ResultsIB1_$outfile\_predictions.txt
    cat Results/bm/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

    if [ $cla -ne 1 ]; then
      paste -d',' $name\_baymodified_$method\_$i\_$att temp > ttemp && mv ttemp $name\_baymodified_$method\_$i\_$att
    else
      cat Results/bm/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
      paste -d',' class temp > $name\_baymodified_$method\_$i\_$att
    fi 
    #rm temp class
  done # cla


  # majorith voting of 50 kNN classifiers built on random $att attributes
  python voting.py $name\_baymodified_$method\_$i\_$att $name\_baymodified_$method\_$i

  if [ $i -ne 1 ]; then
    paste -d',' $name\_baymodified_$method $name\_baymodified_$method\_$i > tempall && mv tempall $name\_baymodified_$method
  else
    cat $name\_baymodified_$method\_$i > $name\_baymodified_$method
  fi

done #i:foldernumber

awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_baymodified_$method > $name\_baymodified_$method\_avg
