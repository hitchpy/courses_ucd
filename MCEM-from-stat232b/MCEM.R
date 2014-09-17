######################
# STAT232B Project3
# Yu Pei SID999438479
######################

#for getting the initial values
#using glmer in lme4 with binomial family
#result mu = -2.290324   myvar = 0.47727

##litter[[1]] = as.factor(litter[[1]])
##litter[[1]] = as.factor(litter[[1]])

#### data entry
### the final dataset is named litter, 
### and the 13*11 matrix corresponding to table 4 is named datainput, 
### all other values are trival you can remove them from R after. 
### litter has two cols, the first is y, the second is the corresponding subject number the y belongs to.  
datainput<-matrix(0,13,11)
datainput[1,1:2]<-c(15,1)
datainput[2,1:3]<-c(6,1,2)
datainput[3,1:2]<-c(6,6)
datainput[4,1:5]<-c(7,2,3,0,2)
datainput[5,1:5]<-c(16,9,3,3,1)
datainput[6,1:5]<-c(57,38,17,2,2)
datainput[7,1:8]<-c(119,81,45,6,1,0,0,1)
datainput[8,1:5]<-c(173,118,57,16,3)
datainput[8,9]<-1
datainput[9,1:7]<-c(136,103,50,13,6,1,1)
datainput[10,1:5]<-c(54,51,32,5,1)
datainput[10,10]<-1
datainput[11,1:5]<-c(13,15,12,3,1)
datainput[12,1:4]<-c(0,4,3,1)
datainput[13,3]<-c(1)
datainput[13,8]<-1
sum(datainput)
litter<-matrix(0,10533,2)
k=0
for(i in 1:13){
  for(j in 1:min(i+1,11)){
    
    tmp1<-c(rep(1,times=j-1),rep(0,times=i-j+1))
    tmp2<-rep(tmp1,times=datainput[i,j])
    if(length(tmp2)>0){
      litter[(k+1):(k+length(tmp2)),1]<-tmp2
      k<-k+length(tmp2)
    }
  }
}
row.sum=apply(datainput, 1, sum)
row.num=1:13
litter2=numeric(sum(row.sum*row.num))
end.point=0
end.lindex=0
for (i in 1:13)
{
  start.point=end.point+1
  end.point=end.point+i*row.sum[i]
  start.lindex=end.lindex+1
  end.lindex=end.lindex+row.sum[i]
  litter2[start.point: end.point]=rep(start.lindex:end.lindex, each=i)
}
litter[,2]<-litter2
colnames(litter)<-c("y","subject")
litter<-as.data.frame(litter)



yi = tapply(litter[[1]],litter[[2]],sum)
ni = table(litter[[2]])
mydata = cbind(ni,yi)


expit = function(mu ,alpha){
  exp(mu + alpha)/(1+exp(mu + alpha))
}

gentheta = function(mu,myvar,temp,alpha ,data1){
  ss1 = data1[,2]
  ss2 = data1[1,]-data1[2,]
  nomit=(expit(mu,temp)^ss1) * ((1-expit(mu,temp))^ss2)
  denomit = (expit(mu,alpha)^ss1) * (1-expit(mu,alpha)^ss2)
  nomit/denomit
}

MH = function(mu, myvar,data1, L = 7000 ){
  #For this problem, data should be two column
  #first with ni, second with yi = sum(yij)
  N0 =4000
  alpha = matrix(rep(0,1328*(L+N0)),ncol = 1328)
  alpha[1,] = rep(0,1328)
  for(i in 2:(N0+L)){
    temp = rnorm(1328,0, sqrt(myvar))
    theta = gentheta(mu,myvar,temp, alpha[(i-1),], data1)
    U = runif(1328)
    alpha[i,] = ifelse(U< pmin(1,theta),temp,alpha[(i-1),])
  }
  alpha[(N0+1):(N0+L),]
}

updatemu = function(data1, alpha,L){
  myfunc = function(mu,data1,alpha,L){
    #create the function going to be optimized
    sum(sapply(1:L,function(i){
     #for each row of alpha
      sum(data1[,2] * log(expit(mu, alpha[i,])) +(data1[,1]-data1[,2]) * log(1-expit(mu, alpha[i,])) )
    }))/L
  }
  optimize(myfunc,c(-5,0),data1,alpha,L,maximum=TRUE)$maximum###some part of the result
}

updatemyvar = function(data1, alpha,L){
  myfunc = function(myvar,data1,alpha,L){
    #create the function going to be optimized
      -(1328/2)*log(2*pi*myvar) - (1/(2*myvar)) * sum(alpha^2)/L
  }
  optimize(myfunc,c(0.1,3),data1,alpha,L,maximum=TRUE)$maximum###some part of the result
}


MCEM = function(mu0, myvar0,data1, iter = 100, L = 2000){
  output = matrix(rep(0,iter*2),ncol=2)
  alpha = replicate(L,rnorm(1328,0,sqrt(myvar0)))
  if(nrow(alpha)==1328){alpha=t(alpha)}
  ####The main EM body
  for(i in 1:iter){
    output[i,1] = updatemu(data1, alpha,L)
    output[i,2] = updatemyvar(data1, alpha,L)
	alpha = MH(output[i,1], output[i,2] ,data1, L)#a matrix of L * 1328
  }
  output
}

myrun = MCEM(-2.2903,0.477,mydata,iter = 200,L=2000)
save(myrun,file="myresult.rda")

