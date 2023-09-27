#v0.12
#lib functions
# -- QUITE OLD --
# 2012.05.17 function: print_attribute

#function to rank attributes  based on IG
#input trainfilename testfilename numberofattributes  
#function dorankattribute {
#        train_file_name=ig_$name\_trainset$i.arff
#        test_file_name=ig_$name\_testset$i.arff
#        train_number_of_lines=`cat $train_file_name | wc -l`
#        train_number_of_instances=`expr $train_number_of_lines - $numberofattributes - 2 - 4`
#        test_number_of_lines=`cat $test_file_name | wc -l`
#        test_number_of_instances=`expr $test_number_of_lines - $numberofattributes - 2 - 4`
#        sh rankattribute.sh $train_file_name Attributes_$train_file_name.txt $numberofattributes $train_number_of_instances ig_$name\_trainset$i $mindim 1 
#        sh rankattribute.sh $test_file_name Attributes_$train_file_name.txt $numberofattributes $test_number_of_instances ig_$name\_testset$i $mindim 1 
#        rm rankattribute.sh

#function to get the number of test instances
#in a fold two parameters are needed
#1:number of instances 2:number of folds

function getnumberoftestinstancesinfolds {
  i=`expr $1 / $2`
  j=`expr $1 % $2`

  for (( a=0; a<$2; a++ ))
  do
    numberoftestinstancesinfolds[$a]=$i
  done

  while [ $j -ge 1 ]; do
    k=`expr $j - 1`
    numberoftestinstancesinfolds[$k]=`expr ${numberoftestinstancesinfolds[$k]} + 1`
    let j--
  done
  #echoed the output to captuer the return
  echo ${numberoftestinstancesinfolds[@]}
}

#Functions for directory creations #2010/02/03
function create_directories_for_results {
expno=$1
name=$2
method=$3
if [ ! -d $wekapath/data/$expno ]
then
mkdir -p $wekapath/data/$expno/$name/$method/Results
elif [ ! -d $wekapath/data/$expno/$name ]
then
mkdir -p $wekapath/data/$expno/$name/$method/Results
elif [ ! -d $wekapath/data/$expno/$name/$method ]
then
mkdir -p $wekapath/data/$expno/$name/$method/Results
elif [ ! -d $wekapath/data/$expno/$name/$method/Results ]
then
mkdir -p $wekapath/data/$expno/$name/$method/Results
fi
echo "Directories created"
}
#function create_directories_for_results {
#expno=$1
#name=$2
#if [ ! -d $wekapath/data/$expno ]
#then
#mkdir -p $wekapath/data/$expno/$name/Results
#elif [ ! -d $wekapath/data/$expno/$name ]
#then
#mkdir -p $wekapath/data/$expno/$name/Results
#elif [ ! -d $wekapath/data/$expno/$name/Results ]
#then
#mkdir $wekapath/data/$expno/$name/Results
#fi
#echo "Directories created"
#}

function create_directories_for_attributeselect {
expno=$1
name=$2
if [ ! -d $wekapath/data/$expno ]
then
mkdir -p $wekapath/data/$expno/$name/AttributeSelect
elif [ ! -d $wekapath/data/$expno/$name ]
then
mkdir -p $wekapath/data/$expno/$name/AttributeSelect
elif [ ! -d $wekapath/data/$expno/$name/AttributeSelect ]
then
mkdir $wekapath/data/$expno/$name/AttributeSelect
fi
echo "Directories created"
}

#remove summary files
function remove_summaryfiles {
name=$1
method=$2
  if [ -f $name\_$method\_all ]; then
    rm $name\_$method\_all
  fi
 
  if [ -f $name\_$method ]; then
    rm $name\_$method
  fi
}

#Function on ARFF Format

function print_relation_name
{
echo "@relation $1"  
echo 
}

#$1 = attribute name
#$2 = attribute type

function print_attribute
{
echo "@attribute $1 $2"
}

function print_attribute_list
{
for ((x=1; x<=$1; x++)) 
do 
  if [ -n $2 ]; then
    attribute_name=$2$x
  else
    attribute_name=$x
  fi
  echo "@attribute $attribute_name numeric" 
done
}

function print_attribute_list_file
{
 cat $1
}

function print_attribute_class
{
  echo "@attribute class? { $1 }" 
}

function print_data
{
  echo
  echo "@data"
  echo
  if [ -n $2 ]; then
    paste -d',' $1 $2 | tr -d '\15\32'
  else
    cat $1 | tr -d '\15\32'
  fi
}

function attribute_select
{
expno=$1
name=$2
method=$3
numatt=$4
filename=$5

 if [ "$method" = "ig" ]; then
   java  -classpath ";weka.jar" weka.attributeSelection.InfoGainAttributeEval -s "weka.attributeSelection.Ranker -N $numatt" -i data/$expno/$name/$method/$filename > data/$expno/$name/$method/AttributeSelect/Attributes_$filename.txt  
 elif [ "$method" = "relieff" ]; then
   java  -classpath ";weka.jar" weka.attributeSelection.ReliefFAttributeEval -s "weka.attributeSelection.Ranker -N $numatt" -i data/$expno/$name/$method/$filename > data/$expno/$name/$method/AttributeSelect/Attributes_$filename.txt
 fi  
}

function attribute_rank
{
expno=$1
name=$2
method=$3
numatt=$4
filename=$5
i=$6

  mkdir -p ARFF/$method/AttributeSelect
  cp rankattribute.sh rankchild.sh ARFF/$method/
  cp $wekapath/data/$expno/$name/$method/AttributeSelect/Attributes_$filename.txt ARFF/$method/AttributeSelect/
  cd ARFF/$method
    cp ../raw/raw_$name\_trainset$i.arff $method\_$name\_trainset$i.arff
    cp ../raw/raw_$name\_testset$i.arff $method\_$name\_testset$i.arff
    train_file_name=$method\_$name\_trainset$i.arff
          test_file_name=$method\_$name\_testset$i.arff
          train_number_of_lines=`cat $train_file_name | wc -l`
          train_number_of_instances=`expr $train_number_of_lines - $numberofattributes - 2 - 4`
          test_number_of_lines=`cat $test_file_name | wc -l`
          test_number_of_instances=`expr $test_number_of_lines - $numberofattributes - 2 - 4`
          sh rankattribute.sh $train_file_name AttributeSelect/Attributes_$train_file_name.txt $numberofattributes $train_number_of_instances $method\_$name\_trainset$i $numatt 1
          sh rankattribute.sh $test_file_name AttributeSelect/Attributes_$train_file_name.txt $numberofattributes $test_number_of_instances $method\_$name\_testset$i $numatt 1
          rm rankattribute.sh rankchild.sh
        cd -
}
