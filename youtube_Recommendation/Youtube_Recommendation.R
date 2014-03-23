### unset JAVA_HOME in shell to prevent some JNI error


######## Importing data and transform to data.frame
######## Data is a small json file of 474 Youtube
######## video info that need several recommended video

library('RJSONIO')

myfile = fromJSON("CodeAssignmentDataSet.json",encoding="Latin1")
##Encoding,otherwise will encounter difficulty in the following annotation 

### only have 3 keys, so I repeat the process manually
description = sapply(myfile, function(file){file$description})
titles = sapply(myfile, function(file){file$title})
## different video have diff num of categories labels, store it in list
categories = lapply(myfile, function(file){file$categories})

video = data.frame(description, titles, I(categories))
video[[1]] = as.character(video[[1]])
video[[2]] = as.character(video[[2]])

#######################################
####### NLP part, take out the nouns 
#######################################

options( java.parameters = "-Xmx4g" )
library(rJava)
library(openNLP)
library(NLP)
## installed openNLPmodels.en 
## install.packages("openNLPmodels.en", repos = "http://datacube.wu.ac.at/", type = 'source')

### Several functions to extract persons , shows, dates etc
### as keys for further info retrieval.
getNames = function(sv){
    ###work for a string vector	
	### Most will be NULL, quality highly depends on the 
	### input corpus.
	sta = Maxent_Sent_Token_Annotator()
	wta = Maxent_Word_Token_Annotator()
	ea = Maxent_Entity_Annotator()
	sapply(sv, function(string){
	    if(string == "")return(NULL)
	    s = as.String(string)
		a2 = annotate(s, list(sta, wta))
		nam = ea(s,a2)
		if(length(nam)==0)return(NULL)
		else return(unclass(s[ea(s,a2)]))
	})
}

getShows = function(){}

actors = unique(c(getNames(video[[1]][389]), getNames(video[[2]][389]), recursive=TRUE))
#shows =  unique(c(getShows(video[[1]][i]), getShows(video[[2]][i]), recursive=TRUE))

#keywords = c(actors,shows)

########################################
###### Retrieve more information from wiki
########################################

### Assume for each video, we will have at least
### two key words that can be used to get more information.


###Case example use the 389 entry, with celebrities 
### "Peter Dinklage" "Peter Helliar"  "Megan Gale"
### Starring in movie  I Love You Too 

getUrl = function(words){# a char vector
    ##only works if this page exist, and
	## has no ambiguity with other things
	## Better to get infomation from some 
	## structured data resources
    pre = 'https://en.wikipedia.org/wiki/'
	words = strsplit(words, " ")
	words = sapply(words,paste,collapse='_')
	urls = paste(pre,words,sep="")
    urls
}


getContent = function(words){
    require(XML)
	require(RCurl)
    con = getCurlHandle()
    ### run with actors( three names from row 389)
    myurl = getUrl(words)
    txt = sapply(myurl, function(u) getURLContent(u, curl = con))
	contents = sapply(1:length(txt),function(i){
	    doc = htmlParse(txt[[i]])
		nodes = getNodeSet(doc, "//p")##lacks some important info in 
		#other places like in a table.
		texts = sapply(nodes,xmlValue)
        paste(texts,collapse='')
	})
return(contents)
}

recommend = function(contents){
    ## With the assumption of more then two key words
	## with build a length(content) * words DocTermMatrix
	## using tm package
	require(tm)
	mycorpus = Corpus(VectorSource(contents,encoding="UTF-8"))
    mycorpus = tm_map(mycorpus, removePunctuation)
    mycorpus = tm_map(mycorpus, stripWhitespace)
	dtm = DocumentTermMatrix(mycorpus,control=list(wordLengths=c(1,20), #Tfidf
              removeNumbers=FALSE,weighting=weightTfIdf))
}


mainfunc = function(index){
    #Main function to run against
	#all the entries in the JSON files
	#output will be the key words that should 
	# be included in the recommended video
	entry = video[index,]
	actors = unique(c(getNames(entry$description), getNames(entry$titles), recursive=TRUE))
	shows = unique(c(getNames(entry$description), getNames(entry$titles), recursive=TRUE))
	content = getContent(c(actors,shows))
	output = recommend(content)

return(output)
}