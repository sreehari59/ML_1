from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pickle



def trainandsavemodel():

        print("going to Train Model")
        # reading data from Excel
        basedata1 = pd.read_excel("Test.xlsx")
        print("Excel data:",basedata1)
        print("\n")
        basedata =basedata1.as_matrix()
        print("Matrix data:",basedata)

        #defining Label encoder
        le=preprocessing.LabelEncoder()

        # label encoding for the Day column
        le.fit(basedata[:,5])
        basedata[:,5]=le.transform(basedata[:,5])
        # [ProductId, Year, Month, Day, Week, Salesman, RetailPrice, Route, DepotId]
        X=basedata[:,[1,3,4,5,6,7,13,14]]
        y=basedata[:,-1]

        # splitting the data into Train and Test at the ratio of 80:20
        X_train, X_test, y_train, y_test = train_test_split(X,y, test_size=0.2)

        # fit the model with n_estimator as 22(identified using GridSearchCV)
        model = RandomForestRegressor(n_estimators=22)
        model.fit(X_train,y_train)

        # save the model for future prediction
        filename = 'finalised_trained_model.sav'
        pickle.dump(model, open(filename, 'wb'))

        print("saved the Trained Model")

