#!/bin/bash
# filename: rp_changed_no_ensembles.sh
# date: 2014.02.13
# author: Sampath Deegalla
# version: 1.0
# changing no of kNN ensembsls as 1,5,10,25,50

set -e #brake if error

starttime=`date`
echo "start"
echo $starttime

method=raw
numatt=$numberofattributes
#nocla=50 # number of nearest neighbors is 50

skipcrefil=0 # skip file creation



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

# creating directories
mkdir -p ARFF/rp10cv/
mkdir -p ARFF/rp/
mkdir -p Results/rp10cv/
mkdir -p Results/rp/

for nocla in 1 5 10 25 50
do
nc=ne$nocla
#skip=1; if [ $skip -ne 1 ]; then #skip #i
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  echo $i
  #skip=1; if [ $skip -ne 1 ]; then #skip #j
  for (( j=1; j<=$NUMFOLDS; j++ ))
  do
    
    idx=1
    while [ $idx -le 10 ]
    do
      att=$((  ($numatt * $idx)/10 ))     
      #skip=1; if [ $skip -ne 1 ]; then

      # selecting random number of features 
      # for 50 nearest neighbor classifiers
      # in the training set
      skip=1; if [ $skip -ne 1 ]; then
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
      fi

      # using 1KNN for the results
      #
      skip=1; if [ $skip -ne 1 ]; then    
      for (( cla=1; cla<=$nocla; cla++ ))
      do
        infile=$method\_$name\_trainset$i\_trainfold$j.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
        
        # accuracy
        (java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/rp10cv/$outfile -T ARFF/rp10cv/$testoutfile -p 0 > Results/rp10cv/ResultsIB1_$outfile\_predictions.txt) &
      done
      wait
      fi

      # Summarising accuracy for different number of Nearest Neighbors (1,5,10,25,50)
      #
      for (( cla=1; cla<=$nocla; cla++ ))
      do
        infile=$method\_$name\_trainset$i\_trainfold$j.arff
        testinfile=$method\_$name\_trainset$i\_testfold$j.arff
        outfile=$method\_$name\_trainset$i\_trainfold$j\_$att\_$cla.arff
        testoutfile=$method\_$name\_trainset$i\_testfold$j\_$att\_$cla.arff
      
        cat Results/rp10cv/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

        if [ $cla -ne 1 ]; then
          paste -d',' $name\_rp_$method\_$nc\_$i\_$j\_$att temp > ttemp && mv ttemp $name\_rp_$method\_$nc\_$i\_$j\_$att
        else
          cat Results/rp10cv/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
          paste -d',' class temp > $name\_rp_$method\_$nc\_$i\_$j\_$att
        fi 
        rm -f temp class
      done #cla
      #fi #skip
      
      # Majority Voting outside WEKA/ ? Boyer-Moore Majority Vote Algorithm ??? 
      # voting 50 kNN classifiers built on $att attributes
      python voting.py $name\_rp_$method\_$nc\_$i\_$j\_$att $name\_rp_$method\_$nc\_$i\_$j

      idx=$(($idx + 1))
    done #att
    wait

    #skip=1; if [ $skip -ne 1 ]; then
    if [ $j -ne 1 ]; then
      paste -d',' $name\_rp_$method\_$nc\_$i $name\_rp_$method\_$nc\_$i\_$j > temp && mv temp $name\_rp_$method\_$nc\_$i
    else
      cat $name\_rp_$method\_$nc\_$i\_$j > $name\_rp_$method\_$nc\_$i
    fi
    #fi #skip

  done #j
  mv $name\_rp_$method\_* Results/rp10cv/
  #fi #skip #j
done #i:foldernumber
#fi #skip #i


#10cv
for (( i=1; i<=$NUMFOLDS; i++ ))
do
  rm -f $name\_rp_$method\_$nc\_$i
  # 10cv
  awk 'BEGIN {FS=","}{ print ($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10 }' Results/rp10cv/$name\_rp_$method\_$nc\_$i > $name\_rp10cv_$method\_$nc\_$i\_avg
  cat $name\_rp10cv_$method\_$nc\_$i\_avg
  mindim=`awk '{ if ($1>maxacc) {maxacc=$1; ind=NR} } END{print ind}' $name\_rp10cv_$method\_$nc\_$i\_avg`
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
        
     java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomProjection -N $att -D SPARSE1 -R $cla -c last -i ARFF/$method/$infile > ARFF/rp/$outfile
     java -classpath $wekajarpath weka.filters.unsupervised.attribute.RandomProjection -N $att -D SPARSE1 -R $cla -c last -i ARFF/$method/$testinfile > ARFF/rp/$testoutfile
    
    # accuracy
    java -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/rp/$outfile -T ARFF/rp/$testoutfile -p 0 > Results/rp/ResultsIB1_$outfile\_predictions.txt
    cat Results/rp/ResultsIB1_$outfile\_predictions.txt
    cat Results/rp/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $NF}' > temp

    if [ $cla -ne 1 ]; then
      paste -d',' $name\_rp_$method\_$nc\_$i\_$att temp > ttemp && mv ttemp $name\_rp_$method\_$nc\_$i\_$att
    else
      cat Results/rp/ResultsIB1_$outfile\_predictions.txt | tail -n +6 | head -n -1 | awk '{ print $2,$3 }' | sed 's/ /,/g' | sed 's/:/,/g' | awk 'BEGIN {FS=","}{print $2}' > class
      paste -d',' class temp > $name\_rp_$method\_$nc\_$i\_$att
    fi 
    #rm temp class
  done # cla
  #fi #skip


  # majorith voting of 50 kNN classifiers built on random $att attributes
  python voting.py $name\_rp_$method\_$nc\_$i\_$att $name\_rp_$method\_$nc\_$i

  if [ $i -ne 1 ]; then
    paste -d',' $name\_rp_$method\_$nc $name\_rp_$method\_$nc\_$i > tempall && mv tempall $name\_rp_$method\_$nc
  else
    cp $name\_rp_$method\_$nc\_$i $name\_rp_$method\_$nc
  fi

done #i:foldernumber

awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_rp_$method\_$nc > $name\_rp_$method\_$nc\_avg

done

echo "finished"
echo $starttime
date
