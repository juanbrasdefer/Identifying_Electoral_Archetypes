# so it begins

# libraries, directory ------------------------------------------------------------
library(tidyverse)
library(here)

here::i_am("code/exploring_ANES.R")


# load data -----------------------------------------------------------------------

df <- read.delim(here("data/ANES/2016/anes_timeseries_2016/anes_timeseries_2016_rawdata.txt")
                 , sep = "|", 
                 header = TRUE)  # For tab-separated


#length(unique(df$V160001)) 
# gives 4270
# which means this is definitely our unique identifier column

# VARIABLES ----------------------------------------------------------------------

#Pre-Election Variables
# V161003 - PRE: How often does R pay attn to politics and elections
# V161004 - PRE: How interested in following campaigns
# V161005 - PRE: Did R vote for President in 2012
# V161006 - PRE: Recall of last (2012) Presidential vote choice
# V161008 - PRE: Days in week watch/listen/read news on any media
# V161009 - PRE: Attention to news on any media
# V161010d - PRE: Vote section- FIPS state code for sample address
# V161019 - PRE: Party of registration
# V161021 - PRE: Did R vote in a Presidential primary or caucus
# V161021a - PRE: For which candidate did R vote in Presidential prim
# V161022 - PRE: Already voted in General Election
# V161026 - PRE: Did R vote for President in 2016
# V161027 - PRE: For whom did R vote for President
# V161029b - PRE: Placeholder Code- How long before election R made decision Pres vote
# V161030 - PRE: Does R intend to vote for President
# V161031 - PRE: For whom does R intend to vote for President
# V161032 - PRE: Pref strng for Pres cand for whom R intends to vote
# V161033 - PRE: Does R prefer Pres cand (no intent to register)
# V161034 - PRE: Preference for Pres cand (no intent to register)
# V161036 - PRE: Did R vote for U.S. House of Representatives
# V161039 - PRE: Does R intend to vote for U.S. House
# V161046 - PRE: Did R vote for U.S. Senate
# V161049 - PRE: Does R intend to vote for U.S. Senate
# V161055 - PRE: Did R vote for governor
# V161058 - PRE: Does R intend to vote for governor
# V161064x - PRE: SUMMARY - party of Pre-election Presidential vote/intent/preference
# V161065x - PRE: SUMMARY - party of Pre-election U.S. House vote/intent/preference
# V161066x - PRE: SUMMARY - party of Pre-election U.S. Senate vote/intent/preference
# V161067x - PRE: SUMMARY - party of Pre-election Gubernatorial vote/intent/preference
# V161080 - PRE: Approval of Congress handling its job
# V161081 - PRE: Are things in the country on right track
# V161082 - PRE: Approve or disapprove President handling job as Pres
# V161083 - PRE: Approve or disapprove President handling economy
# V161084 - PRE: Approve or disapprove President handling foreign rel
# V161086 - PRE: Feeling Thermometer: Democratic Presidential cand
# V161087 - PRE: Feeling Thermometer: Republican Presidential cand
# V161095 - PRE: Feeling Thermometer: Democratic Party
# V161096 - PRE: Feeling Thermometer: Republican Party
# V161097 - PRE: Is there anything R likes about Democratic Party
# V161103 - PRE: Is there anything R likes about Republican Party
# V161110 - PRE: R how much better worse off than 1 year ago
# V161111 - PRE: R how much better worse off next year
# V161126 - PRE: 7pt scale Liberal conservative self-placement
# V161128 - PRE: 7pt scale liberal conservative - Dem Pres cand
# V161129 - PRE: 7pt scale liberal conservative - Rep Pres cand
# V161137 - PRE: Income gap today more or less than 20 years ago
# V161139 - PRE: Current economy good or bad
# V161140 - PRE: National economy better worse in last year
# V161144 - PRE: Which party better: handling nations economy
# V161145 - PRE: Care who wins Presidential Election revised version
# V161150a - PRE: VERSION 1A placement- Does R consider voting a duty or choice
# V161150b - PRE: VERSION 1B placement- Does R consider voting a choice or duty
# V161151x - PRE: SUMMARY - Voting as duty or choice
# V161155 - PRE: Party ID: Does R think of self as Dem, Rep, Ind or what
# V161173 - PRE: Rep and Dem adequate parties
# V161215 - PRE: REV How often trust govt in Wash to do what is right
# V161216 - PRE: Govt run by a few big interests or for benefit of all
# V161218 - PRE: How many in government are corrupt
# V161219 - PRE: How often can people be trusted
# V161220 - PRE: Elections make govt pay attention
# V161221 - PRE: Is global warming happening or not
# V161224 - PRE: Govt action about rising temperatures
# V161231 - PRE: R position on gay marriage
# V161234 - PRE: U.S. more or less secure than when Pres took office
# V161235 - PRE: Economy better since 2008
# V161241 - PRE: Is religion important part of R life
# V161267 - PRE: Respondent age
# V161267x - PRE: SUMMARY - Respondent age group
# V161268 - PRE: R marital status
# V161270 - PRE: Highest level of Education
# V161274a - PRE: Previously served on active duty in armed forces
# V161277 - PRE: Initial R employment status, start of occupation module (EMPLOYMENT general)
# V161302 - PRE: Anyone in HH belong to labor union
# V161310x - PRE: SUMMARY - R self-identified race
# V161342 - PRE FTF CASI / WEB: R self-identified gender
# V161513 - PRE FTF CASI / WEB: Years Senator Elected
# V161514 - PRE FTF CASI / WEB: Political knowledge: program Fed govt spends
# V161522 - PRE: How satisfied is R with life

#Post-Election Variables
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#

# V163001a - SAMPLE: Sample location FIPS state
# V163001b - SAMPLE: Sample location state postal abbreviation



