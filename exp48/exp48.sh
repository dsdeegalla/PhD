#!/usr/bin/bash -x
# Author : Sampath Deegalla dsdeegalla@pdn.ac.lk
# Modified : 2019.02.20, 2016.01.26, 2016.01.22
#
# Experiment 48: Reserch Methodology II improvements
 
# Experiment 47: knn ensembles using rp and rs for image datasets
#extend exp45 with different number of kNN ensembles
# for microarray datasets used earlier
# as knn ensembles 1,5,10,25,50 as suggested by henrik
# 
# break if an error
#set -e

# making arff files from txt files
#source functions.sh
source /cygdrive/c/Experiments/exp48/functions.sh
# data preprocessing
# source datapreprocessing.sh

# experiment setup
# raw accuracy
expraw=1 # yes 1 no 0
# bay ensemble
expbay=0 # yes 1 no 0
# rp ensemble
exprp=0 # yes 1 no 0
# bay individual run 
expbayin=0 # yes 1 no 0
# rp individual run
exprpin=0  # yes 1 no 0 # 2016.02.07
# bay new # 2019.02.22
expbaynew=0
# knn for k 1 3 5 7 9
exprawibk=0
# j48 
exprawj48=0
# RandomForest
exprawrf=0
# SVM Linear Kernel
exprawsvm=1
# log file
logfile=log.txt

for dataset in 'zubud' #'AI' 'AMPH1' 'ATA' 'COMT' 'EDC' 'HIVPR' 'HIVRT' 'HPTP' 'ace' 'ache' 'bzr' 'caco' 'cox2' 'cpd-mouse' 'cpd-rat' 'gpb' 'therm' 'thr'
#for dataset in 'colontumor' 
#for dataset in 'colontumor' 'leukemia' 'centralnervous' 'srbct' 'lymphoma' 'brain' 'nci60' 'prostate' 'AI' 'AMPH1' 'ATA' 'COMT' 'EDC' 'HIVPR' 'HIVRT' 'HPTP' 'ace' 'ache' 'bzr' 'caco' 'cox2' 'cpd-mouse' 'cpd-rat' 'gpb' 'therm' 'thr' 'mias' 'outex' 'leedsbutterfly' 'zubud' 'car' '17flowers' 'coil100' 'irma'
#for dataset in 'mias' 'outex' 'leedsbutterfly' 'zubud' 'car' '17flowers' 'coil100' 'irma'
do
  echo $dataset
  mkdir -p $dataset/
  cp datasets/$dataset/$dataset.arff $dataset/ || exit
  #cp functions.sh main.sh config.exp pls_main.m ds_pls.m simpls.m ds_changeY.m pca_main.m ds_princomp.m rankattribute.sh rankchild.sh oct2arff.sh $dataset/
  cp functions.sh main.sh config.exp pls_main.m ds_pls.m simpls.m ds_changeY.m pca_main.m ds_princomp.m oct2arff.sh $dataset/
  cp modifiedbay.sh voting.py $dataset/
  cp bay.sh bay.new.sh bay2.sh $dataset/
  cp rp.sh rp2.sh rp_changed_no_ensembles.sh $dataset/
  cp bayindividualrun.sh bayindividualrunV2.sh $dataset/ # 2016.01.26
  cp rpindividualrun.sh rpindividualrunV2.sh $dataset/ # 2016.02.07
  cd $dataset/
  echo "Start" >> $logfile
  date >> $logfile
  echo "Start"
  date
  echo $dataset >> $logfile
  echo $dataset
  if [ $expraw -eq 1 ]; then
    #
    # Create 10-folds for cross validation and make data files for Matlab
    #
    echo "40001: create 10cv and data files for matlab"
    echo "40001: create 10cv and data files for matlab" >> $logfile
    bash main.sh $dataset 40001
    echo "40001: done" >> $logfile
    date >> $logfile
    echo "40001: done"
    date
    # 
    # RAW accuracies using 10-fold cross validation
    # 
    echo "40002: raw accuracy using 10cv"
    date
    echo "40002: raw accuracy using 10cv" >> $logfile
    date >> $logfile
    bash main.sh $dataset 40002
    echo "40002: done" >> $logfile
    date >> $logfile
    echo "40002: done"
    date
  fi
  #
  # change kNN for k 1 3 5 7 9
  if [ $exprawibk -eq 1 ]; then
    echo "48025: raw accuracy using 10cv"
    date
    echo "48025: raw accuracy using 10cv" >> $logfile
    date >> $logfile
    bash main.sh $dataset 48025
    echo "48025: done" >> $logfile
    date >> $logfile
    echo "48025: done"
    date
  fi
  #
  # Decision Tree J48
  #
  if [ $exprawj48 -eq 1 ]; then
    echo "48026: raw accuracy using 10cv"
    date
    echo "48026: raw accuracy using 10cv" >> $logfile
    date >> $logfile
    bash main.sh $dataset 48026
    echo "48026: done" >> $logfile
    date >> $logfile
    echo "48026: done"
    date
  fi
  #
  # Random Forest
  #
  if [ $exprawrf -eq 1 ]; then
    echo "48027: raw accuracy using 10cv"
    date
    echo "48027: raw accuracy using 10cv" >> $logfile
    date >> $logfile
    bash main.sh $dataset 48027
    echo "48027: done" >> $logfile
    date >> $logfile
    echo "48027: done"
    date
  fi
  #
  # SVM Linear Kernel  
  #
  if [ $exprawsvm -eq 1 ]; then
    echo "48028: raw accuracy using 10cv"
    date
    echo "48028: raw accuracy using 10cv" >> $logfile
    date >> $logfile
    bash main.sh $dataset 48028
    echo "48028: done" >> $logfile
    date >> $logfile
    echo "48028: done"
    date
  fi
  # 
  # Make train test ARFF files for internal cross validation and make Matlab files for internal cross validation 
  # 
  #echo "40010: make10cv10cv and files for matlab" >> $logfile
  #bash main.sh $dataset 40010
  #echo "40010: done" >> $logfile
  #date >> $logfile
  #
  # PLS classification
  #
  #echo "40011: pls" >> $logfile
  #bash main.sh $dataset 40011 pls
  #
  # PCA
  #
  #echo "40011: pca" >> $logfile
  #bash main.sh $dataset 40011 pca
  #
  # IG
  #
  #echo "40011: ig start" >> $logfile
  #bash main.sh $dataset 40011 ig
  #echo "40011: ig end" >> $logfile
  #date >> $logfile
  #
  # ReliefF
  #
  #echo "40011: relieff start" >> $logfile
  #bash main.sh $dataset 40011 relieff
  #echo "40011: relieff end" >> $logfile
  #date >> $logfile
  
  # Modifiedbay
  #echo "43017: modified bay pls" >> $logfile
  #sh main.sh $dataset 43017 pls

  #echo "43017: modified bay pca" >> $logfile
  #sh main.sh $dataset 43017 pca
  
  #echo "43017: modified bay ig start" >> $logfile
  #sh main.sh $dataset 43017 ig
  #echo "43017: modified bay ig end" >> $logfile

  #echo "43017: modified bay relieff" >> $logfile
  #sh main.sh $dataset 43017 relieff
  
  if [ $expbay -eq 1 ]; then
    # Bay
    echo "43018: bay start" >> $logfile
    date >> $logfile
    echo "43018: bay start" 
    date
    bash main.sh $dataset 43018
    echo "43018: bay end" >> $logfile
    date >> $logfile
    echo "43018: bay end" 
    date
  fi 
  
  if [ $expbaynew -eq 1 ]; then
    # Bay new 
    echo "48024: bay new start" >> $logfile
    date >> $logfile
    echo "48024: bay new start" 
    date
    bash main.sh $dataset 48024
    echo "48024: bay new end" >> $logfile
    date >> $logfile
    echo "48024: bay new end" 
    date
  fi 
  
  if [ $expbayin -eq 1 ]; then
    # 
    # Bay individual runs
    #
    echo "47022: bay individual runs start" >> $logfile
    date >> $logfile
    echo "47022: bay individual runs start"
    date
    bash main.sh $dataset 47022
    echo "47022: bay individual runs end" >> $logfile
    date >> $logfile
    echo "47022: bay individual runs end"
    date
  fi


  if [ $exprp -eq 1 ]; then
    #
    # RP
    # 
    date >> $logfile
    echo "44019: rp start" >> $logfile
    date >> $logfile
    echo "44019: rp start" 
    date 
    bash main.sh $dataset 44019
    echo "44019: rp end" >> $logfile 
    date >> $logfile
    echo "44019: rp end"
    date
  fi

  if [ $exprpin -eq 1 ]; then
    # 
    # RP individual runs
    #
    echo "47023: rp individual runs start" >> $logfile
    date >> $logfile
    echo "47023: rp individual runs start"
    date
    bash main.sh $dataset 47023
    echo "47023: rp individual runs end" >> $logfile
    date >> $logfile
    echo "47023: rp individual runs end"
    date
  fi

  #
  # RP chaning number of knn ensembles
  # 
  #date >> $logfile
  #echo "46020: rp start" >> $logfile
  #sh main.sh $dataset 46020
  #echo "46020: rp end" >> $logfile 
  #date >> $logfile

  #
  # Bay chaning number of knn ensembles
  # 
  #date >> $logfile
  #echo "46021: bay diff no of ensembles start" >> $logfile
  #sh main.sh $dataset 46021
  #echo "46021: bay diff no of ensembles  end" >> $logfile 
  #date >> $logfile
  #rm bay.sh
  #rm modifiedbay.sh voting.py
  #rm functions.sh main.sh config.exp pls_main.m ds_pls.m simpls.m ds_changeY.m pca_main.m ds_princomp.m oct2arff.sh 
  #date >> $logfile
  echo "End" >> $logfile
  date >> $logfile
  echo "End" 
  date 
  cd -
done
