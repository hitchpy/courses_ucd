#Formatting and comment

fnames=list.files(,pattern='*.csv')


count_freqR=function(fname){
#this is the handling function to do
# 1, base on the header type, get column number
# 2, extract the ArrDelay, load into R and turn to int, get rid of NA
# 3, return Freq table
	headerLine <- readLines(fname, n=1)
    headerFields <- unlist(strsplit(headerLine, split=","))
    if('"ARR_DELAY"' %in% headerFields){
	    
		coln=which(headerFields == '"ARR_DELAY"')+2
	}else{
	    
		coln=which(headerFields == 'ArrDelay')
    }
	
	command = paste('cat',fname,'|cut -f',coln,'-d ,|tail -n+2')
	arrdelay = system(command,intern=TRUE)
	
	arrdelay = suppressWarnings( as.integer( arrdelay ))
    arrdelay = arrdelay[ !is.na( arrdelay )]	
#change to table method 	
#	for(i in 1:length(arrdelay) ){
#   freqtable[arrdelay[i]]=freqtable[arrdelay[i]]+1
#	}

    table(arrdelay)
}

##calling the method to return tables for each year/month
main_func=function(fnames){
#Not sure how to merge the data properly
#sort data into a freq table but with repetitive names.
#compute statistics

  all_table = lapply( fnames,count_freqR)
  main_table = do.call( c,all_table)
  main_table = main_table[order( as.integer( names( main_table)))]

  len = sum( main_table)
  med =names( which( cumsum( main_table) >= len/2 )[ 1 ] )
  me = sum( as.integer( names( main_table)) * main_table ) / len
  std = sqrt( sum( as.integer( names( main_table))^2 * main_table )/len -  me )
  list(mean=me,sd=std,median=med)
}