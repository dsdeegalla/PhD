import string
import sys
#import os

infilename=sys.argv[1] #baymodified_$i_$j_$cla
outfilename=sys.argv[2] #baymodified_$i_$j

lines=[]
f = open(infilename)
for line in f.readlines():
    # remove new line character and
    # split it using ,
    lines.append(line.rstrip('\n').split(','))
f.close()

#os.remove(outfilename)

#lines = [
#[-1,-1,-1,-1,-1,-1],
#[-1,-1,-1,-1,1,-1],
#[-1,-1,-1,-1,-1,-1],
#[1,1,1,1,1,1],
#[1,1,1,1,1,1],
#[1,1,1,1,1,1],
#[1,1,1,1,1,-1],
#[2,1,1,2,2,3]
#]

def voting(lines):
    i=0
    updated=[]
    acccount=0
    while ( i<len(lines)):
        # class labels without true class
        updated.append(lines[i][1:])
        max=0
        label=""
        for ii in set(updated[i]):
            count=updated[i].count(ii)
            if ( max < count ):
                max=count
                label=ii
        if ( lines[i][0] == label ):
            acccount+=1
        i+=1
    avgacc=(float(acccount) / float(len(lines))) * 100
    print avgacc
    f = open (outfilename,'a')
    f.write(str(avgacc))
    f.write('\n')
    f.close()

voting(lines)
print sys.argv[1]
