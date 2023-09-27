%sample octave file
format short;
X=load("trainset.data");
[r c]=size(X);
X_test=load("testset.data");
Y=load("trainset.class");
tic(); %initiate the timer
[PLS_train,PLS_test]=ds_pls(X,ds_changeY(Y),X_test,r-1);
timepls=toc(); %calculate the time
printf("Time for PLS %.4f seconds\n", timepls);
save trainset.txt PLS_train; 
save testset.txt PLS_test; 

%[pc,Train,Test]=ds_princomp(A,B);
%save pca_colontumor_trainset1.data Train 
%save pca_colontumor_testset1.data Test 
%X=load("colontumor_trainset1.data");
%X_test1=load("colontumor_testset1.data");
%Y=load("colontumor_trainset1.class");
%[PLS_train1,PLS_test1]=ds_pls(X,ds_changeY(Y),X_test1,20)
%X=[1 5 4 4 3; 2 9 3 2 6; 5 6 7 2 7; 3 1 2 4 3]
%X_test1=X
%Y=[1; 1; 2; 2]
%[PLS_train1,PLS_test1]=ds_pls(X,ds_changeY(Y),X_test1,2)
