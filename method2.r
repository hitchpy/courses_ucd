

fnames=list.files(,pattern='*.csv')

count_freqR=function(fname){

 #   freqtable=rep(0.0,6000)
	headerLine <- readLines(fname, n=1)
    headerFields <- unlist(strsplit(headerLine, split=","))
    if('"ARR_DELAY"' %in% headerFields){
	    
		coln=which(headerFields == '"ARR_DELAY"')+2
	}else{
	    
		coln=which(headerFields == 'ArrDelay')
    }
	
	command = paste('cat',fname,'|cut -f',coln,'-d ,|tail -n+2')
	arrdelay = system(command,intern=TRUE)
	
	arrdelay = suppressWarnings( as.integer( arrdelay ))[ !is.na( arrdelay )]	
#change to table method 	
#	for(i in 1:length(arrdelay) ){
#   freqtable[arrdelay[i]]=freqtable[arrdelay[i]]+1
#	}

    table(arrdelay)
}

##calling the method to return tables for each year/month
main_func=function(fnames){
  all_table = lapply( fnames,count_freqR)
  main_table = do.call( c,all_table)
  main_table = main_table[order( as.integer( names( main_table)))]

  len = sum( main_table)
  med =names( which( cumsum( main_table) >= len/2 )[ 1 ] )
  me = sum( as.integer( names( main_table)) * main_table ) / sum( main_table)
  std = sqrt( sum( as.integer( names( main_table))^2 * main_table ) - ( me * len) )
  list(mean=me,sd=std,median=med)
}