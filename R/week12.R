# Script for easy testing
library(tidyverse)
library(httr)
library(rvest)
library(tictoc)

responses_tbl = tibble() # Creating tibble to store response from get request
get_url = "https://old.reddit.com/r/IOPsychology/" # Initial get url
counter = 1 

tic()
## This is a while loop goes through all visible pages in the io subreddit 
### I initially set it to 100 pages but ran into an error at page 40 because 
### there are only 40 pages right now, so I set 40 for the while loop 

while(counter <= 40){
  response = content(GET(get_url, user_agent("UMN Student lee02903@umn.edu")), as = "text")
  responses_tbl = bind_rows(responses_tbl, tibble(response)) # storing get response to tibble
  print(paste(counter, "Just received data from", get_url))
  
  next_url = read_html(response) %>% html_elements("span.next-button a") %>% html_attr("href")
  get_url = next_url # Setting url for next iteration
  counter = counter + 1 # Incrementing counter for while loop
  
  Sys.sleep(2) # Pause to conform to rate limit
}
toc()

## Creating a function that gets post title and num of upvotes for each page
get_info = function(single_page){
  single_page = read_html(single_page)
  xpath_post = "//div[contains(@class, 'odd') or contains(@class, 'even')]//a[contains(@class, 'title may-blank')]"
  xpath_upvotes = "//div[contains(@class, 'odd') or contains(@class, 'even')]//div[@class = 'score unvoted']"
  
  post = html_elements(single_page, xpath = xpath_post) %>% html_text()
  upvotes = html_elements(single_page, xpath = xpath_upvotes) %>% 
    html_text() %>% 
    as.numeric() 
  
  # Added for myself  to see the post date
  time =  html_elements(single_page, "time:nth-child(1)") %>% html_text() 
  
  io_tbl = tibble(time = time[-1], post, upvotes)
  return(io_tbl)
}

## Outputting a list of posts containing a separate tibble for each page 
posts_ls = lapply(responses_tbl$response, get_info)

## Collapsing all tibbles in the list to form one giant tibble
week12_tbl =  bind_rows(posts_ls) %>% select(-time)

## Saving scraped dataset as week12_tbl.csv
write_csv(week12_tbl, "../data/week12_tbl.csv")