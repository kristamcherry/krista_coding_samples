*****************
* Project: Fam Health Shocks
* Coder: Krista Cherry 
* Date: 10/30/2024

* We want to record: 
* bene's first IP emerg hospitalization 
* bene's first flag for the following Chronic Conditions: 
* amie alzhdmte hipfrace strktiae chrnkdne brainj_medicare_ever,
* liver_medicare_ever spiinj_medicare_ever visual_medicare_ever 
* cancer_medicare_ever mental_medicare_ever 

* merge to the denominator file (bsfab) to get not-time-varying demographics 
* including the first file year the bene is observed 

* we use: 
* bsfab, medpar, bsfcc, bsfo 
*****************

program main 
    medpar 
    bsfcc_o 
    bsfab 
    merge 
end 

* first IP emergency hospitalization, comes from medpar 
program medpar 
    forvalues i = 1992 / 2017 {
        use "$data_extract/med/`i'/med`i'.dta", clear
        
        *dropping SNF stays
        keep if sslssnf == "L" | sslssnf == "S" 
        
        *keeping emergency stays 
        destring type_adm, replace force 
        gen emergency = inlist(type_adm, 1, 2, 5)
        keep if emergency == 1

        keep bene_id type_adm admsndt
        tempfile medpar`i'
        save `medpar`i'', replace 
    }

    use `medpar1992', clear
    forvalues i = 1993 / 2017 {
        append using `medpar`i''
    }
    
    gsort bene_id admsndt
    by bene_id: egen fst_ip_emerg_admsn = min(admsndt) 
    drop if admsndt != fst_ip_emerg_admsn

    keep bene_id fst_ip_emerg_admsn
    duplicates drop

    gisid bene_id
    save "$temp/medpar_shock.dta", replace
end 

program bsfcc_o 
* we go 2000 - 2017 because there is no "bsfo" file in 1999 
    forvalues i = 2000 / 2017 {
        use "$data_extract/bsfcc/`i'/bsfcc`i'.dta", clear 
        duplicates tag bene_id, gen(dup_tag)
        drop if dup_tag > 0
        merge 1:1 bene_id using "$data_extract/bsfo/`i'/bsfo`i'.dta", nogen 

        cap drop file_year
        gen file_year = `i'

        egen mental_medicare_ever = rowmin(anxi_medicare_ever bipl_medicare_ever depsn_medicare_ever ptra_medicare_ever deprssne)
        egen cancer_medicare_ever = rowmin(cncrbrse cncrclre cncrprse cncrlnge cncendme leuklymph_medicare_ever)

        keep bene_id file_year amie alzhdmte hipfrace strktiae chrnkdne brainj_medicare_ever liver_medicare_ever spiinj_medicare_ever visual_medicare_ever cancer_medicare_ever mental_medicare_ever   

        tempfile cc`i'
        save `cc`i'', replace 
    }

    use `cc2000', clear
    forvalues i = 2001 / 2017 {
        append using `cc`i''
    }

    gisid bene_id file_year

    foreach var in amie alzhdmte hipfrace strktiae chrnkdne brainj_medicare_ever liver_medicare_ever spiinj_medicare_ever visual_medicare_ever cancer_medicare_ever mental_medicare_ever {
        cap drop `var'1
        gsort bene_id file_year
        by bene_id: egen `var'1 = first(`var')
        format `var'1 %tdD_m_Y
    }
    collapse (min) amie1 alzhdmte1 hipfrace1 strktiae1 chrnkdne1 brainj_medicare_ever1 liver_medicare_ever1 spiinj_medicare_ever1 visual_medicare_ever1 cancer_medicare_ever1 mental_medicare_ever1, by(bene_id) 
    gisid bene_id

    save "$temp/cc_shock.dta"
end 

*We're keeping U.S. based benes 
program bsfab 
    forvalues i = 1992/2017 {
        use "$data_extract/bsfab/`i'/bsfab`i'.dta", clear
        cap drop file_year
        gen file_year = `i'

        drop if mi(bene_dob)

        *drop observations outside of the U.S. 
        drop if state_cd=="" | state_cd=="00" |state_cd=="40" | state_cd=="48" 
        drop if state_cd=="54" | state_cd=="55" | state_cd=="56" | state_cd=="57" 
        drop if state_cd=="58" | state_cd=="59" | state_cd=="60" | state_cd=="61" 
        drop if state_cd=="62" | state_cd=="63" | state_cd=="64" | state_cd=="65" 
        drop if state_cd=="66" | state_cd=="75" | state_cd=="77" | state_cd=="79" 
        drop if state_cd=="81" | state_cd=="82" | state_cd=="83" | state_cd=="84" 
        drop if state_cd=="85" | state_cd=="86" | state_cd=="87" | state_cd=="88" 
        drop if state_cd=="89" | state_cd=="90" | state_cd=="91" | state_cd=="92" 
        drop if state_cd=="93" | state_cd=="94" | state_cd=="95" | state_cd=="96" 
        drop if state_cd=="97" | state_cd=="98" | state_cd=="99" | state_cd=="70"
        drop if state_cd=="67" | state_cd=="68" | state_cd=="69" | state_cd=="71" 
        drop if state_cd=="73" | state_cd=="74" | state_cd=="76" | state_cd=="78"

        keep bene_id file_year bene_dob death_dt sex race 

        tempfile bsfab`i'
        save `bsfab`i'', replace 
    }

    use `bsfab1992', clear
    forvalues i = 1993/2017 {
        append using `bsfab`i''
    }
    gisid bene_id file_year

    gsort bene_id file_year
    by bene_id: egen first_record = first(file_year)

    *dropping benes with varying birth and death dates
    *see program written below
    drop_varying_var, invar(bene_dob)
    drop_varying_var, invar(death_dt)

    gsort bene_id death_dt
    by bene_id: replace death_dt = death_dt[1]

    *flagging individuals 
    flag_social_group, invar(sex) outvar(male) value("1")
    flag_social_group, invar(race) outvar(white) value("2")

    keep bene_id first_record bene_dob death_dt male white
    duplicates drop
    gisid bene_id

    save "$temp/bsfab_shock.dta", replace
end 

program merge 
    use "$temp/bsfab_shock.dta", clear 
    merge 1:1 bene_id using "$temp/medpar_shock.dta", nogen 
    merge 1:1 bene_id using "$temp/cc_shock.dta", nogen
    save "$derived/bene_shocks.dta", replace
end 

* private programs
program drop drop_varying_var
program drop_varying_var 
    syntax, invar(varname)
    gsort bene_id file_year
    by bene_id: egen first_`invar' = first(`invar')
    gen flag = first_`invar' != `invar'
    by bene_id: egen flag_any = max(flag)
    drop if flag_any == 1
    drop flag 
    drop flag_any 
end

program drop flag_social_group
program flag_social_group 
    syntax, invar(varname) outvar(name) value(string)
    count if mi(`invar')
    gen not_`outvar' = (`invar' != "`value'")
    gsort bene_id
    by bene_id: egen all_not_`outvar' = total(not_`outvar')
    gen `outvar' = (all_not_`outvar' == 0)
    count if `outvar' == 1
end

main