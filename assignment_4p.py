#Name:Sara Ragab
#Assignment 4

#Packages to be used
import os
import math
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

#setting the work directory
#============================
os.chdir("/Users/sararagab/Desktop/SH_MDP/APEC_8222_copy/Code/python_for_big_data")

# Problem 1: Filesystems (30 pts)
#=================================
# QUESTION 1a - 5 pts
# Print out a list of all the files in the class Data directory
directory = "../../Data"
file_names=os.listdir(directory)# using the os.listdir command to obtain a list of file names in data folder
print("Question 1a:\n",file_names)
#==============================================================================================================
# Question 1b - 5 pts
# Using a for loop over that list, count how many times the character string "maize" occurs in the file NAMES


# we set count= 0 and we iterate over each file in the list variable we created using a loop
# we use the if statement so that if the word 'maize' exists with the list the count variable
# would count it
count = 0
for s in file_names:
    if 'maize' in s:
        count += 1
print("Question 1b:\n",count)
#==============================================================================================================
# Question 1c - 10 pts
# Using os.path.splitext(), count how many files have the ".tif" extension

filepaths = [] # creating an empty list called filepaths
count=0 # setting the count variable to zero
for path in file_names:
    filename, file_extension = os.path.splitext(path) # using the os.path.splitext command to
                                                     #separate the file name and the file extension
    filepaths.append(file_extension)# extracting the file extension alone and adding it to the filepaths[] list
filepaths.count('.tif') # using the .count command to count the '.tif' extension in the filepaths[] list

print("Question 1c:\n",filepaths.count('.tif'))
#==============================================================================================================
# Question 1d - 10 pts
# Print out a sorted list of filename, filesize.
# Loop and add files to list.
filesize = [] # creating an empty list  to which I'll add the file size and name later
for file in file_names: # looping over the list that we created earlier with the file names
    # Use os.path.join to get full file path.
    location = os.path.join(directory, file)

    # Get the size of each file in the above list "location"
    size = os.path.getsize(location)
    filesize.append((size, file))# adding the filesize and name to the filesize
                              #list we created earlier

# Sort list of tuples by the first element, size.
filesize.sort(reverse=True) # to sort the list from largest to smallest
                            # we use the reverse=true argument

# Display filesize.
print("Question 1d:")
for x in filesize:
    print(x)
#==================================================================================================================
## Question 2: 70 pts

# Question 2a - 10 pts
#read in the Production_Crops_E_All_Data_(Normalized).csv file.
path = "../../Data/Production_Crops_E_All_Data_(Normalized).csv"

# encoding='latin' argument to tell the computer how to read the file.
df = pd.read_csv(path,encoding='latin')

# Save the column headers to a list and print it out
col=list(df.columns)

#Also print out the number of rows.
#y=df.index # we can also use the .index command to  shows thw number of rows
count_row = df.shape[0]

print("Question 2a:\n","Column headers:\n", col,":\n"
      ,"number of rows:\n", count_row)
#=========================================================================
# Question 2b - 10 pts
#  Constraining the size of the DF so that it only has Production statistics using the df.loc method
df1= df.loc[df['Element'] == 'Production']

print("Question 2b:\n Production data:\n" ,df1)

#=========================================================================
# Question 2c - 10 pts
# Use pandas unique() function to get a list of all Area names used in this table and all the Item names used.

#a list of all Area names
Area_names=df.Area.unique()
print("Question 2c:\n",Area_names)

#a list of all Item names
Item_names=df.Item.unique()
print("Question 2c:\n",Item_names)

print("Question 2c:\n","Area names:\n", Area_names,":\n"
      ,"Item names:\n", Item_names)
#=========================================================================
# Question 2d - 10 pts
# Produce a line-graph of Production from 1961 to 2019 of Maize in Canada.

#Creating the dataframe that has info about Production from 1961 to 2019 of Maize in Canada.
df2= df.loc[(df['Element'] == 'Production') & (df['Area'] == 'Canada')
            & (df['Item']=="Maize") & (df['Year']>=1961) & (df['Year']<2020)]

print("Question 2d:\n df of Production from 1961 to 2019 of Maize in Canada:\n",df2)

#Producing a line plot of the values of production of maize in Canada in the
#given time period
df2.plot(kind='line', x='Value', y='Year')
plt.show()
#=========================================================================

# Question 2e - 10 pts
#  Unstacking the data so that each Area is in a unique row and each year in a unique column

#Using the pd.pivot_table to unstack the data
# I was not sure which dataframe to pivot I decided to stick with the df2 ( i.e the production dataframe)
df3= pd.pivot_table(df1, values=['Value'],index=['Area']#we use the area as the index (i.e row headers)
                                         , columns=['Year']) #and the years as the columns headers


print("Question 2e:\n Production table unstacked", df3)

# we save the df to a csv file
df3.to_csv('question_2e.csv')

# Question 2f - 10 pts
# Create an unstacked dataframe similar to above except with ALL of the different crops (Items) included.
# If you saved previous steps' dataframes, you might already have the one you need to pivot on, otherwise recreate it.
# Print and save this to question_2f.csv

df4 = pd.pivot_table(df1, values=['Value'], index=['Area', 'Item'],columns=['Year'])
print("Question 2f:\n Production table unstacked for All Items", df4)
df4.to_csv('question_2f.csv')



# Question 2g - 10 pts

# restricting the production dataframe (df1) to Year and Value so that we have value of all items across years
df5 = df1[['Year', 'Value']]
#then we want to group and aggregate the values by the Year variable using the .grouby and sum commands
#Hence we get the total production tonnage of all crops for all countries over time
tot_prod = df5.groupby('Year')['Value'].sum()
print(print("Question 2g:\n Total Production for All Items for All counties:\n ", tot_prod))
#plot the total production tonnage
tot_prod.plot(kind='line', x='Value', y='Year')
plt.show()
plt.savefig('question_2g.png')
