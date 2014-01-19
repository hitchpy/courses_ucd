count_freqC = function(fname){
  .Call('freq_table',fname)
}
IntegerFrequencyTable = 
function(table)
{
  class(table) = c("IntegerFrequencyTable", "DiscreteFrequencyTable", "table")
  table
}

main_funcC = function(fnames){
  results = rep(0.0,6000)
  for( fname in fnames){
    results=results+count_freqC(fname)
	}
  IntegerFrequencyTable(results)
}