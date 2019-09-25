#!/usr/bin/python
from tkinter import *
from datetime import datetime
import calendar
import TrainandPredictData as tpd

mwin=Tk()
vexp=''
# Function for sale prediction
def getSalesPrediction():
    print (t1.get())
    saledate = datetime.strptime(t1.get(), '%d/%m/%Y')
    print (saledate)
    tpd.PredictSales(saledate)
    day = calendar.day_name[saledate.weekday()]
    
#function for training the model
def traintheModel():
    print("Train Model Button Click")
    tpd.trainModel()
    
#function that close the tkinter window
def closewindow():
    print("Going to Close the window")
    exit()

mwin.title('Sales Prediction')
t1=StringVar()
l1=Label(mwin,text="Date for which Sales is required-(dd/mm/yyy format) ")
e1=Entry(mwin,textvariable=t1)

#button for sale button
bpredict=Button(mwin,text='Get Sales',command=getSalesPrediction)
#button for training the model 
btrain=Button(mwin,text='Train Model',command=traintheModel)
#button to close the window
bexit = Button(mwin,text='Close',command=closewindow)

btrain.grid(row=0, column=6, columnspan=2)
l1.grid(row=1, column=0, columnspan=4)
e1.grid(row=1,column=5, columnspan=2)
bpredict.grid(row=2,column=2, columnspan=2)
bexit.grid(row=2,column=5, columnspan=2)



#it is put inside a continous loop
mwin.mainloop()
