# Poor Browser

# Load libs
library(dplyr)
library(lubridate)
library(splines)
library(stringr)

## Load data
## Via Prospect Theory
load("luth2.rdata")

# Operating System
# luth2$agent.x
luth2 <- luth2 %>%
  mutate(osx = case_when(
    grepl("windows", cleanagx) ~ "windows",
    grepl("macintosh", cleanagx) ~ "apple", 
    grepl("linux", cleanagx) ~ "linux",
    grepl("iphone", cleanagx) ~ "iphone",
    grepl("webtv", cleanagx) ~ "webtv",
    grepl("nokia", cleanagx) ~ "nokia",
    TRUE ~ "unknown"
  ))

# Browser 1
luth2 <- luth2 %>%
  mutate(
    browx = case_when(
      grepl("msie4|98|iphone|symbian|msie5|msie6|msie7|firefox30", cleanagx) ~ "old",
      TRUE ~ "other"
    ))

luth2 <- luth2 %>%
  mutate(
    browx2 = case_when(
      grepl("firefox", cleanagx) ~ "firefox",
      grepl("msie4|msie5|msie6", cleanagx) ~ "msie6",   
      grepl("msie7", cleanagx) ~ "msie7",
      grepl("msie8", cleanagx) ~ "msie8",
      TRUE ~ "other"
    ))

# Browser 2
luth2 <- luth2 %>%
  mutate(
    browy = case_when(
      grepl("msie4|98|iphone|symbian|msie5|msie6|msie7|firefox30", cleanagy) ~ "old",
      TRUE ~ "other"
    ))

luth2 <- luth2 %>%
  mutate(
    browy2 = case_when(
      grepl("firefox", cleanagy) ~ "firefox",
      grepl("msie4|msie5|msie6", cleanagy) ~ "msie6",
      grepl("msie7", cleanagy) ~ "msie7",
      grepl("msie8", cleanagy) ~ "msie8",
      TRUE ~ "other"
    ))

# Duration
luth2$durx <- as.duration(luth2$surveytime.x)
luth2$dury <- luth2$surveytime.y

# total NAs
luth2$na <- rowSums(is.na(luth2))

# Propensity to Complete by Browser
# You can glm with family = binomial also
summary(lm(status.x == 'COMPLETED' ~ I(browx == 'old'), data=luth2[!is.na(luth2$pcid.x), ]))
summary(lm(status.y == 'COMPLETED' ~ I(browy == 'old'), data=luth2[!is.na(luth2$pcid.y), ]))

# Number of NAs by Browser
summary(lm(na ~ I(browx == 'old') + ppage + as.factor(ppeduc) + as.factor(race2) + ppgender, data=luth2[!is.na(luth2$pcid.x), ]))
summary(lm(na ~ I(browy == 'old') + ppage + as.factor(ppeduc) + as.factor(race2) + ppgender, data=luth2[!is.na(luth2$pcid.y), ]))
