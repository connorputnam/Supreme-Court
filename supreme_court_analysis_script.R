library(tidyverse)
library(jsonlite)
library(ggthemes)
library(anytime)
library(kableExtra)
library(RSQLite)
library(DBI)
library(pander)


# Problem Statement

# Obtain

supreme2 <- read.csv("data/unnested_transcripts.csv") # reading in the data



# Scrub

#selecting variables of interest

supreme <- supreme2 %>% 
  select(X, appointing_president, role_title, date_end, 
         id, date_start, ideology, seniority, opinion_type, 
         vote, member.ID, member.last_name, member.length_of_service, 
         member.view_count, member.identifier, member.name)




# Explore

###Some summary stats
###pander is just a way of displaying plots
summary(supreme$ideology) %>% 
  pander(caption = "Summary Statistics for Ideology")
summary(supreme$member.length_of_service) %>% 
  pander(caption = "Summary Statistics for Member Lenght of Service(Days)")

ggplot(supreme, aes(vote, fill = vote)) + 
  geom_bar() +
  theme_fivethirtyeight() +
  ggtitle("How Often do Judges Vote in the Majority or the Minority",
          subtitle = "From 1790 - 2020")



# Model

## Three Data Analysis Questions


### Question 1

###adding in president elected years and parties
ww2 <- supreme %>%
  filter(appointing_president == "Franklin D. Rossevelt" | appointing_president == "Harry S. Truman"|
         appointing_president == "Dwight D. Eisenhower" | appointing_president == "John F. Kennedy"|
         appointing_president == "Lyndon B. Johnson" | appointing_president == "Richard Nixon"|
         appointing_president == "Gerald Ford"| appointing_president == "Jimmy Carter" |
         appointing_president == "Ronald Reagan"| appointing_president == "George H. W. Bush"|
         appointing_president == "Bill Clinton"| appointing_president == "George W. Bush"|
         appointing_president == "Barack Obama"|  appointing_president == "Donald J. Trump") %>% #takin g only the post ww2 presidents
  mutate(presidental_year = case_when(appointing_president == "Donald J. Trump" ~ 2017,
                                      appointing_president == "Barack Obama" ~ 2009,
                                      appointing_president == "George W. Bush" ~ 2001,
                                      appointing_president == "Bill Clinton" ~ 1993,
                                      appointing_president == "George H. W. Bush" ~ 1989,
                                      appointing_president == "Ronald Reagan" ~ 1981,
                                      appointing_president == "Jimmy Carter" ~ 1977,
                                      appointing_president == "Gerald Ford" ~ 1974,
                                      appointing_president == "Richard Nixon" ~ 1969,
                                      appointing_president == "Lyndon B. Johnson" ~ 1963,
                                      appointing_president == "John F. Kennedy" ~ 1961,
                                      appointing_president == "Dwight D. Eisenhower" ~ 1953,
                                      appointing_president == "Harry S. Truman" ~ 1945,
                                      appointing_president == "Franklin D. Roosevelt" ~ 1933)) %>%
  mutate(party = as.factor(case_when(appointing_president == "Donald J. Trump" ~ "Republican",
                                      appointing_president == "Barack Obama" ~ "Democrat",
                                      appointing_president == "George W. Bush" ~ "Republican",
                                      appointing_president == "Bill Clinton" ~ "Democrat",
                                      appointing_president == "George H. W. Bush" ~ "Republican",
                                      appointing_president == "Ronald Reagan" ~ "Republican",
                                      appointing_president == "Jimmy Carter" ~ "Democrat",
                                      appointing_president == "Gerald Ford" ~ "Republican",
                                      appointing_president == "Richard Nixon" ~ "Republican",
                                      appointing_president == "Lyndon B. Johnson" ~ "Democrat",
                                      appointing_president == "John F. Kennedy" ~ "Democrat",
                                      appointing_president == "Dwight D. Eisenhower" ~ "Republican",
                                      appointing_president == "Harry S. Truman" ~ "Democrat",
                                      appointing_president == "Franklin D. Roosevelt" ~ "Democrat"))) %>%
  mutate(Ideology = as.factor(case_when(party == "Republican" ~ "Conservative",
                                       party == "Democrat" ~ "Liberal")))
###need to also group things for visulization
ww2_bar <- ww2 %>%
  group_by(presidental_year, appointing_president, party) %>%
  summarise(unique(member.name)) %>%
              rename(judge_amount = "unique(member.name)") %>%
              extract(appointing_president, c("FirstName", "LastName"), "([^ ]+) (.*)") %>% #getting the last an first name
              arrange(desc(presidental_year))

kable(head(ww2_bar)) %>% kable_styling(latex_options="scale_down")



#first plot

ggplot(ww2_bar, aes(fct_reorder(LastName, presidental_year), fill = party)) +
  geom_bar() +
  scale_fill_manual(values=c("#26b3f2", "#ec1e26")) +
  theme_fivethirtyeight() +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.7))


### Question 2



ww2_line <- ww2 %>%
  select(appointing_president, ideology, member.last_name, 
         member.length_of_service, presidental_year, party, member.name, date_start, Ideology) %>%
  group_by(member.last_name) %>%
  mutate(average_ideology = mean(ideology)) %>%
  distinct(member.name, .keep_all = TRUE) %>% ###only unique values
  arrange(desc(presidental_year))
  #summarise(unique(member.name)) %>%
  #rename(judge_amount = "unique(member.name)")
  


###second plot
ggplot(ww2_line) +
  geom_bar(aes(reorder(member.last_name, date_start), 
               average_ideology, fill = Ideology),
           stat = "identity") +
  scale_fill_manual(values=c("#ec1e26", "#26b3f2")) +
  # geom_errorbar(aes(member.last_name, average_ideology, 
  #                   ymin = average_ideology + sd(ideology) , 
  #                   ymax = average_ideology - sd(ideology))) +
  coord_flip() + #looks better to flip the graph
  theme_fivethirtyeight() +
  ggtitle("Average Ideology for Supreme Court Justices", 
          subtitle = "Ordered by most recently appointed to latest appointed") +
  theme(axis.text.y = element_text(size = 8)) #+
  #scale_fill_discrete(name = "Ideology")


###density might a good wayu to look at this
ggplot(ww2_line) +
  geom_density(aes(ideology, fill = Ideology), alpha = 0.5, position = "stack") +
  scale_fill_manual(values=c("#ec1e26", "#26b3f2")) +   #manually assign colors
  theme_fivethirtyeight() +
  geom_vline(xintercept = mean(ww2_line$ideology)) #add a vertical line



eras <- supreme2 %>%
  mutate(start_date = anytime(date_start)) %>%
  #distinct(member.name, .keep_all = TRUE) %>%
  select(appointing_president, member.name, start_date, 
         date_end, ideology, member.length_of_service, date_start) %>%
  arrange(desc(start_date)) %>%
  mutate(era = as.factor(case_when(date_start <= -4102444800 ~ "1790 - 1839", #create groups by years
                                   (date_start > -4102444800 & date_start <= -2524521600) ~ "1840 - 1889",
                                   (date_start > -2524521600 & date_start <= -946771200) ~ "1889 - 1940",
                                    (date_start > -2524521600 & date_start <= 662688000) ~ "1941 - 1990"))) %>%
  drop_na(era)


### Question 3

###last plot

ggplot(eras, aes(ideology, member.length_of_service)) +
  geom_jitter(alpha = 0.5, color = "steelblue") +
  facet_wrap(~era, ncol = 2) +
  theme_fivethirtyeight()


