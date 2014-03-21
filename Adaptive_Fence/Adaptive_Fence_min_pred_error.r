####################################
###
###          PART II
######## Model selection ###########

library(lme4)
fullmodel = lmer(HACorn ~ PixelsCorn + 
                   PixelsSoybeans + x1x2 + x12 + x22 + (1 | county ),
                 data = dat, REML = FALSE)

### Add Z matrix, use in bootstrap sampling later
Z = getME(fullmodel,'Z')

fixeffect = fixef(fullmodel)
rand = attributes(VarCorr(fullmodel)[[1]])$stddev
# sd for random effect and residuals
resis = sigma(fullmodel)

n_row_dat = nrow(dat)

intercepts = rep(1, n_row_dat)
fixs = as.numeric(as.matrix(cbind(intercepts, dat[ ,3:7])) %*% fixeffect)
bootsample = replicate(100, (fixs + as.numeric(Z %*% rnorm(ncounty, 0, rand)) +
                               #updated here to incoporate Z
                               rnorm(n_row_dat, 0, resis)), simplify='array')
### Obtain Bootstrap dataset


getMSPE = function(cols, model, sample){
  ## for each boot sample, in the fence, we calculate
  ## the MSPE according to the equation
  beta = fixef(model)
  sigma_v = attributes(VarCorr(model)[[1]])$stddev
  sigma_v2 = sigma_v^2
  sigma_e = sigma(model) 
  sigma_e2 = sigma_e^2
  yi_bar = sum_j(sample) / ni
  y2 = sum_j(sample * sample) / ni
  temp = (ni*sigma_v2)/(sigma_e2+ni*sigma_v2)
  vec1 = as.numeric(X_BIG[,c(1,cols)] %*% beta)
  vec2 = as.numeric(x_small[, c(1,cols)] %*% beta)
  #### Added K to simplify later expression
  K = (ni / Ni + (1 - ni / Ni) * temp)
  
  ####################
  alternative = sapply((cols-1), function(i){
    sum_j(Xmatrix[,i] * sample)/ni - sum_j_2(Xmatrix[, i], sample )
  } )
  
  alternative = cbind(yi_bar, alternative)
  temp2 = as.numeric(alternative %*% beta)
  ################################################
  
  
  #### The four actual parts in the equation
    mu_i_squre = vec1^2 + (2 * K *(temp2 - (vec1 * vec2)  ) )+ (K * (yi_bar - vec2))^2 
    a_i  = (1-ni/Ni) * (sigma_e2/(sigma_e2+ni*sigma_v2))
    b_i  =  1 - 2* (ni/Ni + (1-ni/Ni)*temp) 
    mu_tilda2 = y2 - sum_j_2(sample, sample)
    
    mspe_v = mu_i_squre - 2*a_i*temp2 + b_i*mu_tilda2
    ################## joint estimate xi*yi
    sum(mspe_v)

}


getmodel_p2 = function(C, data){  ##main body
  
  ## We don't conside i = 0 for MSPE since there is only intercept
  n_type = 5
  
  countmatrix = matrix(rep(0, n_type*10),nrow=n_type)
  
  getopt_p2 = function(sample){
    #### use double for loop (31 models)
    #### compute loglik, if in the fence, calculate MSPE
    #### store MSPE in the temp_full matrix
    #### find min, update countmatrix.
    
    newdata = cbind(Xmatrix, sample)
    colnames(newdata) = varnames
    #######Change to full model based on each boot sample.
    full = - logLik(lmer(y ~ x1 +x2 + x3 + x4 + x5 + 
                           (1 | county), data = newdata, REML = FALSE))[1]
    
    temp_full = matrix(rep(0, n_type*10),nrow = n_type)
    for(i_1 in 1:n_type){ 
      combin = combn(5,i_1)
      len = dim(combin)[2]
      for(j in 1:len){
      formular = as.formula(paste("y ~ ",paste(varnames[combin[, j]], collapse = '+'),
                                    '+ (1 | county)' ))
        m = lmer(formular, data = newdata, REML=FALSE)
      temp1 = - logLik(m)[1]
      if(temp1 - full <= C){ ####  Not sure why using the same full.???
      temp_full[i_1, j] = getMSPE((combin[, j]+1), m, sample)
       }                       
     }
   }
    
    index = which.min(temp_full)
    countmatrix[index] <<-  countmatrix[index] + 1
 }
 lapply(1:100,function(i)getopt_p2(data[,i]))
 countmatrix ## change to the maximum count's freq( p* )
 ## max(countmatrix/100)
}

########################   Running for each C 
### Define C's range
C = seq(0.5,10,by = 0.5)
library(parallel)
#cl = makeCluster(4, "FORK")
#myresult = clusterApply(cl, C, getmodel_p2, bootsample)





##### NOTE: first part about data preparation
####        The one in #### are the one used in the 
#####        following analysis

library('rsae')

data(landsat)

###Define data set that are used in later computation
### First, the matrix (x1,x2,x1x2,x12,x22)
dat = landsat[,3:6] 
dat$x1x2 = dat[,3] * dat[,4]
dat$x12 = dat[,3] * dat[,3]
dat$x22 = dat[,4] * dat[,4]
dat = cbind(dat,landsat$CountyName)
dat[,1:7] = scale(dat[,1:7], center = FALSE)
colnames(dat)[8] = 'county'
aa <- as.character(dat[,8])
aa[1:3] <- rep("combined_counties", 3)
bb <- as.factor(aa)
dat[ ,8] <- bb
fac.order = unique(as.numeric(dat$county)) 
# used to adjust split() in sum_j()

#####################################################
Xmatrix = dat[ ,3:8]
varnames = c("x1","x2","x3","x4","x5",'county','y')
#####################################################


#### Other numbers needed in the MSPE computation
ni <- c(3,2,3,3,3,3,4,5,5,6) 
ncounty <- length(ni)
Ni <- unique(c(sum(landsat[1:3 ,1]), landsat[4:37, 1]))


## utility functions
sum_j = function(vectors){
  ## preserve Jean's orginal functionality
  sapply(split(vectors, dat$county), sum)[fac.order]
}

sum_j_2 = function(arg1, arg2){
  ### The second part of equation(3) in the Final project
  ### spec. Used in many places
  const = (Ni - 1)/(Ni * (ni - 1))
  sum1 = sum_j(arg1) / ni
  sum2 = sum_j(arg2) / ni
  temp1 = rep(sum1, times = ni)
  temp2 = rep(sum2, times = ni) 
 const * sum_j((arg1 - temp1) * (arg2 - temp2)) 
 #update  sum_j((arg1 - temp1) * (arg2 - temp2))
}


#### Now define the second matrix with
####small (yi._corn, yi._soybean, x1i.,x2i., x1x2i., x12i., x22.)
#############################################################
x_small = cbind(rep(1,10), sapply(3:7, 
                        function(i){sum_j(dat[[i]])/ni}))
#############################################################

#### The third matrix with big X, 
#### (X1i, X2i, X1X2i, X12i, X22i)
X1_bar <- (545*295.29 + 566*300.4 + 394*289.6) / (545+566+394)
X2_bar <- (545*189.7 + 566*196.65 + 394*205.28) / (545+566+394)

X1i_bar <- as.numeric(scale(unique(c(X1_bar, landsat$MeanPixelsCorn[4:37])), center=FALSE))
X2i_bar <- as.numeric(scale(unique(c(X2_bar, landsat$MeanPixelsSoybeans[4:37])), center=FALSE))
X1X2i_bar = x_small[, 4] - sum_j_2(dat[[3]], dat[[4]])
X12i_bar = x_small[, 5] - sum_j_2(dat[[3]], dat[[3]])
X22i_bar = x_small[, 6] - sum_j_2(dat[[4]], dat[[4]])

########################################################################
X_BIG = cbind(rep(1,10),X1i_bar, X2i_bar, X1X2i_bar, X12i_bar, X22i_bar)

########################################################################