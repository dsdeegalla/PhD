function [T_Train,T_Test]=ds_pls(X_Train,Y_Train,X_Test,PLScomp);
% ------------------------------------------------------------------------
% Function: [T_Train,T_Test]=ds_pls(X_Train,Y_Train,X_Test,PLScomp)
% ------------------------------------------------------------------------
% Aim:
% SIM-PLS 
% ------------------------------------------------------------------------
% Input: 
% X_Train : p x n matrix
% Y_Train : p x 1 
% X_Test : p x n2 matrix
% PLScomp : number of PLS component

%for i=1:10
    %disp('Hi');
    
    %X=(in_data_train1.X)';
    %Y=(in_data_train1.y)';
    %X_test=test1';
    %Only needed if you are using in_data_train
    %X=X_Train';
    %Y=Y_Train';
    %X_test=X_Test';
    
    X=X_Train;
    Y=Y_Train;
    X_test=X_Test;
    
    
    
    %mean centred data
    [r c]=size(X);
    X=X-repmat(mean(X),r,1);
    %edited on 21.04.2009
    [r2 c2]=size(X_test);
    X_test=X_test-repmat(mean(X_test),r2,1);
    [r1 c1]=size(Y);
    Y=Y-repmat(mean(Y),r1,1);
    %Y=Y-mean(Y);
    
    % 1/ for non tall matrix: 
    [B,C,P,T_Train,U,R_Train,R2X,R2Y]=simpls(X,Y,PLScomp,[],X'*X);
    clear B C P U  R2X R2Y
    T_Test=X_test*R_Train;
    clear X Y X_test R_Train
    
%end
    
