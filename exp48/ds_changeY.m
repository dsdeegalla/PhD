function Y=ds_changeY(z)
y=z';
numberofattributes=max(y);
[r c]=size(y);
Y1=zeros(numberofattributes,c);
for i=1:numberofattributes
   for j=1:c
      if y(j) == i
          Y1(i,j)=1;
      end
   end
end
Y=Y1';
