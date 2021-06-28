#Name: Sara Ragab Hussien
#Assignment(4)


rm(list = ls())

#Packages to be used 
library('data.table')
library('httr')
library('rvest')
library('gsubfn')


# setting work directory
#setwd("/Users/sararagabhussien/Dropbox/My Mac (Sara’s MacBook Air)/Desktop/APEC 8221/Assignment 4")

#Part 1
#setting the library for packages to be used 
beer.data=read_html("https://www.brewersassociation.org/statistics-and-data/state-craft-beer-stats/")
beer.data
#tag is div and selector is a class called stat-container 
stats.table= html_node(beer.data, "div.stat-container")
states=html_text(html_nodes(beer.data,"div.stat-container h1"),trim=T)
states

# 
stat.cat=c("per-state","economic-impact","production")
breweries=data.table(NULL)
for (x in stat.cat) {
  dat1=data.frame(state=states, stat.cat= x)
  for (y in c("total","per-capita")) {
    m1=html_nodes(beer.data,paste0("#",x))
    m2=html_nodes(m1,paste0(".",y))
    m3=html_text(html_node(m2,".count"),trim=TRUE)
    dat1=cbind(dat1,m3)
  }
  breweries=rbind(breweries, dat1)
}

names(breweries)[3:4]=c("total","per-capita")
breweries
str(breweries)

breweries$total=gsub(",","",breweries$total)
breweries$total=as.numeric(breweries$total)
breweries$`per-capita`=as.numeric(breweries$`per-capita`)
breweries$stat.cat=gsub("-","_",breweries$stat.cat)

breweries$total=gsub(",","",breweries$total)
str(breweries)

breweries$stat.cat=gsub("economic_impact","sales",breweries$stat.cat)
breweries$stat.cat=gsub("per_state","breweries",breweries$stat.cat)

breweries

# another way of doing it 
breweries$stat.cat=as.factor(breweries$stat.cat)
levels(breweries$stat.cat)=c("Sales","Brewries","Production")

#Both the data frame that we pulled out and the one in assignment 3 are similar
##################################################
#PART2


#Step A
#i) use the read_html to create an xml documnet of NPS homepage
nps.url="https://www.nps.gov/index.htm"
nps.home.data=read_html(nps.url)
nps.home.data

#ii) extract the first html node 
stat.list=html_node(nps.home.data,"ul.dropdown-menu")
stat.list

#iii) extract all html node objects 
state=html_nodes(nps.home.data,"ul.dropdown-menu>li")

nps.home.dta = read_html("https://www.nps.gov/index.htm")

#Extract URL path for each state
#iv) extract the url path and name for each state and place them in a dataframe

GetUrlName=function(url,state.txt){
  url=nps.home.data %>% html_nodes(".dropdown-menu>li>a") 
  url.txt=html_text(url)
  path.url=html_attr(url,"href")# to extract the states's url
  url=paste0("https://www.nps.gov",path.url)# putting together the full absolute url
  state.name=html_text(html_nodes(nps.home.data,"ul.dropdown-menu>li"))# to extract the states names
  state.name
  return(data.frame(state.name, url, stringsAsFactors = FALSE))
}

state.path = GetUrlName(state)
#########################################################
#Step B
#i) extract by the numbers call out for nps.state.data 
#ii) extarcting all nodes for state-level info and
# lets for instance extract by the number call out for minnesota 
mn.dta=read_html("https://www.nps.gov/state/mn/index.htm")
stats.tab=html_nodes(mn.dta,"ul.state_numbers>li")
stats.mn=html_text(stats.tab,trim=T)
stats.mn

#separating the values from the var_long and putting them into a single data table
value = sub("\\s.*", "", stats.mn)
var_long = sub("^\\S+\\s+", "", stats.mn) 
  
value 
var_long

stats.dt.mn = as.data.table(cbind(value, var_long))
stats.dt.mn
#cleaning the data table

library(gsubfn)
value=gsubfn(".", list("," = "", "$"=""), value)
var_long=gsubfn(".", list("»"="", "&"=""),var_long)
var_long=trimws(var_long)
value=as.numeric(value, rm.na=T)
stats.dt.mn=cbind(var_long,value)

#iii) Applying the previous example in the form of a function
#create a function to extract the values and long variable name

GetStats=function(url){
  nps.state.data = read_html(state.path$url[[1]])
  stats.tab = html_nodes(nps.state.data, "ul.state_numbers>li")
  stats=html_text(stats.tab,trim=T)
  ext.dta=function(list){
    html_text(html_nodes(list[1], "li"))
  }
stats.list=lapply(state.name,GetStats) # to apply the function to every element pf state.name
stats.df=as.data.frame(stats.list)
value = sub("\\s.*", "", stats.df[[1]])  # tto extract value and long variable names
var_long = sub("^\\S+\\s+", "", stats.df[[1]]) 
stats.dt = as.data.table(cbind(value, var_long))
value=gsubfn(".", list("," = "", "$"=""),  stats.df[[1]])#cleaning data
var_long=gsubfn(".", list("»"="", "&"=""), stats.df[[1]])
var_long=trimws(var_long)
stats.dt=stats.dt[, .(var_long= trimws(gsubfn(".", list("»"="", "&"=""), stats.df[[1]]))),
                       value = as.numeric(gsubfn(".", list("," = "", "$"=""),  stats.df[[1]]))]
return( stats.dt)
}

#Step C

#i) base url is already set in the above steps

#ii)read nps-vars.csv file

all.states=fread("../data/nps_vars.csv")
colnames(all.states)

#ii) I already formed the general url for each state so here I am just going to 
#extract the info for each state using the lapply instead of the loop command
#I first start off by creating the GetStat function and apply it to
# each state

## to apply the GetStats function to all elements in state.path using a loop function

for (x in 1:length(state.path[[1]])) {
    state.stats = GetStats(state.path)
    names(state.stats) = c("var_long", state.path[[2]][x]) # change value to state name
         all.states = merge(all.states, state.stats, "var_long", all = TRUE) #Merge states with var_long
       }
       
# another way
state.stats=lapply(state.path, GetStats(url)) 

all.states

##################################################################

# Part 3

r.Play = readLines("../data/MuchAdo.txt")

#Substitute places where name is spelled normally:

r.Play = gsub("Benedick", "Benedict", r.Play, fixed = TRUE)
r.Play = gsub("BENEDICK", "BENEDICT", r.Play, fixed = TRUE)

#modified character vector
writeLines(r.Play,con = "../data/muchAdo.txt")



###################################################################
# Part 4
#separate all the words in the muchAdo file

#Step A
m =strsplit(rawPlay, split = " ", fixed = T)


ma.words = unlist(unlist(m)
                  [unlist(m) != ""])

ma.words

#step B
# remove punctuation and change to lower case
ma.words = tolower(gsub("[[:punct:]]", "", ma.words)
                   
                   [gsub("[[:punct:]]", "", ma.words) != ""])

#Step C 

# create the table
ma.freq = table(ma.words)

#sorting the table
ma.freq = sort(ma.freq, decreasing = T)

#Removing  words that have four or fewer letters 
ma.words = ma.words[nchar(ma.words) >= 4]

#New sorted frequency table
ma.freq1 = table(ma.words)
ma.freq1 = sort(ma.freq1, decreasing =T)

# to get the 20 most common words 
head(ma.freq1,20)

# these are:
#that /will /with /benedick/claudio/your /have/ beatrice/  leonato
# pedro /this/hero /what/ good/love/ would/ thou/shall/ they / well



