# Importing required libraries
import twitter
from twitter import *
import pandas
import matplotlib
import nltk
import time
import json
import re
import csv
from pandas import read_csv
from PreProcess import*


#Twitter API Key
# pUcQsoBOJUcOeSG1fCm30g1oS

#Secret Key
# lLPET11nvP0HCUur5ww3c30SSZ75l5y6WpV4nrc3kxPHF6ShUK

#Bearer Token
# AAAAAAAAAAAAAAAAAAAAAJszHgEAAAAAMceybnbONckP%2BM6AZ6Mvo2iGfn4%3Dz1e4JKNT7fMR96suAW9TII5n5uj5lwUQU9fTUJPKQobB0upgis

#Access Token
# 1303791902358036481-XvuYTabFL7qTCfrnNkHNRdH4y81PFP

#Access Token Secret
#DXf4D2cWs7jzt4wcupilHdL1jE6Nr9jizMZURAqnf0rcT

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
        tweets_fetched = twitter_api.GetSearch(keyword, count =100)
        print("Fetched" + str(len(tweets_fetched)) + "tweets for the term" + keyword)

        return [{"text":status.text,"label":None} for status in tweets_fetched] #This is a JSON object
    except:
        print("Something went wrong")
        return None


testDataSet = buildTestSet('bitcoin')

print(testDataSet[0:4])
print(type(testDataSet))


def buildTrainingSet(corpusFile, tweetDataFile):

    import csv
    import time

    corpus = []

    with open(corpusFile, 'r') as csvfile:
        lineReader = csv.reader(csvfile, delimiter=',', quotechar="\"")
        for row in lineReader:
            corpus.append({"tweet_id": row[2], "label": row[1], "topic": row[0]})

    rate_limit = 180
    sleep_time = 900 / 180

    trainingDataSet = []

    for tweet in corpus:
        try:
            status = twitter_api.GetStatus(tweet["tweet_id"])
            print("Tweet fetched" + status.text)
            tweet["text"] = status.text
            trainingDataSet.append(tweet)
            time.sleep(sleep_time)
        except:
            continue
    # now we write them to the empty CSV file
    with open(tweetDataFile, 'w') as csvfile:
        linewriter = csv.writer(csvfile, delimiter=',', quotechar="\"")
        for tweet in trainingDataSet:
            try:
                linewriter.writerow([tweet["tweet_id"], tweet["text"], tweet["label"], tweet["topic"]])
            except Exception as e:
                print(e)
    return trainingDataSet


corpusFile = "/Users/cyrusmatheson/Documents/Python FIles/corpus.csv"
tweetDataFile = "/Users/cyrusmatheson/Documents/Python FIles/tweetDataFile.csv"

trainingData = buildTrainingSet(corpusFile, tweetDataFile)

tweetProcessor = PreProcessTweets()
preprocessedTrainingSet = tweetProcessor.processTweets(trainingData)
preprocessedTestSet = tweetProcessor.processTweets(testDataSet)




