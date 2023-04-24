* Please note that this requires the yfinance package to be installed;
* Scrape BTC price in USD over a time frame that can be adjusted below;
proc python;
submit;
import yfinance as yf
import datetime

yf.pdr_override()

df = yf.download('BTC-USD', datetime.datetime(2020, 1, 1), datetime.datetime(2023, 2, 2))['Close']

SAS.df2sd(df, 'work.btc')
endsubmit;
run;

* Load the result data to CAS;
cas mysess;

* Adjust date to have the correct format;
data casuser.btc(promote=yes);
	length closeDate 8.;
	format closeDate date9.;
	set work.btc;
	closeDate = input(substr(date, 1, 10), YYMMDD10.);
run;

cas mysess terminate;