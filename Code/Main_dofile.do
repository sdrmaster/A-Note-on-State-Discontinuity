// main.do
// Master script to run all sub-scripts in order

clear all
set more off // Prevent pauses during execution

//Installing packages only when they are needed
local packages "alluvial asdoc bumpline colrspace estout palettes sankey tabout wbopendata "
foreach pkg in `packages' {
    cap which `pkg'
    if _rc {
        ssc install `pkg'
    }
}


//Overall directory path

global package="C:\Users\sdavi\OneDrive\Desktop\Reproducibility_Package/"

//Additional directory paths
global di1 "${package}Data\Raw/"
global do1 "${package}Data\Cleaned/"
global do2 "${package}Data\Cleaned\New/"
global tab "${package}Outputs\Main\Tables/"
global fig "${package}Outputs\Main\Figures/"
global annex_tab "${package}Outputs\Annex\Tables/"

// Run each script in sequence
do 01_IPUMS_Cleaning
do 02_ACLED
do 03_Merging_ACLED_IPUMS
do 04_State_Discontinuity
do 05_Analysis
do 06_Regression_Analysis
do 07_Maps_Cleaning
do 08_Robustness


// Completion message
di "All scripts executed successfully!"

exit