/*example from stata help:

sysuse auto, clear
local keep make price sales
ds
local vars `r(varlist)'
local tokeep : list vars & keep
display "`tokeep'"
keep `tokeep'
ds

*/
#delimit ;
local keepvars
id_release
id_interview
id_residence
id_state
id_splitoff
id_mode
id_composition
id_institution
id_1968family
id_reinstated
id_interviewer
id_month
id_day
id_year
id_length
id_size
id_age
id_sex
id_agespouse
id_sexpouse
id_children
id_youngest
id_nonfu
id_marital
id_household
id_lweight
id_csweight
major_food
minor_food_home
minor_food_delivered
minor_food_out
major_housing
minor_housing_mortgage
minor_housing_rent
minor_housing_tax
minor_housing_insurance
minor_housing_util
broad_housing_util_gas
broad_housing_util_elect
broad_housing_util_water
broad_housing_util_other
minor_housing_telephone
minor_housing_computer
minor_housing_repair
minor_housing_furnish
major_trans
minor_trans_carload
minor_trans_cardown
minor_trans_carlease
minor_trans_carinsurance
minor_trans_carother
minor_trans_repaire
minor_trans_gasoline
minor_trans_parking
minor_trans_public
minor_trans_taxicab
minor_trans_other
major_edu
major_child
major_health
minor_health_hospital
minor_health_doctor
minor_health_prescription
minor_health_insurance
major_trip
major_cloth
major_recreation

wtr_stock
value_stock
profit_stock
wtr_ckg
wtr_bonds
profit_bonds 
pension_r
pension_s
pension_comp_r
pension_comp_s
own_rent
amt_ckg
wealth_wo_equity
wealth_w_equity
value_ira
value_vehicles
amt_pension_r
amt_initial_prev_pension_r
amt_now_prev_pension_r
amt_pension_s
amt_initial_prev_pension_s
amt_now_prev_pension_s
value_house
value_home_equity
home_mort_prin_1
home_mort_prin_2
value_net_business
value_business
debt_business
value_net_other_real_estate
value_other_real_estate
debt_other_real_estate
value_net_other_assets
debt_all
debt_credit_card
debt_student_loan
debt_medical
debt_legal
debt_family

;
#delimit cr

ds
local vars `r(varlist)'
local tokeep : list vars & keepvars
display "`tokeep'"
keep `tokeep'
ds
