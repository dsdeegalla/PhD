#!/usr/bin/bash -x
# v1.18
# 
# classification for IB1 and RF
# Sampath Deegalla
# Last modified 2021.06.09 added svm linear kernel , remove auc precision recall
#2019.02.20, 2016.01.26, 2016.01.22, 2012.04.03

# possible improvements
# use of mktemp for temporary files

# set -e or bash -e option to brake the code if any of exit status return 0

# simple if ... then ... else ... fi can be replace with [[...]] && ... || ...
# but there may be problems not exactly the same

# change the content of the same file
# sed 's/foo/bar/g' file > tempfile && mv tempfile file
# moving only happens if the first part before && is true

# equivelent to set -e
set -o nounset 

#source functions.sh || exit
source /cygdrive/c/Experiments/exp48/functions.sh || exit


# Check number of arguments
if test $# -lt 2 
then
echo Usage: bash main.sh \<section\> 
exit
fi

# Global Variables datefile-colontumor.data
# 
# Variables defined in config.exp : 
#   $expno $wekajarpath $NUMFOLDS $norm $numatt 
#   $name $numberofattributes $numberofinstances $numberofclasses
#   $numberofplsattributes $numberofpcaattributes $numberofigattributes $numberofrelieffattributes 
#   $numberofensembleattributes $classlist 
source /cygdrive/c/Experiments/exp48/config.exp || exit

if [ $2 -eq 40001 ]; then 
  # divide current dataset as train and test
  # open weka and load data and names files and then save it in arff format
  # Normalize attributes, this doesnt give any advantage in raw performance

  # Norlize dataset 21.02.2019 
  #cp $name.arff raw_$name.arff || exit 1
  java  -classpath $wekajarpath weka.filters.unsupervised.attribute.Normalize -S 1 -T 0.0 -i $name.arff -o raw_$name.arff -c last 

  # :: Making separate file for num folds :: 
  echo making $NUMFOLDS folds 
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      #seed default 1
      (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i raw_$name.arff -o raw_$name\_trainset$i.arff -c last -S 1 -N $NUMFOLDS -F $i -V) &
      (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i raw_$name.arff -o raw_$name\_testset$i.arff -c last -S 1 -N $NUMFOLDS -F $i) &
      #seed 0

      #(java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i raw_$name.arff -o raw_$name\_testset$i.arff -c last -S 0 -N $NUMFOLDS -F $i) &
      wait 
      echo $i
    done
  mkdir -p ARFF/raw
  mv raw_*.arff ARFF/raw/
  
  # Prepare files for the feature extraction step. 
  # Separate data and class files.
  numberoftestinstancesinfolds=(`getnumberoftestinstancesinfolds $numberofinstances $NUMFOLDS`)
  cd ARFF/raw
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      k=`expr $i - 1`
      trainnumberofinstances=`expr $numberofinstances - ${numberoftestinstancesinfolds[$k]}` 
      tail -n $trainnumberofinstances raw_$name\_trainset$i.arff | cut -d',' -f1-`expr $numberofattributes` > $name\_trainset$i.data
      tail -n $trainnumberofinstances raw_$name\_trainset$i.arff | cut -d',' -f`expr $numberofattributes + 1` | tr -d '\15\32' > $name\_trainset$i.class
      tail -n ${numberoftestinstancesinfolds[$k]} raw_$name\_testset$i.arff | cut -d',' -f1-`expr $numberofattributes` > $name\_testset$i.data
      tail -n ${numberoftestinstancesinfolds[$k]} raw_$name\_testset$i.arff | cut -d',' -f`expr $numberofattributes + 1` | tr -d '\15\32' > $name\_testset$i.class
    done
    mkdir -p ../../Matlab/raw
    mv *.data *.class ../../Matlab/raw/
  cd -
  exit
fi

#Raw Accuracy with separate train and test sets
if [ $2 -eq 40002 ] #step 2
then
  # Results generation
  mkdir -p Results/raw
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    trainfilename=raw_$name\_trainset$i.arff
    testfilename=raw_$name\_testset$i.arff
    #echo $wekajarpath
    #read
    (java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/raw/$trainfilename -T ARFF/raw/$testfilename > Results/raw/ResultsIB1_$trainfilename.txt) &
    wait
  done

  # Results summarisation
  rm -f $name\_raw
  rm -f $name\_raw_avg
  for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
  do
    grep "^Correctly" Results/raw/ResultsIB1_raw_$name\_trainset$foldernumber.arff.txt | tail -n 1 | awk '{ print $5 }' > $name\_raw_$foldernumber
    if [ $foldernumber -ne 1 ]
    then
      paste -d',' $name\_raw $name\_raw_$foldernumber > tempall && mv tempall $name\_raw
    else
      cat $name\_raw_$foldernumber > $name\_raw
    fi
    rm $name\_raw_$foldernumber 
  done

  awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $name\_raw > $name\_raw_avg
  mv $name\_raw Results/raw/
  mv $name\_raw_avg Results/ 
  exit
fi


if [ $2 -eq 40010 ]
then
  # make train and test files for internal cross validation
  for (( i=1; i<=$NUMFOLDS; i++ ))
  do
    for (( j=1; j<=$NUMFOLDS; j++ ))
    do
      #seed 1
      (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name\_trainset$i.arff -o ARFF/raw/raw_$name\_trainset$i\_trainfold$j.arff -c last -S 1 -N $NUMFOLDS -F $j -V) &
      (java  -classpath $wekajarpath weka.filters.supervised.instance.StratifiedRemoveFolds -i ARFF/raw/raw_$name\_trainset$i.arff -o ARFF/raw/raw_$name\_trainset$i\_testfold$j.arff -c last -S 1 -N $NUMFOLDS -F $j) &
      wait 
    done 
  done

  # make Matlab data files for internal cross validation
  cd ARFF/raw
    numberoftestinstancesinfolds=(`getnumberoftestinstancesinfolds $numberofinstances $NUMFOLDS`)
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      k=`expr $i - 1`
      trainnumberofinstances=`expr $numberofinstances - ${numberoftestinstancesinfolds[$k]}` 
      trainnumberoftestinstancesinfolds=(`getnumberoftestinstancesinfolds $trainnumberofinstances $NUMFOLDS`)
      for (( u=1; u<=$NUMFOLDS; u++ ))
      do
        v=`expr $u - 1`
        traintrainnumberofinstances=`expr $trainnumberofinstances - ${trainnumberoftestinstancesinfolds[$v]}` 
        tail -n $traintrainnumberofinstances raw_$name\_trainset$i\_trainfold$u.arff | cut -d',' -f1-`expr $numberofattributes` > $name\_trainset$i\_trainfold$u.data
        tail -n $traintrainnumberofinstances raw_$name\_trainset$i\_trainfold$u.arff | cut -d',' -f`expr $numberofattributes + 1` | tr -d '\15\32' > $name\_trainset$i\_trainfold$u.class
        tail -n ${trainnumberoftestinstancesinfolds[$v]} raw_$name\_trainset$i\_testfold$u.arff | cut -d',' -f1-`expr $numberofattributes` > $name\_trainset$i\_testfold$u.data
        tail -n ${trainnumberoftestinstancesinfolds[$v]} raw_$name\_trainset$i\_testfold$u.arff | cut -d',' -f`expr $numberofattributes + 1` | tr -d '\15\32' > $name\_trainset$i\_testfold$u.class
      done
    done

    mkdir -p ../../Matlab/raw
    mv *.data *.class ../../Matlab/raw/
  cd -
  exit
fi # end of 40010

# PLS,PCA,IG and ReliefF transformations 2010-01-21
if [ $2 -eq 40011 ]
then
  
  method=$3

  #skip=1; if [ $skip -ne 1 ]; then #1

  #If the method is PLS or PCA 
  if [[ "$method" = "pls" || "$method" = "pca" ]]; then

    echo $method start 
    
    #skip=1; if [ $skip -ne 1 ]; then #skip 1.1 skipping creation of pls and pca files
    # PLS/PCA transformation in Octave
    mkdir Matlab/$method
    # Transform RAW to PCA or PLS step 2 and 3 
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      for (( j=1; j<=$NUMFOLDS; j++ ))
      do

        cp Matlab/raw/$name\_trainset$i\_trainfold$j.data trainset.data
        #--only need for pls
        if [ "$method" = "pls" ]; then
        cp Matlab/raw/$name\_trainset$i\_trainfold$j.class trainset.class
        echo coping class file 
        cp ../datasets/classfiles/$name.sed class.sed
        echo "finished"
        #cat trainset.class | sed -f class.sed > temp
        sed -f class.sed trainset.class > temp
        mv temp trainset.class
        fi
        #--

        cp Matlab/raw/$name\_trainset$i\_testfold$j.data testset.data 
        octave -qf $method\_main.m 
        #input parameters pls: trainset.data trainset.class testset.data output: trainset.txt testset.txt numberofplscomponents = no of rows in train -1
        #input parameters pca: trainset.data testset.data output: trainset.txt testset.txt numberofplscomponents = no of rows in train -1  
        mv trainset.txt Matlab/$method/$method\_$name\_trainset$i\_trainfold$j.txt 
        mv testset.txt  Matlab/$method/$method\_$name\_trainset$i\_testfold$j.txt
        rm trainset.data testset.data 
        if [ "$method" = "pls" ]; then rm trainset.class; fi
        echo $i $j
      done
    done

    #fi #skip 1.1

    echo "$method finished"
    #read
    # arff files for PLS/PCA
    # it also needed to create all attributes in separate files
    # if number of args is 6, it makes indivial files if not otherwise
    
    # converting Matlab files to ARFF format
    echo converting into ARFF format
    cp oct2arff.sh functions.sh Matlab/$method/
    cd Matlab/$method
      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        for (( j=1; j<=$NUMFOLDS; j++ ))
        do
          numinstr=`cat ../raw/$name\_trainset$i\_trainfold$j.data | wc -l` #no of train instances
          numinste=`cat ../raw/$name\_trainset$i\_testfold$j.data | wc -l` #no of test instances
          # need to improve the following
          #numatt=15
          sh oct2arff.sh $method\_$name\_trainset$i\_trainfold$j.txt ../raw/$name\_trainset$i\_trainfold$j.class  $numinstr $numatt $classlist 1
          sh oct2arff.sh $method\_$name\_trainset$i\_testfold$j.txt ../raw/$name\_trainset$i\_testfold$j.class  $numinste $numatt $classlist 1
        done
      done
      mkdir -p ../../ARFF/$method"10cv"
      mv *.arff ../../ARFF/$method"10cv"
      rm oct2arff.sh functions.sh
    cd -
    #fi #skip 1.1
    echo "$method finished"
    #echo "Enter to continue"
    #read
  elif [[ "$method" = "ig" || "$method" = "relieff" ]]; then
    numberofmethodattributes=$numberofigattributes
    
    #Attribute selection on the training set
    #skip=1; if [ $skip -ne 1 ]; then #skip 2.2 
    #Attribute selection using IG or ReliefF
    mkdir -p ARFF/$method/AttributeSelect
    if [ "$method" = "ig" ]; then
      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        for (( j=1; j<=$NUMFOLDS; j++ ))
        do
          infilename=raw_$name\_trainset$i\_trainfold$j.arff
          outfilename=$method\_$name\_trainset$i\_trainfold$j.arff
          java  -classpath $wekajarpath weka.attributeSelection.InfoGainAttributeEval -s "weka.attributeSelection.Ranker -N $numberofmethodattributes" -i ARFF/raw/$infilename > ARFF/$method/AttributeSelect/Attributes_$outfilename.txt  
        done
      done
      echo "ig done"
    elif [ "$method" = "relieff" ]; then
      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        for (( j=1; j<=$NUMFOLDS; j++ ))
        do
          infilename=raw_$name\_trainset$i\_trainfold$j.arff
          outfilename=$method\_$name\_trainset$i\_trainfold$j.arff
          java  -classpath $wekajarpath weka.attributeSelection.ReliefFAttributeEval -s "weka.attributeSelection.Ranker -N $numberofmethodattributes" -i ARFF/raw/$infilename > ARFF/$method/AttributeSelect/Attributes_$outfilename.txt
        done
      done
    fi 
    #echo "Attribute selection for $method is finished. Press ANY key to continue"
    #read 
    #fi #skip 2.2
 
    mkdir -p ARFF/$method"10cv"
    #cp rankattribute.sh rankchild.sh ARFF/$method/
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      for (( j=1; j<=$NUMFOLDS; j++ ))
      do
        train_file_name=$method\_$name\_trainset$i\_trainfold$j.arff
        attributelist=`cat ARFF/$method/AttributeSelect/Attributes_$train_file_name.txt | tail -n 2 | head -n 1 | awk '{ print $3 }'`
        echo "Attribute list: $attributelist"
        #cd $wekapath
        java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/raw/raw_$name\_trainset$i\_trainfold$j.arff | tr -d '\15\23' > ARFF/$method"10cv"/$method\_$name\_trainset$i\_trainfold$j\_$numberofmethodattributes.arff
        java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/raw/raw_$name\_trainset$i\_testfold$j.arff | tr -d '\15\23' > ARFF/$method"10cv"/$method\_$name\_trainset$i\_testfold$j\_$numberofmethodattributes.arff
        #for (( k=1; k<=99; k++ ))
        k=1
        while [ $k -lt $numberofmethodattributes ]
        do
          (java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R first-$k,last -i ARFF/$method"10cv"/$method\_$name\_trainset$i\_trainfold$j\_$numberofmethodattributes.arff | tr -d '\15\23' > ARFF/$method"10cv"/$method\_$name\_trainset$i\_trainfold$j\_$k.arff) &
          (java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R first-$k,last -i ARFF/$method"10cv"/$method\_$name\_trainset$i\_testfold$j\_$numberofmethodattributes.arff | tr -d '\15\23' > ARFF/$method"10cv"/$method\_$name\_trainset$i\_testfold$j\_$k.arff) &
          k=$(($k + 1))
        done
        #cd -
      done
      wait
    done
    wait
    #rm rankattribute.sh rankchild.sh
    #cd -
    echo "$method finished"
    #fi #skip 2.3
  else
    echo non specified
  fi
  ##
  #fi #1
  
  #skip=1; if [ $skip -ne 1 ]; then
  if [[ "$method" = "pls" || "$method" = "pca" || "$method" = "ig" || "$method" = "relieff" ]]; then

    if [ "$method" = "pls" ]; then
      numberofmethodattributes=15
    elif [ "$method" = "pca" ]; then
      numberofmethodattributes=15
    elif [ "$method" = "ig" ]; then
      numberofmethodattributes=$numberofigattributes
    elif [ "$method" = "relieff" ]; then
      numberofmethodattributes=$numberofrelieffattributes
    else
      numberofmethodattributes=$numberofattributes
    fi

    #Accuracies
    echo "Calculating 10cv accuracies to find optimal no of dimensions" 
    
    #cd $wekapath/
    echo "$method Accuracy"
    #skip=1; if [ $skip -ne 1 ]; then

    # perform 10cv on training set to find optimal
    # number of components that gives the highest
    # accuracy 
    mkdir -p Results/$method"10cv"
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      for (( j=1; j<=$NUMFOLDS; j++ ))
      do
        k=1
        while [ $k -le $numberofmethodattributes ]
        do
          echo $i $j $k
          trainfilename=$method\_$name\_trainset$i\_trainfold$j\_$k.arff
          testfilename=$method\_$name\_trainset$i\_testfold$j\_$k.arff
          (java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/$method"10cv"/$trainfilename -T ARFF/$method"10cv"/$testfilename > Results/$method"10cv"/ResultsIB1_$trainfilename.txt) &
          (java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/$method"10cv"/$trainfilename -T ARFF/$method"10cv"/$testfilename -p 0 > Results/$method"10cv"/ResultsIB1_$trainfilename\_predictions.txt) &
          k=$(($k + 1))
        done 
      done
      wait 
    done
    wait
    #exit
    #echo "break here"
    #read
    #fi #skip
       
    echo "Summarize"
    #skip=1; if [ $skip -ne 1 ]; then
    rm -f $name\_$method"10cv"
    for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
    do
      for (( trainfoldernumber=1; trainfoldernumber<=$NUMFOLDS; trainfoldernumber++ ))
      do
        for (( numberofcomponent=1; numberofcomponent<=$numberofmethodattributes; numberofcomponent++ ))
        do
          echo $foldernumber $trainfoldernumber $numberofcomponent
          grep "^Correctly" Results/$method"10cv"/ResultsIB1_$method\_$name\_trainset$foldernumber\_trainfold$trainfoldernumber\_$numberofcomponent.arff.txt | tail -n 1 | awk '{ print $5 }' >> $name\_$method"10cv"_$foldernumber\_$trainfoldernumber
        done

        if [ $trainfoldernumber -ne 1 ]; then
          paste -d',' $name\_$method"10cv"_$foldernumber $name\_$method"10cv"_$foldernumber\_$trainfoldernumber > temp && mv temp $name\_$method"10cv"_$foldernumber
        else
          cat $name\_$method"10cv"_$foldernumber\_$trainfoldernumber > $name\_$method"10cv"\_$foldernumber
        fi
        rm $name\_$method"10cv"_$foldernumber\_$trainfoldernumber
      done
      awk 'BEGIN {FS=","}{ print ($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10 }' $name\_$method"10cv"_$foldernumber > $name\_$method"10cv"_$foldernumber\_avg
    done
    #echo "break here"
    #read
    #fi #skip
    #cd -

    #echo creating directory
    mkdir -p Results/$method"10cv"
    mv $name\_$method"10cv"* Results/$method"10cv"/
    
    for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
    do
      echo $foldernumber
      #skip=1; if [ $skip -ne 1 ]; then
      mindim=`awk '{ if ($1 > maxacc) {maxacc=$1; ind=NR} } END{print ind}' Results/$method"10cv"/$name\_$method"10cv"_$foldernumber\_avg`
      echo "optimal dimension is" $mindim 
      #echo "dataset:" $name "folder:" $foldername "optimal dimension:" $mindim >> $method.mindim
      echo "dataset:" $name "optimal dimension:" $mindim >> $method.mindim
      if [[ "$method" = "pls" || "$method" = "pca" ]]; then
        echo $method start 
        #PLS/PCA transformation in Octave
  
        #Transform RAW to PCA or PLS step 2 and 3 
        cp Matlab/raw/$name\_trainset$foldernumber.data trainset.data
        #--only need for pls
        if [ "$method" = "pls" ]; then
        cp Matlab/raw/$name\_trainset$foldernumber.class trainset.class
        echo coping class file 
        cp ../datasets/classfiles/$name.sed class.sed
        echo "finished"
        sed -f class.sed trainset.class > temp
        mv temp trainset.class
        fi
        #--

        cp Matlab/raw/$name\_testset$foldernumber.data testset.data 
        octave -qf $method\_main.m 
        mv trainset.txt Matlab/$method/$method\_$name\_trainset$foldernumber.txt 
        mv testset.txt  Matlab/$method/$method\_$name\_testset$foldernumber.txt
        rm trainset.data trainset.class testset.data 
        #echo $foldernumber
        echo "$method finished"
  
        #arff files for PLS/PCA
        #it also needed to create all attributes in separate files
        #if number of args is 6, it makes indivial files if not otherwise
        cp oct2arff.sh functions.sh Matlab/$method/
        cd Matlab/$method
          numinstr=`cat ../raw/$name\_trainset$foldernumber.data | wc -l` #no of train instances
          numinste=`cat ../raw/$name\_testset$foldernumber.data | wc -l` #no of test instances
          if [ "$method" = "pls" ]; then
            numatt=`expr $numinstr - 1`
          else
            numatt=$numinstr
          fi
          sh oct2arff.sh $method\_$name\_trainset$foldernumber.txt ../raw/$name\_trainset$foldernumber.class  $numinstr $numatt $classlist 1 $mindim
          sh oct2arff.sh $method\_$name\_testset$foldernumber.txt ../raw/$name\_testset$foldernumber.class  $numinste $numatt $classlist 1 $mindim
          mkdir -p ../../ARFF/$method
          mv *.arff ../../ARFF/$method
          rm oct2arff.sh functions.sh
        cd -
      #If the method is IG 
      elif [[ "$method" = "ig" || "$method" = "relieff" ]]; then
        #Attribute selection on the training set
        #mkdir -p $wekapath/data/$expno/$name/$method
        #cp ARFF/raw/raw_$name\_trainset$foldernumber.arff $wekapath/data/$expno/$name/$method/$method\_$name\_trainset$foldernumber.arff
        #cd $wekapath/
        #mkdir -p data/$expno/$name/$method/AttributeSelect
        mkdir -p ARFF/$method/AttributeSelect
        numatt=$mindim
        #filename=$method\_$name\_trainset$foldernumber.arff
        infilename=raw_$name\_trainset$foldernumber.arff
        outfilename=$method\_$name\_trainset$foldernumber.arff
        #attribute_select $expno $name $method $numatt $filename
        if [ "$method" = "ig" ]; then
          #java  -classpath ";weka.jar" weka.attributeSelection.InfoGainAttributeEval -s "weka.attributeSelection.Ranker -N $numatt" -i data/$expno/$name/$method/$filename > data/$expno/$name/$method/AttributeSelect/Attributes_$filename.txt  
          java  -classpath $wekajarpath weka.attributeSelection.InfoGainAttributeEval -s "weka.attributeSelection.Ranker -N $numatt" -i ARFF/raw/$infilename > ARFF/$method/AttributeSelect/Attributes_$outfilename.txt  
        elif [ "$method" = "relieff" ]; then
          #java  -classpath ";weka.jar" weka.attributeSelection.ReliefFAttributeEval -s "weka.attributeSelection.Ranker -N $numatt" -i data/$expno/$name/$method/$filename > data/$expno/$name/$method/AttributeSelect/Attributes_$filename.txt
          java  -classpath $wekajarpath weka.attributeSelection.ReliefFAttributeEval -s "weka.attributeSelection.Ranker -N $numatt" -i ARFF/raw/$infilename > ARFF/$method/AttributeSelect/Attributes_$outfilename.txt
        fi  
        #cd -
        mkdir -p ARFF/$method
        #cp rankattribute.sh rankchild.sh ARFF/$method/
        #mv $wekapath/data/$expno/$name/$method/AttributeSelect/Attributes_$filename.txt ARFF/$method/AttributeSelect/
        #cd ARFF/$method
          #cp ../raw/raw_$name\_trainset$foldernumber.arff $method\_$name\_trainset$foldernumber.arff
          #cp ../raw/raw_$name\_testset$foldernumber.arff $method\_$name\_testset$foldernumber.arff
          #train_file_name=$method\_$name\_trainset$foldernumber.arff
          #test_file_name=$method\_$name\_testset$foldernumber.arff
          #train_number_of_lines=`cat $train_file_name | wc -l`
          #train_number_of_instances=`expr $train_number_of_lines - $numberofattributes - 2 - 4`
          #test_number_of_lines=`cat $test_file_name | wc -l`
          #test_number_of_instances=`expr $test_number_of_lines - $numberofattributes - 2 - 4`
          #sh rankattribute.sh $train_file_name AttributeSelect/Attributes_$train_file_name.txt $numberofattributes $train_number_of_instances $method\_$name\_trainset$foldernumber $numatt 1
          #sh rankattribute.sh $test_file_name AttributeSelect/Attributes_$train_file_name.txt $numberofattributes $test_number_of_instances $method\_$name\_testset$foldernumber $numatt 1
          #rm rankattribute.sh rankchild.sh
          train_file_name=$method\_$name\_trainset$foldernumber.arff
          attributelist=`cat ARFF/$method/AttributeSelect/Attributes_$train_file_name.txt | tail -n 2 | head -n 1 | awk '{ print $3 }'`
          echo "Attribute list: $attributelist"
          java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/raw/raw_$name\_trainset$foldernumber.arff | tr -d '\15\23' > ARFF/$method/$method\_$name\_trainset$foldernumber.arff
          java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R $attributelist,last -i ARFF/raw/raw_$name\_testset$foldernumber.arff | tr -d '\15\23' > ARFF/$method/$method\_$name\_testset$foldernumber.arff

          java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R first-$numatt,last -i ARFF/$method/$method\_$name\_trainset$foldernumber.arff | tr -d '\15\23' > ARFF/$method/$method\_$name\_trainset$foldernumber\_$numatt.arff
          java -classpath $wekajarpath weka.filters.unsupervised.attribute.Reorder -R first-$numatt,last -i ARFF/$method/$method\_$name\_testset$foldernumber.arff | tr -d '\15\23' > ARFF/$method/$method\_$name\_testset$foldernumber\_$numatt.arff
        #cd -
        echo "$method finished"
      else
        echo non specified
      fi
    #fi #skip
    done

    #create_directories_for_results $expno $name $method
    mkdir -p Results/$method

    #skip=1; if [ $skip -ne 1 ]; then
    for (( i=1; i<=$NUMFOLDS; i++ ))
    do
      mindim=`awk '{ if ($1 > maxacc) {maxacc=$1; ind=NR} } END{print ind}' Results/$method"10cv"/$name\_$method"10cv"_$i\_avg`
      j=$mindim
      trainfilename=$method\_$name\_trainset$i\_$j.arff
      testfilename=$method\_$name\_testset$i\_$j.arff
      java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/$method/$trainfilename -T ARFF/$method/$testfilename > Results/$method/ResultsIB1_$trainfilename.txt
      java  -classpath $wekajarpath weka.classifiers.lazy.IB1 -t ARFF/$method/$trainfilename -T ARFF/$method/$testfilename -p 0 > Results/$method/ResultsIB1_$trainfilename\_predictions.txt
    done
    #fi #skip
    
    rm -f $name\_$method
    for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
    do
      mindim=`awk '{ if ($1 > maxacc) {maxacc=$1; ind=NR} } END{print ind}' Results/$method"10cv"/$name\_$method"10cv"_$foldernumber\_avg`
      j=$mindim
      grep "^Correctly" Results/$method/ResultsIB1_$method\_$name\_trainset$foldernumber\_$j.arff.txt | tail -n 1 | awk '{ print $5 }' > $name\_$method\_$foldernumber
      if [ $foldernumber -ne 1 ]; then
        paste -d',' $name\_$method $name\_$method\_$foldernumber > tempall && mv tempall $name\_$method
      else
        cat $name\_$method\_$foldernumber > $name\_$method
      fi
      rm $name\_$method\_$foldernumber 
    done

    mv $name\_$method Results/$method/
    awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' Results/$method/$name\_$method > Results/$name\_$method\_avg
  fi 
  exit
fi

####
#PLS,PCA,IG and ReliefF for IB1 and RF Random
if [ $2 -eq 40020 ]
then
  
  #method=$3
  #classifier=$4
  classifier="RF"

  #skip=1; if [ $skip -ne 1 ]; then #2
  #if [[ "$method" = "pls" || "$method" = "pca" || "$method" = "ig" || "$method" = "relieff" ]]; then
  for method in 'raw' 'pls' 'pca' 'ig' 'relieff'
  do
    if [ "$method" = "pls" ]; then
      numberofmethodattributes=15
    elif [ "$method" = "pca" ]; then
      numberofmethodattributes=15
    elif [ "$method" = "ig" ]; then
      numberofmethodattributes=100
    elif [ "$method" = "relieff" ]; then
      numberofmethodattributes=100
    else
      numberofmethodattributes=$numberofattributes
    fi

    #Accuracies
    #skip=1; if [ $skip -ne 1 ]; then
      create_directories_for_results $expno $name $method
      #copy relevent files to weka folder
    if [[ "$method" = "raw" || "$method" = "relieff" || "$method" = "ig" ]]; then
      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        cp ARFF/raw/raw_$name\_trainset$i.arff $wekapath/data/$expno/$name/$method/$method\_$name\_trainset$i.arff
        cp ARFF/raw/raw_$name\_testset$i.arff $wekapath/data/$expno/$name/$method/$method\_$name\_testset$i.arff
      done
      echo copy finished
    fi

    if [[ "$method" = "relieff" || "$method" = "ig" ]]; then
      cd $wekapath/
      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        mkdir -p data/$expno/$name/$method/AttributeSelect
        filename=$method\_$name\_trainset$i.arff
        attribute_select $expno $name $method $numberofmethodattributes $filename
      done
      cd -

      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        filename=$method\_$name\_trainset$i.arff
        attribute_rank $expno $name $method $numberofmethodattributes $filename $i
        trainfilename=$method\_$name\_trainset$i\_$numberofmethodattributes.arff
        testfilename=$method\_$name\_testset$i\_$numberofmethodattributes.arff
        cp ARFF/$method/$trainfilename $wekapath/data/$expno/$name/$method/
        cp ARFF/$method/$testfilename $wekapath/data/$expno/$name/$method/
      done
    elif [[ "$method" = "pls" || "$method" = "pca" ]]; then
        
        for (( i=1; i<=$NUMFOLDS; i++ ))
        do
        #skip=1; if [ $skip -ne 1 ]; then
        echo $method start 
        #PLS/PCA transformation in Octave
  
        #Transform RAW to PCA or PLS step 2 and 3 
        cp Matlab/raw/$name\_trainset$i.data trainset.data
        #--only need for pls
        cp Matlab/raw/$name\_trainset$i.class trainset.class
        echo coping class file 
        cp ../datasets/classfiles/$name.sed class.sed
        echo "finished"
        sed -f class.sed trainset.class > temp
        mv temp trainset.class
        #--
        cp Matlab/raw/$name\_testset$i.data testset.data 
        octave -qf $method\_main.m 
        mv trainset.txt Matlab/$method/$method\_$name\_trainset$i.txt 
        mv testset.txt  Matlab/$method/$method\_$name\_testset$i.txt
        rm trainset.data trainset.class testset.data 
        #echo $foldernumber
        echo "$method finished"
  
        #arff files for PLS/PCA
        #it also needed to create all attributes in separate files
        #if number of args is 6, it makes indivial files if not otherwise
        cp oct2arff.sh functions.sh Matlab/$method/
        cd Matlab/$method
          numinstr=`cat ../raw/$name\_trainset$i.data | wc -l` #no of train instances
          numinste=`cat ../raw/$name\_testset$i.data | wc -l` #no of test instances
          if [ "$method" = "pls" ]; then
            numatt=`expr $numinstr - 1`
          else
            numatt=$numinstr
          fi
          sh oct2arff.sh $method\_$name\_trainset$i.txt ../raw/$name\_trainset$i.class  $numinstr $numatt $classlist 1 $numberofmethodattributes
          sh oct2arff.sh $method\_$name\_testset$i.txt ../raw/$name\_testset$i.class  $numinste $numatt $classlist 1 $numberofmethodattributes
          mkdir -p ../../ARFF/$method
          mv *.arff ../../ARFF/$method
          rm oct2arff.sh functions.sh
        cd -
        #fi
        trainfilename=$method\_$name\_trainset$i\_$numberofmethodattributes.arff
        testfilename=$method\_$name\_testset$i\_$numberofmethodattributes.arff
        cp ARFF/$method/$trainfilename $wekapath/data/$expno/$name/$method/
        cp ARFF/$method/$testfilename $wekapath/data/$expno/$name/$method/
        done
    fi

    cd $wekapath/
      echo "$method Accuracy"
      for (( i=1; i<=$NUMFOLDS; i++ ))
      do
        if [[ "$method" = "pls" || "$method" = "pca" || "$method" = "ig" || "$method" = "relieff" ]]; then
        trainfilename=$method\_$name\_trainset$i\_$numberofmethodattributes.arff
        testfilename=$method\_$name\_testset$i\_$numberofmethodattributes.arff
        else
        trainfilename=$method\_$name\_trainset$i.arff
        testfilename=$method\_$name\_testset$i.arff
        fi
        if [ "$classifier" = "RF" ]; then 
          java  -classpath ";weka.jar" weka.classifiers.trees.RandomForest -I 100 -K 0 -S 1 -t data/$expno/$name/$method/$trainfilename -T data/$expno/$name/$method/$testfilename > data/$expno/$name/$method/Results/Results$classifier\_$trainfilename.txt
          java  -classpath ";weka.jar" weka.classifiers.trees.RandomForest -I 100 -K 0 -S 1 -t data/$expno/$name/$method/$trainfilename -T data/$expno/$name/$method/$testfilename -p 0 > data/$expno/$name/$method/Results/Results$classifier\_$trainfilename\_predictions.txt
        else
          echo "Wrong classifier"
        fi
      done

      rm -f $name\_$classifier\_$method
      for (( foldernumber=1; foldernumber<=$NUMFOLDS; foldernumber++ ))
      do
        if [[ "$method" = "pls" || "$method" = "pca" || "$method" = "ig" || "$method" = "relieff" ]]; then
          grep "^Correctly" data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset$foldernumber\_$numberofmethodattributes.arff.txt | tail -n 1 | awk '{ print $5 }' > $name\_$classifier\_$method\_$foldernumber
        else
          grep "^Correctly" data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset$foldernumber.arff.txt | tail -n 1 | awk '{ print $5 }' > $name\_$classifier\_$method\_$foldernumber
        fi
        #grep "^Correctly" data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset$foldernumber.arff.txt | tail -n 1 | awk '{ print $5 }' > $name\_$classifier\_$method\_$foldernumber
        if [ $foldernumber -ne 1 ]; then
          paste -d',' $name\_$classifier\_$method $name\_$classifier\_$method\_$foldernumber > tempall && mv tempall $name\_$classifier\_$method
        else
          cat $name\_$classifier\_$method\_$foldernumber > $name\_$classifier\_$method
        fi
        rm $name\_$classifier\_$method\_$foldernumber 
      done
      if [[ "$method" = "pls" || "$method" = "pca" ]]; then
      tar -cvzf Results$classifier\_$name\_$method.tar.gz data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset*_??.arff.txt 
      elif [[ "$method" = "ig" || "$method" = "relieff" ]]; then
      tar -cvzf Results$classifier\_$name\_$method.tar.gz data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset*_???.arff.txt 
      #rm -f data/$expno/$name/$method/Results/*.txt
      else
      tar -cvzf Results$classifier\_$name\_$method.tar.gz data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset??.arff.txt data/$expno/$name/$method/Results/Results$classifier\_$method\_$name\_trainset?.arff.txt 
      fi
    cd -

    mkdir -p Results/$method
    mv $wekapath/Results$classifier\_$name\_$method.tar.gz Results/$method/
    mv $wekapath/$name\_$classifier\_$method Results/$method/

    cd Results
      awk 'BEGIN {FS=","} { print (($1+$2+$3+$4+$5+$6+$7+$8+$9+$10)/10) }' $method/$name\_$classifier\_$method > $name\_$classifier\_$method\_avg
    cd -
  done
  #fi
  exit
fi
####

if [ $2 -eq 40014 ]; then #ff2
  source ff2.sh
  exit 0
fi

#classifier fusion from 40014
if [ $2 -eq 40015 ]
then 
  source cf2.sh
  exit 0
fi

#Feature fusion 
if [ $2 -eq 40012 ]
then
  source ff1.sh
  exit 0
fi

#Cascading Classifiers
if [ $2 -eq 41016 ]
then
  #source cc1.sh
  source cc1.ai.sh
  exit 0
fi

# Bay Modified # 20121005
if [ $2 -eq 43017 ]
then
  source /cygdrive/c/SampathDeegalla/Experiments/exp43/createDRfiles.sh
  source /cygdrive/c/SampathDeegalla/Experiments/exp43/modifiedbay.sh
  #source /cygdrive/c/SampathDeegalla/Experiments/exp43/modifiedbay.new.sh
  exit 0
fi

# Bay # 20121014
if [ $2 -eq 43018 ]
then
  ##source /home/sampath/myfiles/sampath/Experiments/exp47/bay.sh || exit 
  #source /media/sampath_home/sampath/Experiments/exp48/bay.sh || exit
  #source /media/sampath_home/sampath/Experiments/exp48/bay2.sh || exit
  source /media/sampath_home/sampath/Experiments/exp48/baypred.sh || exit
  ##source /home/ubuntu/Experiments/exp47/bayv2.sh || exit
  exit 0
fi

# Bay Individual Run Files  # 20160126
if [ $2 -eq 47022 ]
then
  #source /media/sampath_home/sampath/Experiments/exp47/bayindividualrun.sh || exit
  source /media/sampath_home/sampath/Experiments/exp48/bayindividualrunV2.sh || exit
  exit 0
fi

# RP # 20131022
if [ $2 -eq 44019 ]
then
  ##source /home/sampath/myfiles/sampath/Experiments/exp47/rp.sh || exit
  #source /media/sampath_home/sampath/Experiments/exp48/rp.sh || exit
  #source /media/sampath_home/sampath/Experiments/exp48/rp2.sh || exit
  source /media/sampath_home/sampath/Experiments/exp48/rppred.sh || exit
  exit 0
fi

# RP Individual Run Files  # 20160126
if [ $2 -eq 47023 ]
then
  source /media/sampath_home/sampath/Experiments/exp48/rpindividualrun.sh || exit
  #source /media/sampath_home/sampath/Experiments/exp47/rpindividualrunV2.sh || exit
  exit 0
fi

# bay new # 20190222
if [ $2 -eq 48024 ]
then
  source /media/sampath_home/sampath/Experiments/exp48/bay.new.sh || exit
  exit 0
fi

# knn for k 1 3 5 7 9
if [ $2 -eq 48025 ]
then
  source /media/sampath_home/sampath/Experiments/exp48/rawibk.sh || exit
  exit 0
fi

# Decision trees 
if [ $2 -eq 48026 ]
then
  source /cygdrive/c/Experiments/exp48/rawj48.sh || exit
  exit 0
fi

# Random Forests 
if [ $2 -eq 48027 ]
then
  source /cygdrive/c/Experiments/exp48/rawrf.sh || exit
  exit 0
fi

# SVM Linear Kernel 2021.06.09 
if [ $2 -eq 48028 ]
then
  source /cygdrive/c/Experiments/exp48/rawsvm.sh || exit
  exit 0
fi

# RP diff number of ensembles as 1 5 10 25 50 
if [ $2 -eq 46020 ]
then
  source /export/home/hpc-admin/exp46/rp_changed_no_ensembles.sh 
  exit 0
fi

# Bay diff number of ensembles as 1 5 10 25 50 
if [ $2 -eq 46021 ]
then
  source /export/home/hpc-admin/exp46/bay_changed_no_ensembles.sh 
  exit 0
fi

if [ $2 -eq 3371 ]
then
  source ff1accuracy.sh
  exit 0
fi

if [ $2 -eq 338 ]
then
  source cf1.sh
  exit 0
fi
