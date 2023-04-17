# Script for easy testing
library(httr)

## Modified function from class example 
counter = 0 # try scraping 2 pages to start
responses_tbl = tibble() # creating tibble to store responses
get_url = "https://old.reddit.com/r/IOPsychology/" # initial start url

while(counter < 3){
  response = (content(GET(get_url, user_agent("UMN Student lee02903@umn.edu")), as = "text"))
  responses_tbl = bind_rows(responses_tbl, tibble(response))
  print(paste("Just received data from", get_url))
  
  next_url = read_html(response) %>% html_elements("span.next-button a") %>% html_attr("href")
  get_url = next_url
  
  counter = counter + 1
  Sys.sleep(2)
}


page_ls = responses_tbl$response

# creating a function that gets the post title and num of upvotes
get_info = function(single_page){
  single_page = read_html(single_page)
  xpath_post = "//div[contains(@class, 'odd') or contains(@class, 'even')]//a[contains(@class, 'title may-blank')]"
  xpath_upvotes = "//div[contains(@class, 'odd') or contains(@class, 'even')]//div[@class = 'score unvoted']"
  
  post = html_elements(single_page, xpath = xpath_post) %>% html_text()
  upvotes = html_elements(single_page, xpath = xpath_upvotes) %>% 
    html_text() %>% 
    as.numeric() 
  io_tbl = tibble(post, upvotes)
  return(io_tbl)
}

# this is a list containing separate tibbles for each page 
result = lapply(responses_tbl$response, get_info)

# to collapse all the list to form one giant dataset
week12_tbl = result %>% bind_rows()

