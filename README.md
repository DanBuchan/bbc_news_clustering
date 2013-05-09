File Provided
-------------

* process_corpus.rb - a ruby script that reads in the article data from data.json
				    and processes if for analysis in R
* cluster_corpus.R  - an R script of commands that clusters the vectors that
					represent the articles
* vectors.csv       - feature vectors of data that describe each article for 
					clustering in R
* dendrogram_no_tuples.png - Dendrogram of hierarchical clustering of the documents
					   where there are no 2-tuples in the feature vector
* dendrogram.png - Final Dendrogram of hierarchical clustering of the documents
					   where (single words and 2-tuples in the feature vector)

Installation
------------
Code requires the json ruby gem

`> gem install json`

Usage
-----
`> process_corpus data.json`

This will output the vectors.csv file

Then start R in the directory containing the vectors.csv file and execute
the commands one by one. Alternatively load the .R file, the downside of that is
that you won't see the output of the kmeans clustering. Comments in the R file
show the clustering I generated for different values of K, these may differ for
you as kmeans clustering is not guaranteed to converge on the same solution from
different start points. The numbers given indicate the cluster number and the 
sequential order is the same as the given in the initial json data.

Results
-------
Comparing the kmeans clustering demonstrates that the clusters are somewhat
degenerate and it doesn't do a great job of clustering the vectors of data. The 
first 5 articles are always robustly clustered irrespective of the value of K 
chosen and this clustering seems appropriate given topics and body text of the 
articles.  The rest of the articles do not fare so well, for instance the health
service and pyramids articles (9 and 10) always cluster together and are
occasionally collapsed with articles 1 & 4 (where K<=7). This suggests that
kmeans if probably not the best clustering for this data

Moving on we generated a hierarchical clustering of the document vectors. This
clustering is somewhat more canonical than kmeans for document clustering. The
resulting dendrogram (dendrogram.png) displays a much significantly better 
clustering over the kmeans. articles 1,4 and 5 are well clustered. Articles 10
and 15 are arguably well clustered both being about politics although the 
subject matter is not so similar (health and internet reform/legislation).
Broadly the parent cluster for the 1-4-5 cluster is somewhat more varied than
you may wish. The 2-3 cluster is a good clustering but somewhat like the 1-4-5
cluster the parent cluster contains a somewhat disparate range of topics. 
Although articles 7 and 8, both about football, are present together in this
cluster.

Overall the hierarchical clustering does appear to perform better than kmeans
on this dataset but neither could be said to have very adequate performance.

Algorithm
---------
The algorithm implemented largely replicates a common text mining approach.
A bag of all the words and word pairs (2-tuples) found in the corpus of 
documents is generated (10,869 features after data processing). Then for each 
document a vector representing the bag of words is generated for each document. 
Over each document for each feature (word or tuple) the TF-IDF (term 
frequency-inverse document frequency) is calculated. 

TF-IDF is just the simple product of the number of times a word appears in a
text (text frequency) multiplied by the log of the inverse of the number of times
that word appears in the corpus of documents (IDF). This has the useful feature
of heavily down weighting common terms and up-weighting the significance of rare 
terms.

Lastly with the vectors for each document available these are processed by 
standard clustering algorithms in R

Implementation
--------------
This is implemented as a Ruby script which outputs data for R analysis.
I had initially planned to use the ai4r ruby gem for the clustering. In part
the find out more about this module and also to make the data processing a 
fully contained ruby programme. To this end a calculateDistanceMatrix method
is included in the code. This builds a distance matrix where the distance is
the cosine similarity score between the feature vectors. This is typically
a more meaningful distance measure of a high dimensional vector than the 
euclidean distance. The kmeans implementation in ai4r appears to only 
take 2D vectors of points and won't take the full feature vector or a distance
matrix and the other clustering methods are essentially undocumented so I 
abandoned a ai4r. I've left the distance calculation code in for interest 
sake. The cosine similarity code (not mine) is fairly elegant.

The script is built around a PrepJson class that's made up of a handful of 
methods. Walking through the  in turn;

* initialize()

A simple constructor method that initialises a few variables and reads in the
data

* stripChars()

This method walks through each article and title and processes the text of the 
titles and article bodies. Punctuation and numbers are removed. Possessive s ('s)
is also removed from words. Also simple plurals, s endings, have the s removed
This translates Obamas to Obama at the cost of rendering words like 'is', 'was' 
and 'has' as garbage. As words such as 'is', 'was' and 'has' likely have little 
information content for the clustering this seems like an acceptable trade off 
for this example code

* calculateIDF()

This method walks through the corpus and generates the bag of words that will
make up our feature vector, it calculates the IDF value for each word as it
goes and stores everything in a hash table. Importantly the title and article
text are collapsed together and not treated as separate features An initial 
version only generated words of word length 1. dendrogram_no_tuples.png shows 
a results of clustering with such a vector, this clustering did not seem very 
informative so the current implementation of method Additionally generates 
every pair of words in the corpus.

* buildVectors()

This methods walks through each articles and for every word in the bag of words
it calculates the the TD-IDF score for that word in that document. The results
are stored as a 2D array

* Data Output

The 2D array of TD-IDF scores for each article is printed to the vectors.csv
file the order of the vectors is as per the input .json file

* cluster_corpus.R

A short R script that calculate the kmeans clustering of the article vectors
and the hierarchical clustering.

Improvements
------------
The final hierarchical clustering can't really be said to be great. This is
most likely to be a consequence of the very limited size of the article corpus.
And obvious improvement would be cluster a much, much large corpus of documents,
ideally in the 10,000+ range.

In the test preprocessing ,method stripChars(), better handling of the plurals
with an appropriate look up dictionary would be better.

Other things to try would be different tuple sizes for the word bag. The 
addition of triads (3-tuples) to the word bag alongside the 1 and 2-tuples may
help. Additionally it may be worth investigating different combinations perhaps
2-tuples on their own may out perform 1-tuples with 2-tuples as the word bag
will be made up of more significant small phrases.

Finally the clustering algorithm is worth investigating, an alternative may be
Markov Chain Clustering (MCL). This is fast and robust for very large datasets 
especially important if the corpus size is increased by a number of orders of
magnitude. This would allow a return to calculating the cosine similarity 
distance matrix. Additionally, when working with a much larger dataset, the 
problem could be flipped as a supervised learning problem. You might start by
clustering what you have then manually annotating the clusters (you may need to 
collapse some) then a further classifier can be trained so future documents can be
efficiently added to the existing clusters. While this is a common approach to 
large datasets in biology although that manual step requires a great deal of
time and man power so this may not be appropriate for a variety of projects.
supervised learning problem. 

One simple change would be to reduce each article only to it's most significant 
sentences. Then removing the lowest significance sentences from each article then
clustering only on the remaining significant sentences. Sentence significance could
be calculated as some linear sum of all TF-IDF values calculated within that sentence
(probably divided through by either the number of words or number of tuples in the
sentence).