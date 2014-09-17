
In this first version, I implemented two approch, and processed all the years files avalible.
ie. from 1987-2012September.


METHOD2 :In shell, cut out the ArrDelay column, then use scan()/system() to read in the data
  Then do the freq table with table(), then merge all the table together to get the statistics.

METHOUD6: use C code provided by Professor Duncan, plus my linking function. Using C code to compute frequency table. But haven't resolved the different format in 2008-2012 issue. And lack parallel support. 

Note: I haven't implemented the auto switch between column 14 and 44 yet. So main_funcC can only work with files prior to 2008.

To run the function:
1, install the R package, in shell move to the directory with ArrDelays Folder, issue R CMD INSTALL -l your/library/address ArrDelays  
2, IN R library(ArrDelays) there are 6 functions in this package. main_funcR and main_funcC take in a vector of file names(if the csv files are not in your current directory, provide the complete address)
Then the output is of class IntegerFrequencyTable, there are four function mean(),sd(),median(),length() for this class, it can be call directly on the return object, with the desired result.





Method 8 SQL - postgres
With the instruction from Class website, i can download and install the software, but in school server Macro, there is a version 8.4.* postgres psql so it will complain a little
So I added this line 
export LD_LIBRARY_PATH=/home/hitchpy/postgres/bin 
to .bashrc file so that I can start the psql with the newest version.

Then CREATE TABLE, with CREATE TABLE delays (arrdelay double precision);

Finally using the shell script setup_database, run it with   sh setup_database
to loop over all the files and cut the accordding columns, get the data into database. This process takes more than 20 Mins

Then connect in R with
install.packages("RPostgreSQL")
library(RPostgreSQL)

m = dbDriver("PostgreSQL")
con = dbConnect(m, user = "duncan", dbname = "AirlineDelays")


Finally, using freq_table=dbGetQuery(con,'SELECT arrdelay,count(*) FROM delays GROUP BY arrdelay;')
in R to get the frequency table, then can compute all the statistics. This only takes seconds.