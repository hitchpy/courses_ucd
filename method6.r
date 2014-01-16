library(Rcpp)
library(inline)

freq_table=cfunction(signature(x='numeric'),"
  int n = length(x);
  SEXP freq;
  double *px, *pout;
  
  PROTECT(freq = allocVector(REALSXP, 10000));
  memset(REAL(freq),0,10000*sizeof(double));
  px = REAL(x);
  pout = REAL(freq);
  for(int i=0; i< n; i++){
      double temp= px[i];
	  pout[int(temp)+4999] +=1; 
  }
  UNPROTECT(1);
  
 return freq;
 ")
 
 
 count_freqC=function(fname){

    
	headerLine <- readLines(fname, n=1)
    headerFields <- unlist(strsplit(headerLine, split=","))
    coln=which(headerFields == 'ArrDelay')
    coln=coln
    
	command=paste('cat',fname,'|cut -f',coln,'-d ,|tail -n+2')
	arrdelay=system(command,intern=TRUE)
	arrdelay=as.numeric(arrdelay) 	
	arrdelay=arrdelay[!is.na(arrdelay)]
	freq_table(arrdelay)
}