

fnames=list.files(,pattern='*.csv')

count_freqR=function(fname){

 #   freqtable=rep(0.0,6000)
	headerLine <- readLines(fname, n=1)
    headerFields <- unlist(strsplit(headerLine, split=","))
    coln=which(headerFields == 'ArrDelay')
    
	command=paste('cat',fname,'|cut -f',coln,'-d ,|tail -n+2')
	arrdelay=system(command,intern=TRUE)
	arrdelay=as.numeric(arrdelay) 	
	arrdelay=arrdelay[!is.na(arrdelay)]
#change to table method 	
#	for(i in 1:length(arrdelay) ){
#   freqtable[arrdelay[i]]=freqtable[arrdelay[i]]+1
#	}

table(arrdelay)
}

