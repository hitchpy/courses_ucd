#minimum realization of the adaboost algorithm, 
# with a simple classification tree.
#sample training and testing dataset
 p <- 2
 N.train <- 2000
 X.train <- matrix(rnorm(p*N.train),nrow=N.train)
 y.train <- ifelse(apply(X.train^2,1,sum)>qchisq(0.5,p),-1,1)
 train <- data.frame(y=y.train,X=X.train)
 N.test <- 10000 # you may want to start with something smaller
 X.test <- matrix(rnorm(p*N.test),nrow=N.test)
 y.test <- ifelse(apply(X.test^2,1,sum)>qchisq(0.5,p),-1,1)
 test <- data.frame(y=y.test,X=X.test)

myboost = function(data, iter = 100){
#the actual boosting procedure, using default trees from rpart
#return the classifiers and alphas in a list
    require(rpart)
	n = nrow(data)
	w = rep(1/n, n)
	alpha = rep(0, iter)
	modelset = list()
	
	for(i in 1:iter) {
	    models = rpart(y ~., data , weights = w ,method = 'class')
		pred = predict(models, type = 'class')
		misclass = as.numeric(pred != data$y)
		err = t(w) %*% misclass
		#if(err > 0.5) take opposite, simplified here.
		
		myalpha = log((1-err)/err)
		modelset[[i]] = models
		w = w * exp(myalpha * misclass)
		w = w / sum(w)
		alpha[i] = myalpha
	
	}
	return(list(classifiers = modelset, alpha = alpha))

}

fit.ada = function(data, test = NULL, levels = c(-1, 1), iter = 100) {
    #levels give the lables for the two classes
	#fitting the final prediction using myboost function
	runada = myboost(data, iter)
	classifiers = runada$classifiers
	alpha = runada$alpha
	if(is.null(test)) test = data[, -1]
	boomatrix = matrix(rep(0, nrow(test) * iter), ncol = iter)
	
	for(i in 1:iter) {
	    pred = predict(classifiers[[i]], test, type = 'class')
		boomatrix[, i] = alpha[i] * ifelse(pred == levels[1], -1, 1)

	}
   boostresult = ifelse(rowSums(boomatrix) < 0 ,levels[1],levels[2])
}