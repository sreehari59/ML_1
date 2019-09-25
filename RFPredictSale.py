from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pickle

def predictsale(predictdata):
        filename = 'finalised_trained_model.sav'
        # load trained model
        trained_model = pickle.load(open(filename,'rb'))
        p = trained_model.predict(predictdata)
        print (p)
        
        return p




