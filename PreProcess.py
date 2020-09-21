# Pre Processing tweet Data
import re
import nltk
nltk.download('stopwords')
nltk.download('punkt')
from nltk.tokenize import word_tokenize
from string import punctuation
from nltk.corpus import stopwords
import twitter





# initializing api instance
twitter_api = twitter.Api(consumer_key='pUcQsoBOJUcOeSG1fCm30g1oS',
                          consumer_secret ='lLPET11nvP0HCUur5ww3c30SSZ75l5y6WpV4nrc3kxPHF6ShUK',
                          access_token_key='1303791902358036481-XvuYTabFL7qTCfrnNkHNRdH4y81PFP',
                          access_token_secret = 'DXf4D2cWs7jzt4wcupilHdL1jE6Nr9jizMZURAqnf0rcT')

# Verifying Authentication
print(twitter_api.VerifyCredentials())

# Building test set
def buildTestSet(keyword):
    try:
        tweets_fetched = twitter_api.GetSearch(keyword,  count = 100)
        print("Fetched" + str(len(tweets_fetched)) + "tweets for the term" + keyword)

        return [{"text":status.text,"label":None} for status in tweets_fetched] #This is a JSON object
    except:
        print("Something went wrong")
        return None

testDataSet = buildTestSet('cuties')
print(testDataSet)

# Importing trainingDataSet and converting into desired format

def buildTrainingSet(tweet_file):
    import csv

    trainingDataSet = []

    with open(tweet_file,'r',encoding='latin-1') as csvfile:
        lineReader = csv.reader(csvfile, delimiter=',', quotechar="\"")
        for row in lineReader:
            trainingDataSet.append({'text':row[1],'label':row[2]})

    return trainingDataSet

tweetDataFile = "/Users/cyrusmatheson/Documents/Python FIles/tweetDataFileComp.csv"
trainingDataSet = buildTrainingSet(tweetDataFile)
# Note that stopwords are the english words which dont add meaning to a sentence, they can be ignored
# without sacrificing the meaning of the sentence, the he have, are already included in the nltk corpus

class PreProcessTweets:
    def __init__(self):
        self._stopwords = set(stopwords.words('english') + list(punctuation) + ['AT_USER','URL'])
        # This creates a set of stopwords that we can remove without losing tweet meaning

    def processTweets(self,list_of_tweets):
        processedTweets=[]
        for tweet in list_of_tweets:
            processedTweets.append((self._processTweet(tweet["text"]),tweet["label"]))
        return processedTweets

    def _processTweet(self,tweet):
        tweet = tweet.lower() # convert to lower case
        tweet = re.sub('((www\.[^\s]+)|(https?://[^\s]+))', 'URL', tweet)  # remove URLs
        tweet = re.sub('@[^\s]+', 'AT_USER', tweet)  # remove usernames
        tweet = re.sub(r'#([^\s]+)', r'\1', tweet)  # remove the # in #hashtag
        tweet = word_tokenize(tweet)  # remove repeated characters (helloooooooo into hello)
        return [word for word in tweet if word not in self._stopwords]

# Here we create a class which constructs an object with two methods, one which stores processed tweets and one which processes them
# it also defines an attribute which is the set of stopwords


# Utilizing the preProcessing Class

tweetProcessor = PreProcessTweets()
preprocessedTrainingSet = tweetProcessor.processTweets(trainingDataSet)
preprocessedTestSet = tweetProcessor.processTweets(testDataSet)


#for tweet in preprocessedTestSet:
 #   print(tweet[0])

# Building our vocabulary

def buildVocabulary(preprocessedTrainingSet):

    all_words = []

    for(words,sentiment) in preprocessedTrainingSet:
        all_words.extend(words)
    # This loops through all sentiment classes and takes all of the words in each of them
    # Difference bewteen extend and append if z =[1,2,3] x=[4,5] then z.append(x) = [1,2,3,[4,5]]
    # z.extend(x) = [1,2,3,4,5]

    wordlist = nltk.FreqDist(all_words)
    # This determines word frequency and breaks the list of all words into a list of distinct words
    word_features = wordlist.keys()
    # This matches each word with its key (frequency)
    return word_features

# Matching tweets against vocabulary

def extract_features(tweet):
    tweet_words = set(tweet)
    features ={}
    for word in word_features:
        features['contains(%s)' % word] = (word in tweet_words)
    return features

# Building the feature vector
word_features = buildVocabulary(preprocessedTrainingSet)
trainingFeatures = nltk.classify.apply_features(extract_features, preprocessedTrainingSet)
# This breaks each tweet into a vector, comprised of [0,1,0,0....,1,0,1,1,0] where the length of the vector
# is the length of our distinct vocabulary, and 1 indicates a word being present in a tweet and 0 not


#Training the classifier
NBayesClassifier = nltk.NaiveBayesClassifier.train(trainingFeatures)

#Testing our model

NBResultLabels = [NBayesClassifier.classify(extract_features(tweet[0])) for tweet in preprocessedTestSet]
print(NBResultLabels)

# get the majority vote
if NBResultLabels.count('positive') > NBResultLabels.count('negative'):
    print("Overall Positive Sentiment")
    print("Positive Sentiment Percentage = " + str(100*NBResultLabels.count('positive')/len(NBResultLabels)) + "%")
else:
    print("Overall Negative Sentiment")
    print("Negative Sentiment Percentage = " + str(100*NBResultLabels.count('negative')/len(NBResultLabels)) + "%")
# Note that this 'output' provides the overall sentiment of the 100 tweets, not the indivudal sentiment (that is listed in NBResults)










