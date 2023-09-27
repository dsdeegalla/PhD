#!/usr/bin/bash -x
# modified: 2019.02.21 2015.03.04

#printf "%-15s\t%s\t%s\t%s\t%s\t%s\t%s\n" "Dataset" "Raw Accuracy" "Precision" "Recall" "AUC" "Bay" "RP" 

#for dataset in 'mias' 'outex' 'leedsbutterfly' 'zubud' 'car' '17flowers' 'coil100' 'irma'
#for dataset in 'AI' 'AMPH1' 'ATA' 'COMT' 'EDC' 'HIVPR' 'HIVRT' 'HPTP' 'ace' 'ache' 'bzr' 'caco' 'cox2' 'cpd-mouse' 'cpd-rat' 'gpb' 'therm' 'thr'
#printf "%s\t\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" 'dataset' 'raw' 'rs' 'rp' 'rpne1' 'rpne5' 'rpne10' 'rpne25' 'rpne50' 'rsne1' 'rsne5' 'rsne10' 'rsne25' 'rsne50' 
#for dataset in 'centralnervous' 'colontumor' 'leukemia' 'prostate' 'brain' 'lymphoma' 'nci60' 'srbct' 
#printf "%-15s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n" "Dataset" "Raw" "Precis" "Recall" "AUC" "RawIB1" "RawIB3" "RawIB5" "RawIB7" "RawIB9"  #$bay $rp
printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n" "Dataset" "Raw" "Precis" "Recall" "AUC" "RawIB1" "RawIB3" "RawIB5" "RawIB7" "RawIB9" "RecallIB1" "RecallIB3" "RecallIB5" "RecallIB7" "RecallIB9" "PrecisIB1" "PrecisIB3" "PrecisIB5" "PrecisIB7" "PrecisIB9" "AUCIB1" "AUCIB3" "AUCIB5" "AUCIB7" "AUCIB9" "BAYIB1" "BAYIB3" "BAYIB5" "BAYIB7" "BAYIB9" "RPIB1" "RPIB3" "RPIB5" "RPIB7" "RPIB9" "RawDT" "RecDT" "PreDT" "AUCDT" "RawRF" "RecRF" "PreRF" "AUCRF" #$bay $rp
for dataset in 'centralnervous' 'colontumor' 'leukemia' 'prostate' 'brain' 'lymphoma' 'nci60' 'srbct' 'AI' 'AMPH1' 'ATA' 'COMT' 'EDC' 'HIVPR' 'HIVRT' 'HPTP' 'ace' 'ache' 'bzr' 'caco' 'cox2' 'cpd-mouse' 'cpd-rat' 'gpb' 'therm' 'thr' 'outex' 'zubud' 'mias' 'coil100' 'irma' '17flowers' 'leedsbutterfly' 'car'
do
  raw=`cat $dataset/Results/$dataset\_raw_avg`
  raw_precision=`cat $dataset/Results/$dataset\_raw_precision_avg`
  raw_recall=`cat $dataset/Results/$dataset\_raw_recall_avg`
  raw_auc=`cat $dataset/Results/$dataset\_raw_auc_avg`
  rawIB1=`cat $dataset/Results/$dataset\_raw_IB1_avg`
  rawIB3=`cat $dataset/Results/$dataset\_raw_IB3_avg`
  rawIB5=`cat $dataset/Results/$dataset\_raw_IB5_avg`
  rawIB7=`cat $dataset/Results/$dataset\_raw_IB7_avg`
  rawIB9=`cat $dataset/Results/$dataset\_raw_IB9_avg`
  precisionIB1=`cat $dataset/Results/$dataset\_raw_IB1_precision_avg`
  precisionIB3=`cat $dataset/Results/$dataset\_raw_IB3_precision_avg`
  precisionIB5=`cat $dataset/Results/$dataset\_raw_IB5_precision_avg`
  precisionIB7=`cat $dataset/Results/$dataset\_raw_IB7_precision_avg`
  precisionIB9=`cat $dataset/Results/$dataset\_raw_IB9_precision_avg`
  recallIB1=`cat $dataset/Results/$dataset\_raw_IB1_recall_avg`
  recallIB3=`cat $dataset/Results/$dataset\_raw_IB3_recall_avg`
  recallIB5=`cat $dataset/Results/$dataset\_raw_IB5_recall_avg`
  recallIB7=`cat $dataset/Results/$dataset\_raw_IB7_recall_avg`
  recallIB9=`cat $dataset/Results/$dataset\_raw_IB9_recall_avg`
  aucIB1=`cat $dataset/Results/$dataset\_raw_IB1_auc_avg`
  aucIB3=`cat $dataset/Results/$dataset\_raw_IB3_auc_avg`
  aucIB5=`cat $dataset/Results/$dataset\_raw_IB5_auc_avg`
  aucIB7=`cat $dataset/Results/$dataset\_raw_IB7_auc_avg`
  aucIB9=`cat $dataset/Results/$dataset\_raw_IB9_auc_avg`
  bayIB1=`cat $dataset/Results/bay/$dataset\_bay1_raw_avg`
  bayIB3=`cat $dataset/Results/bay/$dataset\_bay3_raw_avg`
  bayIB5=`cat $dataset/Results/bay/$dataset\_bay5_raw_avg`
  bayIB7=`cat $dataset/Results/bay/$dataset\_bay7_raw_avg`
  bayIB9=`cat $dataset/Results/bay/$dataset\_bay9_raw_avg`
  rpIB1=`cat $dataset/Results/rp/$dataset\_rp1_raw_avg`
  rpIB3=`cat $dataset/Results/rp/$dataset\_rp3_raw_avg`
  rpIB5=`cat $dataset/Results/rp/$dataset\_rp5_raw_avg`
  rpIB7=`cat $dataset/Results/rp/$dataset\_rp7_raw_avg`
  rpIB9=`cat $dataset/Results/rp/$dataset\_rp7_raw_avg`
  rawj48=`cat $dataset/Results/$dataset\_raw_j48_avg`
  rawj48_precision=`cat $dataset/Results/$dataset\_raw_j48_precision_avg`
  rawj48_recall=`cat $dataset/Results/$dataset\_raw_j48_recall_avg`
  rawj48_auc=`cat $dataset/Results/$dataset\_raw_j48_auc_avg`
  rawrf=`cat $dataset/Results/$dataset\_raw_rf_avg`
  rawrf_precision=`cat $dataset/Results/$dataset\_raw_rf_precision_avg`
  rawrf_recall=`cat $dataset/Results/$dataset\_raw_rf_recall_avg`
  rawrf_auc=`cat $dataset/Results/$dataset\_raw_rf_auc_avg`

  #bay=`cat $dataset/$dataset\_bay_raw_avg`
  #rp=`cat $dataset/$dataset\_rp_raw_avg`
  
  #rpne1=`cat $dataset/Results/$dataset\_rp_raw_ne1_avg`
  #rpne5=`cat $dataset/Results/$dataset\_rp_raw_ne5_avg`
  #rpne10=`cat $dataset/Results/$dataset\_rp_raw_ne10_avg`
  #rpne25=`cat $dataset/Results/$dataset\_rp_raw_ne25_avg`
  #rpne50=`cat $dataset/Results/$dataset\_rp_raw_ne50_avg`
  #bayne1=`cat $dataset/Results/$dataset\_bay_raw_ne1_avg`
  #bayne5=`cat $dataset/Results/$dataset\_bay_raw_ne5_avg`
  #bayne10=`cat $dataset/Results/$dataset\_bay_raw_ne10_avg`
  #bayne25=`cat $dataset/Results/$dataset\_bay_raw_ne25_avg`
  #bayne50=`cat $dataset/Results/$dataset\_bay_raw_ne50_avg`
  #echo $dataset $raw #$bay $rp
  #echo $dataset $raw $bay $rp $rpne1 $rpne5 $rpne10 $rpne25 $rpne50
  #printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n" $dataset $raw $bay $rp $rpne1 $rpne5 $rpne10 $rpne25 $rpne50
  #printf "%-15s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n" $dataset $raw $bay $rp $rpne1 $rpne5 $rpne10 $rpne25 $rpne50
  #printf "%-15s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t\n" $dataset $raw $bay $rp $rpne1 $rpne5 $rpne10 $rpne25 $rpne50 $bayne1 $bayne5 $bayne10 $bayne25 $bayne50
  #printf "%-15s\t%.2f\t%.2f\t%.2f\n" $dataset $raw $bay $rp
  #printf "%-15s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n" $dataset $raw $raw_precision $raw_recall $raw_auc $rawIB1 $rawIB3 $rawIB5 $rawIB7 $rawIB9  $precisionIB1 #$bay $rp
  #\t%.2f
  # tab separated
  #printf "%-15s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n" $dataset $raw $raw_precision $raw_recall $raw_auc $rawIB1 $rawIB3 $rawIB5 $rawIB7 $rawIB9  $precisionIB1 $precisionIB3 $precisionIB5 $precisionIB7 $precisionIB9 $recallIB1 $recallIB3 $recallIB5 $recallIB7 $recallIB9 $aucIB1 $aucIB3 $aucIB5 $aucIB7 $aucIB9 #$bay $rp
  # comma separated  
printf "%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n" $dataset $raw $raw_precision $raw_recall $raw_auc $rawIB1 $rawIB3 $rawIB5 $rawIB7 $rawIB9  $precisionIB1 $precisionIB3 $precisionIB5 $precisionIB7 $precisionIB9 $recallIB1 $recallIB3 $recallIB5 $recallIB7 $recallIB9 $aucIB1 $aucIB3 $aucIB5 $aucIB7 $aucIB9 $bayIB1 $bayIB3 $bayIB5 $bayIB7 $bayIB9 $rpIB1 $rpIB3 $rpIB5 $rpIB7 $rpIB9 $rawj48 $rawj48_precision $rawj48_recall $rawj48_auc $rawrf $rawrf_precision $rawrf_recall $rawrf_auc #$bay $rp
done
