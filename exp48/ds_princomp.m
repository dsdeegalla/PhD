## Compute principal components of X
## [pc,Trz,Tez] = ds_princomp(X)
##   pc  the principal components
##   Trz   the transformed data for Train Set
##   Trz   the transformed data for Test Set

## Author: Sampath Deegalla

function [pc,Trz,Tez] = ds_princomp(XTrain,XTest)
  C = center(XTrain);
  [U,D,pc] = svd(C,1);
  Trz = center(XTrain)*pc;
  Tez = center(XTest)*pc;
end
