library(ArrDelays)
library(parallel)

files = list.files(,pattern = '(19.{2}|200[1-7])\\.csv$')
cl = makeCluster(2, 'FORK')
ff = clusterSplit(cl, files)
system.time(result.list <- clusterApply(cl, ff, main_funcC))

result = result.list[[1]]
for(i in 2:length(result.list)){
  result = result +result.list[[i]]
}
#the time basically is 2X faster when doubles the nodes