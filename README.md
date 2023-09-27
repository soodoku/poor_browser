## Poor Browsers

Given that older browsers are likelier to display the survey incorrectly and the type of browser a person is using is a reasonable proxy for respondent's proficiency in using computers (and possibly speed of the Internet connection), we hypothesize that respondents using older browsers may abandon surveys at higher rates than those using more modern browsers, and that surveys taken using old browsers contain greater missing data. We control for some known correlates of extent of missing data, and propensity to abandon surveys - race, age, and education.

### Data and Script

* [Data](luth2.rdata)
* [Script](browser.R)

### Description of Data and Measures

#### Data

Respondents come from 1.4 million members of Internet panel. Panel members were recruited in several ways. Initially, RDD phone calls were made to invite American adults to sign up to receive email invitations to participate in surveys, yielding about 2,500 panel members.  Additional phone calls were made to professionals working in the information technology sector who were on professional lists; these calls yielded about 2,500 more panel members.  These initial 5,000 panel members were offered a chance to win cash or gift certificates if they would refer friends or family who might sign up to complete online surveys.  Referred panel members were offered the same incentives to refer other people.  Panel members received a chance to win a prize each time they completed a survey, when someone they referred completed a survey, and each time the referral's referral completed a survey. Panel members were also recruited through online ads (on the firm's own website, news sites, blogs or search engines) and through emails from businesses or non-profit organizations with which the panelist had an affiliation. 72,000 members of a stratified random sample of panel received an email inviting them to participate in our survey, and 2,632 did so (4\% response rate with a 2\% completion rate).  Probability of selection within demographic strata was specified so that invitees resembled the distribution of gender, age, and Census region in the U.S. adult population, as estimated by the 2000 Census.  No quotas were used to restrict who completed the survey. Respondents were entered into a sweepstakes in return for completing our survey.  Email invitations were sent on December 15th, 21st, 2009, and January 10th, 2010. The resulting sample is highly representative with average error  on observable sociodemographic characteristics less than 2\%.

#### Measures

**DV**

1. Whether the person completed the survey or not
2. Number of missing fields in the survey

**IV**

1. Browser - dichotomized into old and new. Old - Internet Explorer 7 or lower, Firefox 3.0 or lower. 
2. Age in years
3. Education - years of education
4. Race - 4 categories: White NH, Black NH, Hispanics, Other

### Results and Discussion

#### Results

1. People using older browsers are less likely to complete the survey. 
2. There is some evidence that respondents using older browsers have more missing data.

#### Discussion

The poor, the old, the less educated, and racial minorities abandon Internet surveys at higher rates. It is not clear 
why. In fact with incentive based surveys, one expects the pattern among the poor to be roughly opposite of what we see. 
One possible explanation for the counter-intuitive empirical observation is that respondents from these demographics 
have slower Internet connections, use older browsers (which pose other problems), and are less proficient in using 
computers.

Inference is hampered by limitations of the measures, and the sample. Type of browser is a proxy for user's proficiency in using the Internet, bandwidth of her Internet connection etc. Direct measures of variables of interest - speed on Internet connection, data on how survey is displayed, etc. - would be vastly superior.

Since the data are from a self-selected sample recruited online, there is every chance that it over-represents those 
who are better at using computers and the Internet. This bias in sample likely means that effects reported here are not
representative of population at large. 
