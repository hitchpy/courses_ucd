library(Rcpp)
library(inline)

freq_table=cfunction(signature(x='numeric'),"
  int n = length(x);
  SEXP freq;
  double *px, *pout;
  
  PROTECT(freq = allocVector(REALSXP, 6000));
  memset(REAL(freq),0,6000*sizeof(double));
  px = REAL(x);
  pout = REAL(freq);
  for(int i=0; i< n; i++){
      double temp= px[i];
	  pout[int(temp)+2999] +=1; 
  }
  UNPROTECT(1);
  
 return freq;
 ")
 
 
 count_freqC=function(fname){

    
	headerLine <- readLines(fname, n=1)
    headerFields <- unlist(strsplit(headerLine, split=","))
    if('"ARR_DELAY"' %in% headerFields){
	    
		coln=which(headerFields == '"ARR_DELAY"')+2
	}else{
	    
		coln=which(headerFields == 'ArrDelay')
    }
	
	command = paste('cat',fname,'|cut -f',coln,'-d ,|tail -n+2')
	arrdelay = system(command,intern=TRUE)
	
	arrdelay = suppressWarnings( as.numeric( arrdelay ))[ !is.na( arrdelay )]
    arrdelay = arrdelay[ !is.na( arrdelay )]
	freq_table(arrdelay)
}

main_funcC = function(fnames){
  results = rep(0.0,6000)
  for( fname in fnames){
    results=results+count_freqC(fname)
	}
  len = sum( results)
  med = which( cumsum( results) >= len/2) [ 1 ] - 3000 
  me = sum ( -2999:3000 * results ) / len
  std = sqrt( sum ( (-2999:3000)^2 * results ) - me * len )
  list(mean=me,sd=std,median=med)
}