#This is the scripts to analyse the stack-overflow question in Kaggle.
#It consist of 
#1,converting the BodyMarkdown to html then parse out the text content
#2,perform basic NLP analysis using tm package in R
#3, statistical/ machine learning methods to predict closed questions
#Note, only the training-sample.csv is used in here.

library(markdown)
library(XML)
library(tm)


#from markdown package, fragment.only to exclude the CSS etc. to save memory space.

train = read.csv('train-sample.csv',colClasses=c(rep('NULL',7),'character',rep('NULL',7)))
train = unlist(train)
tohtml = sapply(train,function(x)markdownToHTML(text=x,fragment.only=TRUE))
library(parallel) # try to parallel this converting process
 cl = makeCluster(4,'FORK') #but it didn't take up much of the time
 htmllist = clusterSplit(cl,tohtml)

getvec = function(htmls){
  sapply(htmls,function(html){
    parsed = htmlParse(html)# get all the paragraphs. Paste them together
    plist = getNodeSet(parsed,'//p')
    texts = sapply(plist,xmlValue)
    paste(texts,collapse='')
  })
}

result.list = clusterApply(cl, htmllist, getvec)
results = unlist(result.list) # 14000+ entries of strings
status = read.csv('train-sample.csv',colClasses=c(rep('NULL',14), 'factor'))
status = unlist(status)
stopCluster(cl)
open = results[status=='open'] # simplify into a two class classification problem
closed = results[status != 'open']

####tm analysis

cb = c(opencorpus, closedcorpus)#create corpus from all the entries
cb = tm_map(cb, tolower)#preprocessing, Somehow the stemming doesn't work
cb = tm_map(cb, removeWords, stopwords('english'))
cb = tm_map(cb, removePunctuation)
cb = tm_map(cb, stripWhitespace)
dtm = DocumentTermMatrix(cb,control=list(wordLengths=c(3,20), #Tfidf
              removeNumbers=TRUE,weighting=weightTfIdf,minDocFreq=30))

dtm2 = DocumentTermMatrix(cb,control=list(wordLengths=c(3,20), #just term freq
                                         removeNumbers=TRUE,weighting=weightTf,minDocFreq=30))

dtm3 = removeSparseTerms(dtm2,0.99)  # cut down the sparsity, just keep some commom words


save(dtm2,dtm,dtm3,file='sparsetable.rda')

fac = as.factor(rep(c(1,0), each=70136))
#Fit a regular random forest using randomForest packages in R
#Takes more than 10 hours to finish a prediction with 500+ features.

