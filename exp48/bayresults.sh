#!/bin/bash

# filename: bayresults.sh
# date: 2019.03.27
# author: Sampath Deegalla
# version: 1.0

set -e #brake if error


method=raw
numatt=$numberofattributes
not=10 # number of threads

echo '\begin{tabular}{|l|r|r|r|r|r|r|r|}'
echo '\hline'
echo 'Dataset & k & 1 & 5 & 10 & 25 & 50 & 100\\'
echo '\hline'
for name in 'colontumor' 'leukemia' 'centralnervous' 'srbct' 'lymphoma' 'brain' 'nci60' 'prostate' 'AI' 'AMPH1' 'ATA' 'COMT' 'EDC' 'HIVPR' 'HIVRT' 'HPTP' 'ace' 'ache' 'bzr' 'caco' 'cox2' 'cpd-mouse' 'cpd-rat' 'gpb' 'therm' 'thr' 'mias' 'outex' 'leedsbutterfly' 'zubud' 'car' '17flowers' 'coil100' 'irma'
do
for nok in 1 3 5 7 9
do
  acc=''
  for nocla in 1 5 10 25 50 100
  do
    #acc=`cat $name/Results/bay/nocla/$name\_bay$nok\_cla$nocla\_$method\_avg`
    acc=`cat $name/Results/rp/nocla/$name\_rp$nok\_cla$nocla\_$method\_avg`
    acc=`printf "%.2f" $acc`
    if [ $nocla -ne 1 ]; then
      nacc=$nacc' & '$acc
    else
      nacc=$acc
    fi
  done #nocla
  echo $name' & '$nok' & '$nacc'\\'
done
done
echo '\end{tabular}%'
