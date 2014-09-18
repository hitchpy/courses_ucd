
#######
##Getting the data

library('rsae')
data(landsat)
dat = landsat[,3:6] 
dat$x1x2 = dat[,3] * dat[,4]
dat$x12 = dat[,3] * dat[,3]
dat$x22 = dat[,4] * dat[,4]
dat = cbind(dat,landsat$CountyName)
dat[,1:7] = scale(dat[,1:7], center = FALSE)
colnames(dat)[8] = 'county'


#####
# Model selection

library(lme4)
fullmodel = lmer(HACorn ~ PixelsCorn + 
                   PixelsSoybeans + x1x2 + x12 + x22 + (1 | county ),
                 data = dat, REML = FALSE)

### Added Z matrix, which is used in bootstrap sampling later
Z = getME(fullmodel,'Z')

fixeffect = fixef(fullmodel)
rand = attributes(VarCorr(fullmodel)[[1]])$stddev
# sd for random effect and residuals
resis = sigma(fullmodel)


intercepts = rep(1,37)
fixs = as.numeric(as.matrix(cbind(intercepts,dat[,3:7])) %*% fixeffect)
bootsample = replicate(100,(fixs + as.numeric(Z %*% rnorm(12,0,rand)) +
                              #updated here to incoporate Z
                              rnorm(37,0, resis)),simplify='array')
### Obtain Bootstrap dataset

#######################################################################

Xmatrix = dat[,3:8]
varnames = c("x1","x2","x3","x4","x5",'county','y')

getloglik = function(i, sample){
   ## Helper function to fit the 
   ## submodel, get the minimum logLik
  newdata = cbind(Xmatrix, sample)
  colnames(newdata) = varnames ##setup the new data with 
                              ## bootstrap sample y.
  
  if (i != 0) {    ### zero dimension model will cause error
    combin = combn(5, i)
    len = dim(combin)[2]
    slots = rep(0, len)
    for(j in 1:len){
      formular = as.formula(paste("y ~ ",paste(varnames[combin[, j]], collapse = '+'),
                                  '+ (1 | county)' ))
      m = lmer(formular, data = newdata, REML=FALSE)
    slots[j] =  - logLik(m)[1]   #get neg logLik 
    }
    return(slots)
  }else{ 
    ## for null model
    m = lmer(y ~ 1 + (1 | county),data = newdata, REML = FALSE)
     return( -logLik(m)[1] )
    }#null model 
  
}


getmodel = function(C, data){  ##main body
  ## 5 choose n, maximum is 5 choose 2 = 10, so set it to 6*10
  ## 6 is because i from 0:5, meaning null model to full model
  countmatrix = matrix(rep(0,60),nrow=6)
  getopt = function(sample){
    ### the main update function, for each boot sample,
    ### find the opt model using minmum dim criteria
    ### Then update the count table
    full = getloglik(5, sample)
    for(i in 0:5){
      temp = getloglik(i, sample)
      if(any(temp-full <C)){
        index = which.min(temp)   # check which model is picked, update
        countmatrix[(i+1),index] <<- countmatrix[(i+1),index] + 1
        break
      }
    }
  }
  
  lapply(1:100,function(i)getopt(data[,i]))
  countmatrix ## change to the maximum count's freq( p* )
  ## max(countmatrix/100)
}

### Define C's range
C = 1:22