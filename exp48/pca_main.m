%sample octave file
format short;
X=load("trainset.data");
X_test=load("testset.data");
tic(); %initiate the timer
[pc,Train,Test]=ds_princomp(X,X_test);
timepls=toc(); %calculate the time
printf("Time for PCA %.4f seconds\n", timepls);
save trainset.txt Train 
save testset.txt Test 

