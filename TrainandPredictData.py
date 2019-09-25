#!/usr/bin/env python

import RFTrainandSaveModel as tsm
import RFPredictSale as ps
import pandas as pd
from pandas import DataFrame as DF
import numpy as np
import datetime as dt
import calendar

def trainModel():
    tsm.trainandsavemodel()

def PredictSales(pdate = dt.date.today()):
    # get all salesmen details in the system
    #tsm.trainandsavemodel()
    
    data = pd.read_excel("Salesmandata.xlsx")
    productdata = pd.read_excel("Productdata.xlsx")
    productdata = productdata.values

    print("Weekday :",(calendar.day_name[pdate.weekday()]))
    # getting the day from the date 
    day = calendar.day_name[pdate.weekday()]
    year = pdate.year
    month = pdate.month
    weekofYear = pdate.isocalendar()[1]
    print(weekofYear)
 
    # selecting the salesmen details for the day
    predicteddetailsDF = DF()
    salesmandata=data[data['Day'] == day]
    print(data['Day'])
    print(salesmandata)
    #
    salesmandata = salesmandata.values
    fileName = 'PredictedSales_'  + '.xlsx'
    print (fileName)
    wo = pd.ExcelWriter(fileName)
    for salesman in salesmandata:
        # Prints the salesman data
        print("Salesman:"+str(salesman))
        predicteddetailsDF = DF()
        
        predicteddict =  dict({'Salesman':[],'Product':[],'Sale':[] })
        for product in productdata:
            predicteddict['Salesman'].append(salesman[2])
            predicteddict['Product'].append(product[1])
            # prints the product details
            print(product)
            
            predictsalelist = [product[0], year, month, weekofYear, salesman[1],product[2],salesman[0], salesman[3]]
            # predictsale gets the value present inside predictsalelist
            predictsale = np.array([predictsalelist])
            # predictedValue gets the value returned by the function predictsale
            predictedValue = ps.predictsale(predictsale)
            # Prints the value returned by the function predictsale
            print("PredictedValue[0]",predictedValue[0])
            predicteddict['Sale'].append(predictedValue[0])
            
        predicteddetailsDF = pd.DataFrame(predicteddict)
        print ("==================================")
        predicteddetailsDF.to_excel(wo,salesman[2])

    print(predicteddetailsDF)
    wo.save()


