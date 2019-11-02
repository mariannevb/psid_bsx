*psid_clean.do
*
/*
This program calls
	keep.do // superset of all variables needed for analysis
	labels.do // value labels for coded variables
	Rmagic.do // rename variables using output from R program
	This program generates:
		"./output/psid_clean.dta" // all data files specified in the Excel spreadsheet
		"./output/psid_edited.dta" // edits psid_clean.dta to create consistently measured variables
		"./output/psid_edited.csv" //a .csv file for use in R, if desired
*/
	cap cd "/Users/xu/Dropbox/XU/interlabor/"
 
	if "`c(hostname)'"=="rose" {
	cd "c:/Users/BaxterMarianne/Dropbox (BOSTON UNIVERSITY)/psid/" 
	}
	
set more off
clear
set maxvar 10000
set more off
clear

* what does this comment mean?
note: The 2017-2005 provide the LONGITUDINAL weights; the 2003-1999 provide additional the CROSS-SECTIONAL weights. */

* code-folding for blocks that do not normally need to be run
test=1
if test=0 {
* =============================================================================
* Keep Identifiers, Characteristics, and Relevant Questions
* =============================================================================

/* this block combines wealth and family files when these are separate; 
* creates complete data files at wave level with filename clean_famYYYY.dta
* create the family files from the psid-provided STATA programs, 
*	with wealth added for waves 1999-2007 inclusive

cd "./input"

* loop to add the wealth supplements for waves 1999-2007
local add 1999 2001 2003 2005 2007
foreach x of local add {
* Merge the 1999 wealth file with the 1999 family file before selecting variales
* all the "S" variables are in the wealth file, not the family file
* for merging wealth and family files, 
*	create variable id_temp corresponding to the interview # in the wealth and family files
do WLTH`x'.do
cap rename S401 id_temp 
cap rename S501 id_temp 
cap rename S601 id_temp 
cap rename S701 id_temp 
cap rename S801 id_temp 
sort id_temp
save "../output/WLTH`x'.dta", replace
do "FAM`x'ER.do"
cap clonevar id_temp=ER13002 
cap clonevar id_temp=ER17002 
cap clonevar id_temp=ER21002 
cap clonevar id_temp=ER25002 
cap clonevar id_temp=ER36002 
sort id_temp
merge 1:1 id_temp using "../output/WLTH`x'.dta"
drop _merge
drop id_temp
erase "../output/WLTH`x'.dta"
save "../output/clean_fam`x'.dta", replace
}

*************************************************************************************
* 2009 - 2017: years without wealth supplement ==> no S-named variables
do "./FAM2017ER.do"
save "../output/clean_fam2017.dta", replace
do "./FAM2015ER.do"
save "../output/clean_fam2015.dta", replace
do "./FAM2013ER.do"
save "../output/clean_fam2013.dta", replace
do "./FAM2011ER.do"
save "../output/clean_fam2011.dta", replace
do "./FAM2009ER.do"
save "../output/clean_fam2009.dta", replace
cd "../"
*/


********  BEGIN XU-ONLY BLOCK *****************************************************
/* needs to be run only once; already done; extra files removed
*the files can be re-generated from the \programs directory
* the extra files are also in dropbox folder \xu papers\psid_backup_files_and_code

* this block assembles the Xu yearly files with selected variables: "simple" in file name

global waves 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017

foreach x of global waves {
clear matrix
clear mata
use "./output/three_self_psid_simple_fam`x'.dta"
sort id_interview
do   "./program/keep.do"
gen id_wave=`x'
la var id_wave "WAVE"
save "./output/xu_fam`x'.dta", replace
clear
}


* Xu-only block:

clear matrix
clear mata
* combine wave files
* NOTE: local waves; different from global earlier; does not include 1999
local waves  2001 2003 2005 2007 2009 2011 2013 2015 2017
use "./output/xu_fam1999.dta", replace
foreach x of local waves {
append using "./output/xu_fam`x'.dta"
cap erase "./output/xu_fam`x'.dta"
}

cap erase "./output/xu_fam1999.dta"
sort id_interview id_wave
aorder
order i* m*
save "./output/xu_fam_all.dta",replace
*/
******************************** END XU BLOCK  **********************************************
}

* Begin selection of variables not in the original Xu dataset

global waves 1999 2001 2003 2005 2007 2009 2011 2013 2015 2017

***********************************BEGIN NEW BLOCK **********************************

foreach x of global waves {
clear matrix
clear mata

* start with 'clean' raw data, now incl. family+wealth, rename and keep variables from excel list
* then add variables using Rmagic and keep; add WAVE variable; save by year, then combine

use  "./output/clean_fam`x'.dta", clear
do "./program/Rmagic.do"
do "./program/keep.do"
gen id_wave=`x'
la var id_wave "WAVE"
sort id_interview
save "./output/temp_mb`x'.dta",replace
}


clear matrix
clear mata
* combine wave files
* NOTE: local waves; different from global earlier; does not include 1999
local waves  2001 2003 2005 2007 2009 2011 2013 2015 2017
use "./output/temp_mb1999.dta", replace
foreach x of local waves {
append using "./output/temp_mb`x'.dta"
cap erase "./output/temp_mb`x'.dta"
}
sort id_interview
cap erase "./output/temp_mb1999.dta"
save  "./output/mb_fam_all.dta",replace

***********************************END NEW BLOCK **********************************

******************************** BEGIN COMBINE BLOCK  **********************************************
* combine the all-years Xu file with the all-years MB file:
use "./output/xu_fam_all.dta",replace
merge 1:1 id_interview id_wave using "./output/mb_fam_all.dta"
aorder
order i* m*
save "./output/psid_clean.dta",replace

******************************** END COMBINE BLOCK  **********************************************
* several variables need additional cleaning to combine/edit/etc. variables for consistency
* this may not be complete at this time

use "./output/psid_clean.dta",replace
* create and add value labels; handle topcoding
do "./program/labels.do

* debt_all (total debt) ends in 2009; individual components after that

gen debt_temp=debt_credit_card+debt_legal+debt_medical+debt_student_loan+debt_family
* for debt_all, don't know or refuse to answer coded as $1 trillion
* deal with this by setting missing values (853 obs, about 1% of total)
replace debt_all=. if debt_all==1000000000.00
* clear out extras and finish the combining; remove pieces
clonevar debt_all_temp=debt_all
la var debt_all_temp "copy of debt_all to extend with the 'pieces sum'"
*fill in the post-2009 debt total with the individual sums
replace debt_all=debt_temp if id_wave>2009
la var debt_all "w39 VALUE ALL DEBTS CALC FROM COMPONENTS AFTER 2009"
* drop components if desired 
drop debt_credit_card debt_legal debt_medical debt_student_loan debt_family
*********************************************************************************************************************************
* create net value variables for years after switch e.g. value of business
replace value_net_other_real_estate = value_other_real_estate - debt_other_real_estate if id_wave>2011
replace value_net_business = value_business-debt_business if id_wave>2011
* drop components of net value
*drop value_other_real_estate debt_other_real_estate value_business debt_business

* debt: debt_all ends in 2009; subsequently replaced by individual categories; 
save "./output/psid_edited.dta",replace

* export a .csv version, if desired
export delimited using "./excel/psid_edited.csv",  replace
*****************************************************************************************
* additional analysis would start here, or in a new file

* tracking interviews for each family
bysort id_interview: gen int_N=_N
bysort id_interview: gen int_number=_n
la var int_number "interview # for family"
la var int_N "total # interview for family"
