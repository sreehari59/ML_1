import numpy as np
import pandas as pd

# This will read the excel file
basedata1=pd.read_excel("Test.xlsx")

# This will print the topmost 5 values
print(basedata1.head())

# This will print the type of basedata1
print(type(basedata1))
print("\n")

# This return a Numpy representation of the given DataFrame
basedata=basedata1.values
print(basedata)
print(type(basedata))
