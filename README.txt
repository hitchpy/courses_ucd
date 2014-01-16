
In this first version, I implemented two approch, and processed all the years files avalible.
ie. from 1987-2012September.


METHOD2 :In shell, cut out the ArrDelay column, then use scan()/system() to read in the data
  Then do the freq table with table(), then merge all the table together to get the statistics.

METHOUD6: Almost the same except use C to write a frequency table method to replace table(),then change the merge method slightly.



To run the code, you need package inline and Rcpp. 
source('method2.r');source('method6.r')

Then run 
main_func(fnames) / main_funcC(fnames) 