

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
	
	arrdelay = suppressWarnings(as.integer(arrdelay))
    arrdelay = arrdelay[!is.na(arrdelay)]	
#change to table method 	
#	for(i in 1:length(arrdelay) ){
#   freqtable[arrdelay[i]]=freqtable[arrdelay[i]]+1
#	}

    table(arrdelay)
}
IntegerFrequencyTable = 
function(table)
{
  class(table) = c("IntegerFrequencyTable", "DiscreteFrequencyTable", "table")
  table
}
##calling the method to return tables for each year/month
main_funcR=function(fnames){
  all_table = lapply( fnames,count_freqR)
  main_table = do.call( c,all_table)
  main_table = main_table[order( as.integer( names( main_table)))]
IntegerFrequencyTable(main_table)
}


length.IntegerFrequencyTable =
function(tt){
 sum(tt)
}

median.IntegerFrequencyTable =
function(tt){
  names(which( cumsum(tt) >= sum(tt)/2 )[ 1 ] )
}

mean.IntegerFrequencyTable =
function(tt){
  sum( as.integer( names(tt)) * tt) / sum(tt)
}

sd.IntegerFrequencyTable =
function(tt){
  sqrt( sum( as.integer( names(tt))^2 * tt)/sum(tt) -  me )
}
