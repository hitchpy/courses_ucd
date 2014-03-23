**Initial build of Youtube Video Recommendation System**
========================================================

Objective
---------

The idea is that based on the JSON entries for a specific video, consisting of the *title*, *description* and *categories*, we output
several key words that should appear in the recommended videos. 

Sentences Tokenization
----------------------

The tokenization is performed using openNLP package with the default models. The result for the descriptions in each entry is very poor, it fail to identify 
many person names and so entries only cut out half the name. This process is highly sensitive to the input model or user defined tokens.  
It is not impossible to improve this part's performance since this part is the most essential part of this recommendation system. Some algorithms for automatic new 
word recognition have been proposed, so one way would be to identify words specific to entertainment and inject it into tokenization process. Right now I don't think
I can finish this process.

> To get the result from openNLP entity tokenizer, library `openNLP`,`NLP`,`RJSONIO`, run the code to get *video* matrix, then run `getNames` function in the script. 

Knowledge Base Query
--------------------

My original thought is that, with several key words from the entry, I can aggregate more information for each term, then rank the term by TF-IDF to come up with 
new terms that are highly related to the key words but doesn't included in the key words. It turns out the performance with only around 2000 words extract from 
several *wikipedia* entries is far from satisfactory. There mainly are two problems:  

- The unstructured wikipedia page is hard to extract all the useful information. Things are even worse if we don't have a valid key words or there are some ambiguity with the key words.  

- The highly ranked words mostly are meaningless random words. Still, it is a problem caused by tokenization and lack of training corpus.

Deep Learning--word2vec program
-------------------------------

The main idea here is still try to come up with key words that are unexpected from the title or description. For example, a title with *France* and *Paris* can give 
you *London* with *England*. It use the distance when projected the words to a vector space to find out correlated words. R currently don't have package that can
perform this analysis, in Python, the module **gensim** support this analysis, the original C program is in <https://code.google.com/p/word2vec/>.  
My original plan is to train a specific model for each video title. But it turns out we need to build a model from enormous amount of texts, so that we can diretly
use the model to find most similar words.  
That is certainly a better strategy but has beyond my current capability to finish, so I have to stop a here.