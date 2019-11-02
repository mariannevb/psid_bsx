* value labels
cap label drop _all
label define married_label 1 "Married" 2 "Never married" 3 "Widowed" 4 "Divorced" 5 "Separated" 8 "na" 9"na"
label define yesno_label 1 "Yes" 2 "No" 8 "na" 9 "na"
label define ira_label 1 "Mostly/all stocks" 2 "Some of each" 3 "Mostly/all bonds/annuities" 7 "other" 8 "na" 9 "na" 0 "innapropriate"
label define own_label 1 "Own" 2 "Rent" 5 "Neither"
label define yn_label 0 "No" 1 "Yes" 

cap label var id_marital married_label

