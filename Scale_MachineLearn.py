# Importing required modules

import sys
import scipy
import numpy
import matplotlib
import pandas as pd
import sklearn

# Adding libraries

from pandas.plotting import scatter_matrix
from matplotlib import pyplot
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC


# Loading machine learning dataset

raw_data = "/Users/cyrusmatheson/Downloads/balance-scale.data"
headers = ['Side','LW','LD','RW','RD']
datafile = pd.read_csv(raw_data,engine = 'python',names = headers)

print(datafile.groupby('Side').size())


# Dividing the dataset for training vs testing
info = datafile.values
Input = info[:,1:5]
Output = info[:,0]

print(Input)
print(Output)


Input_train, Input_validation, Output_train, Output_validation = train_test_split(Input, Output, test_size= 0.3,random_state=1)


# Checking Algorithms
models = []
models.append(('CART', DecisionTreeClassifier()))
models.append(('NB', GaussianNB()))
models.append(('SVM', SVC(gamma='auto')))
models.append(('LR', LogisticRegression(solver='liblinear', multi_class='ovr')))
models.append(('LDA', LinearDiscriminantAnalysis()))
models.append(('KNN', KNeighborsClassifier()))

# evaluate each model in turn
results = []
names = []

for name, model in models:
	kfold = StratifiedKFold(n_splits=10, random_state=1, shuffle=True)
	cv_results = cross_val_score(model, Input_train, Output_train, cv=kfold, scoring='accuracy')
	results.append(cv_results)
	names.append(name)
	print('%s: %f (%f)' % (name, cv_results.mean(), cv_results.std()))

# Compare Algorithms
pyplot.boxplot(results, labels=names)
pyplot.title('Algorithm Comparison')
pyplot.show()

# Making Predictions
model = SVC(gamma='auto')
model.fit(Input_train,Output_train)
predictions = model.predict(Input_validation)

# Evaluate predictions
print(accuracy_score(Output_validation, predictions))
print(confusion_matrix(Output_validation, predictions))
print(classification_report(Output_validation, predictions))

print(predictions)