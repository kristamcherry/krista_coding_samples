*********************
* Project: Fam Health Shocks
* Desc: Run file for first stage figures
* Coder: Krista Cherry 
* Date Updated: 10/30/24 
***********************

clear all
set trace on 
set tracedepth 2

log using "famhealth_run.log", replace

program run_project 
    define_paths_globals
    famhealth_01_firststage
end 

program define_paths_globals
    * Global project paths
    global mypath "/disk/agedisk3/medicare.work/polyakova-DUA54740/kcherr-dua54740/FamHealthShocks_local"
    global code "$mypath/code"
    global temp "$mypath/temp"
    global derived "$mypath/derived"
    global exhibits "$mypath/exhibits"
    global data_extract "/disk/aging/medicare/data/harm/05pct"
    global raw "$mypath/raw"
end 

program famhealth_01_firststage 
    *dataset construction
    run "$code/cleaning/famhealth_01_shocks.do"
    *run "$code/cleaning/famhealth_02_outcomes.do"
    
    *regression
    *run "$code/analysis/famhealth_01_analysis.do"
end 

run_project
log close