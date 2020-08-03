# This program scrapes Amazon pages for product information

# Importing webscraping and other required modules
import re
import selenium
import bs4
import pandas as pd
import numpy as np
import re

print('bs4: {}'.format(bs4.__version__))

from selenium import webdriver
from bs4 import BeautifulSoup
from pandas import read_csv
from time import sleep
from random import randint

# Activating chromedriver and pulling web page
chromedriver = "/Users/cyrusmatheson/Downloads/chromedriver"
driver = webdriver.Chrome(chromedriver)

# Initializing arrays and defining the number of pages scraped
pages = np.arange(1, 25, 1)

stars = []
prices = []
votes = []
names = []

# Scraping desired number of pages

for k in pages:
    sleep(randint(1, 6))
    driver.get("https://www.amazon.com/s?i=electronics-intl-ship&bbn=16225009011&rh=n%3A16225009011%2Cn%3A172541&dc&page=" + str(k) + "&fst=as%3Aoff&qid=1596245898&rnid=16225009011&ref=sr_pg_" + str(k) + "")
    page = driver.page_source
    soup = BeautifulSoup(page, 'html.parser')

    # Scraping desired data
    for x in soup.findAll('div', href=False, attrs={'class': 'sg-col-4-of-12 sg-col-8-of-16 sg-col-16-of-24 sg-col-12-of-20 sg-col-24-of-32 sg-col sg-col-28-of-36 sg-col-20-of-28'}):
        try:
            name = x.find('span', attrs={'class': "a-size-medium a-color-base a-text-normal"})
            price = x.find('span', attrs={'class': "a-offscreen"})
            vote = x.find('span', attrs={'class': "a-size-base"})
            star = x.find('span', attrs={'class': "a-icon-alt"})
            prices.append(price.text)
            names.append(name.text)
            stars.append(star.text)
            votes.append(vote.text)
        except:
            pass


df = pd.DataFrame({"Product Name":names,"Price":prices,"Votes":votes,"Stars":stars})
df.to_csv('products.csv',index=False,encoding ='utf-8')
headers = ['Product','Price','Ratings','Stars']
dataset = pd.read_csv('products.csv',engine = 'python')


starr = []
votess = []
pricess =[]


# Extracting relevant values from strings and converting to floats
for i in range(len(dataset)):
    temp1 = re.findall(r'\d+\.\d+', dataset.iloc[i,3])
    fixed = dataset.iloc[i, 2].replace(',', '')
    temp2 = re.findall(r'\d+',fixed)
    temp3 = re.findall(r'\d+\.\d+', dataset.iloc[i,1])
    res = float(temp1[0])
    rej = float(temp2[0])
    rek = float(temp3[0])
    starr.append(res)
    votess.append(rej)
    pricess.append(rek)

# Recreating csv with relevant data and desired values

nf = pd.DataFrame({"Product Name":names,"Price":pricess,"Votes":votess,"Stars":starr})
nf.to_csv('information.csv',index=False,encoding ='utf-8')
datafile = pd.read_csv('information.csv',engine = 'python')
