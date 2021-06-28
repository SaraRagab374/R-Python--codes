#Name:Sara Ragab
#Assignment 5


remove(list=ls())
###############################################################################
#setwd("~/Dropbox/My Mac (Sara’s MacBook Air)/Desktop/APEC 8221/Assignment 5")

library(rvest)

#Part 1: Get the plays
#1. Do some web scraping to retrieve the URLs for the comedies from the homepage.
#2.Clean URL vectors
comedies.dta=read_html("http://shakespeare.mit.edu/")
url=comedies.dta %>% html_nodes("td a") 
path.url=html_attr(url,"href")
url.list=as.list(head(path.url,n=17))# to keep only the url of the comedy plays
url.play=paste0("http://shakespeare.mit.edu/",url.list)

#2 to get the url for the entire pley replace index with full
url.play=gsub("index.html","full.html",url.play)# to get the url for the entire pley replace index with full
url.play

####################################################################################
#3 making short names of the URLs
url.list
url.list=gsub("/index.html","",url.list)
url.list

#make a vector of file names
url.file=paste0(url.list,".html")

# Hence, we should have a total of 3 vectors 
url.play #a vector of corrected URLs
url.list#a vector of short names
url.file# a vector of filenames

####################################################################################
#4. Now write a loop that downloads the HTML version of each play,
#and saves it to a plays directory

#Creating a play directory if one doesn't already exist
if (!dir.exists("plays")) {dir.create("plays")}# if the plays directory does not exist create a directory called plays

#creating a loop that goes over each play's html and downloads it to the plays directory
for(i in seq_along(url.play)){
    download.file(url.play[i],destfile=paste0("plays/",url.list[i]))}


##############################################################################################
#Part 2: Remove the HTML tags to get pure text

#1) 
#Read one of the files into a character vector
Play.1=readLines(con="../Assignment 5/plays/allswell")
Play.1
#Create a function called rm.tags that removes html  tags from a single line
line=Play.1[600]
line

cln.line=gsub( "<.*?>","", line)# to clean a single line
cln.line# we now get a tags free line
Play.1=gsub( "<.*?>","", Play.1)# applying this to the entire play
Play.1# we get almost a tag free play 

#Now Creating the rm.tag function to remove the tags 

rm.tag=function(line){
  return(gsub( "<.*?>","",line))}
# The way this part  "<.*?>" works is as follows:
#.* is a wildcard for 1 or more characters, 
#? says preceding item should happen once or not at all

cln.Play1=rm.tag(Play.1) #This function removes the html tags<> and everything between them
head(cln.Play1)
############################
# Another way of doing 1) as mentioned in the assignment
# where we identify the places of the tags first

rm.tag2 = function(line){
  while (grepl("<.*>",line)==TRUE) { #using the grepl command to identify which lines have the tags <>
    tag1 = regexpr("<",line)# using the regexpr fn to identify where the open tag > is 
    tag2 = regexpr(">",line)# using the regexpr fn to identify the closed tag
    ext.tag = substr(line, tag1, tag2)#extracting those tags
    rm.tag = gsub(ext.tag,"",line) # removing the tags
  }
  return(line)
}

#######################################################################################

#6.Creating a function "kill.two.line.tags" 
#that finds and deletes these lines from a character vector containing a play.

kill.two.line.tags = function(rm.remaining.tag) { 
      OpenTag =which(
                 grepl("<", rm.remaining.tag, fixed = TRUE) # identify the lines that have only the open tag <
                 &!grepl(">", rm.remaining.tag, fixed = TRUE)) # and not the closed tag
         
      OpenTag.rm = rm.remaining.tag[-OpenTag] # removing the lines which have open tags
         
         ClosedTag = which(
             grepl(">", OpenTag.rm, fixed = TRUE) # identify the lines that have only the closed tag >
             &!grepl("<", OpenTag.rm, fixed = TRUE)) # and not the open tag
         
         ClosedTag.rm= OpenTag.rm[-ClosedTag] # remove the lines which have closed tags
         
         return(ClosedTag.rm)
}

#checking whether it worked 

cln.Play1=kill.two.line.tags(Play.1)
 head(cln.Play1)
 # when we tried before the rm.tag function we saw that the first 2 lines still had the carrorts 
 # one had the open carrot and the following one had the closed carrot, we can see now that those have been 
 #removed by the kill.two.line.tags function 

 ####################################################################### 
 
#7. Write a loop that loops over the plays, reading each one into a character vector
#and puts it into a list called plays.
       
#Creating an empty list called plays
 plays = list()  

 #creating a loop that goes into the url.file(where the plays are present) and reads each play      
for (i in seq_along(url.file)) {
  plays[[i]]=readLines(con=paste0("plays/",url.file[[i]]))} 
 
 # the global environment shows a list called plays with 17 elements each represnts a comedy play 
 # and each play containsthe scripts lines
 
#######################################################################      
       
#8. Next loop over the elements of the list (plays[[1]], plays[[2]],. . . ) 
 
#(a) delete double-line tags with your kill.two.line.tags function 
                      
# we apply a nested loop function where the rm.tag function is applied to the inner loop
 # followed by the kill.two.line.tags function which applies to the whole thing (outer loop)
for (i in seq_along(plays)) {
         play = plays[[i]]
         play = kill.two.line.tags(play)

#(b)replacing each line with a tagless version created by your rm.tags function.        
 for (j in seq_along(plays)) {
           play[j] = rm.tag(play[j])
         }
         plays[[i]] = play
       }
       
#9.Use this line of code to verify that you’ve gotten rid of all the tags:

lapply(plays, function(p){sum(grepl("[<>]", p))}) # after we run it twice results show zero tags !!
#########################################################################
