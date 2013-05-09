#
# Short set of r commands to cluster the data output by process_corpus.rb
#
# My output for the kmeans clustering is listed as a comment as the clustering 
# is somewhat degenerate for independant runs
#


corpus <- read.csv(file="vectors.csv",head=TRUE,sep=",")
#head(distances)
cl <- kmeans(corpus, 7)
cl$cluster
# [1] 5 4 4 5 5 3 7 4 5 5 2 1 6 5 5 5 7 5
cl <- kmeans(corpus, 9)
cl$cluster
# [1] 5 1 1 5 5 3 9 4 9 9 8 2 7 9 9 5 6 5
cl <- kmeans(corpus, 10)
cl$cluster
# [1]  6 10 10  6  6  2  5  8  9  9  4  7  1  3  9  6  8  6


distances<-dist(corpus)
hc<-hclust(distances)
png("dendrogram.png")
plot(hc)
dev.off()