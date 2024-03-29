library(naivebayes)
library(caret)

# Loading of Data
train = read.csv("C:/Users/neilc/dev/proj/nlp-thesis-xlnet-tagalog/data/hatespeech/train.csv", stringsAsFactors = FALSE)
test = read.csv("C:/Users/neilc/dev/proj/nlp-thesis-xlnet-tagalog/data/hatespeech/valid.csv", stringsAsFactors = FALSE)
# Looking through Data

names(train) = c("Text", "Label")
train$Label = as.factor(train$Label)

names(test) = c("Text", "Label")
test$Label = as.factor(test$Label)

prop.table(table(train$Label))
prop.table(table(test$Label))

train$Label
test$Label

library(quanteda)
# Train
# Text-Preprocessing

tagalogstopwords = readLines("C:/Users/neilc/dev/proj/nlp-thesis-xlnet-tagalog/data/stopwords.txt",
                             encoding = "UTF-8")
tagalogstopwords

train.tokens = tokens(train$Text, what = "word", remove_punct = TRUE,
                      remove_numbers = TRUE, remove_url = TRUE,
                      remove_symbols = TRUE, remove_separators = TRUE)
train.tokens = tokens_select(train.tokens, stopwords(), selection = "remove")
train.tokens = tokens_select(train.tokens, tagalogstopwords, selection ="remove")
train.tokens = tokens_wordstem(train.tokens, language = "english")

# Bag-of-words Model
train.tokens.dfm = dfm(train.tokens, tolower = TRUE)
#train.tokens.dfm = dfm_trim(train.tokens.dfm,min_termfreq = 5)
# Cloud of Words


# Matrix
train.tokens.matrix = as.matrix(train.tokens.dfm)
View(train.tokens.matrix[1:20, 1:100])
dim(train.tokens.matrix)

# TF-IDF

term.frequency = function(row) {
  row / sum(row)
}

inverse.doc.freq = function(col) {
  corpus.size = length(col)
  doc.count = length(which(col > 0))

  log10(corpus.size / doc.count)
}

tf.idf = function(tf, idf) {
  tf * idf
}


# Normalize using TF
train.tokens.df = apply(train.tokens.matrix, 1, term.frequency)
dim(train.tokens.df)


# calculate IDF Vector
train.tokens.idf = apply(train.tokens.matrix, 2, inverse.doc.freq)
str(train.tokens.idf)

# TF-IDF
train.tokens.tfidf = apply(train.tokens.df, 2, tf.idf, idf = train.tokens.idf)
dim(train.tokens.tfidf)

# Transpose back
train.tokens.tfidf = t(train.tokens.tfidf)
dim(train.tokens.tfidf)

# Incomplete cases
incomplete.cases = which(!complete.cases(train.tokens.tfidf))
train$Text[incomplete.cases]

train.tokens.tfidf[incomplete.cases,] = rep(0.0, ncol(train.tokens.tfidf))
dim(train.tokens.tfidf)
sum(which(!complete.cases(train.tokens.tfidf)))

# Clean column names
train.tokens.tfidf.df = cbind(Label = train$Label, as.data.frame(train.tokens.tfidf))
names(train.tokens.tfidf.df) = make.names(names(train.tokens.tfidf.df))


# Matrix
train.tokens.matrix = as.matrix(train.tokens.tfidf)
dim(train.tokens.matrix)

### Train the Multinomial Naive Bayes
# set.seed(72323)
mnb <- multinomial_naive_bayes(x = train.tokens.matrix, y = train$Label, laplace = 1)
summary(mnb)

p1 = predict(mnb, train.tokens.matrix)

confusionMatrix(train$Label, p1)

# Test

# Text-Preprocessing
test.tokens = tokens(test$Text, what = "word", remove_punct = TRUE,
                      remove_numbers = TRUE, remove_url = TRUE,
                      remove_symbols = TRUE, remove_separators = TRUE)
test.tokens = tokens_select(test.tokens, stopwords(), selection = "remove")
test.tokens = tokens_select(test.tokens, tagalogstopwords, selection ="remove")
test.tokens = tokens_wordstem(test.tokens, language = "english")


# Bag-of-words Model
test.tokens.dfm = dfm(test.tokens, tolower = TRUE)

# Matrix
test.tokens.dfm = dfm_match(test.tokens.dfm, featnames(train.tokens.dfm))
test.tokens.matrix = as.matrix(test.tokens.dfm)

# Normalize using TF
test.tokens.df = apply(test.tokens.matrix, 1, term.frequency)


# TF-IDF
test.tokens.tfidf = apply(test.tokens.df, 2, tf.idf, idf = train.tokens.idf)

# Transpose back
test.tokens.tfidf = t(test.tokens.tfidf)

# Incomplete cases
incomplete.cases = which(!complete.cases(test.tokens.tfidf))
test$Text[incomplete.cases]

test.tokens.tfidf[incomplete.cases,] = rep(0.0, ncol(test.tokens.tfidf))
sum(which(!complete.cases(test.tokens.tfidf)))

# Clean column names
test.tokens.tfidf.df = cbind(Label = test$Label, as.data.frame(test.tokens.tfidf))
names(test.tokens.tfidf.df) = make.names(names(test.tokens.tfidf.df))


# Matrix
test.tokens.matrix = as.matrix(test.tokens.tfidf)
dim(test.tokens.matrix)

#prediction

p2 = predict(mnb, test.tokens.matrix)

confusionMatrix(test$Label, p2)
confusionMatrix(train$Label, p1)
