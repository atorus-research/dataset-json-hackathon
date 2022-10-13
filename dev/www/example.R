## ----setup, warning=FALSE, results='hold', echo=FALSE-------------------------
knitr::knit_hooks$set(purl = knitr::hook_purl)

## ---- warning=FALSE, results='hold', message=FALSE----------------------------
options(repos = c(
  pharmaverse = 'https://pharmaverse.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))


suppressPackageStartupMessages({
   library(metacore)
   library(metatools)
   library(admiral)
   library(xportr)
   library(dplyr)
   library(tidyr)
   library(safetyData)
   library(lubridate)
   library(stringr)
   library(haven)
   remotes::install_github("atorus-research/timber", ref = "dev")
  library(timber)
})

# Read in data 
data("sdtm_dm")
data("sdtm_ds")
data("sdtm_ex")
data("sdtm_vs")
data("sdtm_lb")
data("sdtm_sv")
data("sdtm_sc")
data("sdtm_mh")
data("sdtm_qs")

# Read in metacore object 
load(metacore_example("pilot_ADaM.rda"))
metacore <- metacore %>% 
  select_dataset("ADSL")

## -----------------------------------------------------------------------------
metacore$ds_vars

## ---- error=TRUE--------------------------------------------------------------
build_from_derived(metacore, list(), predecessor_only = FALSE)

## ----demographcis-------------------------------------------------------------
adsl_preds <- build_from_derived(metacore, list("dm" = sdtm_dm), predecessor_only = FALSE, keep = TRUE)
head(adsl_preds)

## -----------------------------------------------------------------------------
race <- metacore$codelist$codes[16]
race

## ----ct-----------------------------------------------------------------------
adsl_ct <- adsl_preds %>% 
   create_cat_var(metacore, AGE, AGEGR1, AGEGR1N) %>% 
   create_var_from_codelist(metacore, RACE, RACEN) %>% 
   create_var_from_codelist(metacore, TRT01P, TRT01PN) %>% 
   mutate(
      SITEID = as.character(SITEID),
      SITEGR1 = SITEID, 
      TRT01A = TRT01P,
      TRT01AN = TRT01PN,
      ITTFL = if_else(!is.na(ARM) & ARM != "Screen Failure", "Y", "N"))

## ----exposure-----------------------------------------------------------------

adsl_dates <- adsl_ct %>%
   derive_var_trtsdtm(dataset_ex = sdtm_ex) %>% # Derive Datetime of First Exposure to Treatment
   derive_var_trtedtm(dataset_ex = sdtm_ex) %>% # Derive Datetime of Last Exposure to Treatment
   derive_vars_dtm_to_dt(source_vars = vars(TRTSDTM, TRTEDTM)) %>%  #Convert Datetime variables to date 
   mutate(TRTDURD = as.numeric(TRTEDT - TRTSDT) + 1,
          CUMDOSE = TRT01PN * TRTDURD,
          AVGDD = CUMDOSE/TRTDURD,
          SAFFL = if_else(ITTFL == "Y" & !is.na(TRTSDT), "Y", "N")) %>% 
          drop_unspec_vars(metacore)
   

## ----disposition, warning=FALSE-----------------------------------------------
adsl_dispo <- adsl_dates %>% 
   # Derive a Disposition Status 
   derive_disposition_status(
      dataset_ds = sdtm_ds,
      new_var = EOSSTT,
      status_var = DSDECOD,
      filter = DSCAT == "DISPOSITION EVENT"
   ) %>%
   # Derive a Disposition Reason
   derive_disposition_reason(
      dataset_ds = sdtm_ds,
      new_var = DCSREAS,
      reason_var = DSDECOD,
      filter = DSCAT == "DISPOSITION EVENT" & DSDECOD != "SCREEN FAILURE"
   ) %>% 
   # Derived Disposition Date 
   derive_disposition_dt(
      dataset_ds = sdtm_ds,
      new_var = RFENDT,
      dtc = DSSTDTC,
      filter_ds = DSCAT == "OTHER EVENT" & DSDECOD == "FINAL RETRIEVAL VISIT"
   ) %>% 
   # Getting the standardize dispositions from codelist 
   create_var_from_codelist(metacore, EOSSTT, DCDECOD) %>% 
   # Creating disposition flags 
   mutate(
      DISCONFL = if_else(DCDECOD != "COMPLETED", "Y", NA_character_),
      DSRAEFL = if_else(DCDECOD != "ADVERSE EVENT", "Y", NA_character_))

# Get end of treatment visit 
adsl_dispo <- sdtm_ds %>% 
   filter(DSTERM =='PROTOCOL COMPLETED') %>% 
   mutate(VISNUMEN = if_else(VISITNUM == 13, 12, VISITNUM)) %>% 
   select(USUBJID, VISNUMEN) %>% 
   left_join(adsl_dispo, ., by = "USUBJID")


## ----BMI----------------------------------------------------------------------
# Get heights at screening cause those are the only heights available 
heights <- sdtm_vs %>% 
   filter(VISITNUM == 1, VSTESTCD == 'HEIGHT') %>% 
   select(USUBJID, VSTEST, VSSTRESN)

bmis <- sdtm_vs %>% 
   # Get baseline weight 
   filter( VISITNUM == 3, VSTESTCD == "WEIGHT") %>% 
   select(USUBJID, VSTEST, VSSTRESN) %>% 
   # Combine with height 
   bind_rows(heights) %>% 
   # Pivot to a row per subject and calculate BMIBL
   pivot_wider(names_from = VSTEST, values_from = VSSTRESN) %>% 
   mutate(BMIBL = compute_bmi(Height, Weight)) %>% 
   rename(WEIGHTBL = Weight, HEIGHTBL = Height) %>%
   # Create the BMI grouping using the control terminology 
   create_cat_var(metacore, BMIBL, BMIBLGR1)
bmis 

adsl_bmi <- left_join(adsl_dispo, bmis, by = "USUBJID")


## ----Complete Flags-----------------------------------------------------------

completer_cal <- function(.data, wk_num, sv){
   new_col <- paste0("COMP", wk_num, "FL") %>% sym()
   sv %>% 
      group_by(USUBJID) %>% 
      filter(VISIT == paste("WEEK", wk_num)) %>% 
      select(USUBJID, SVSTDTC) %>% 
      left_join(.data, . , by = "USUBJID") %>% 
      mutate({{new_col }}:= if_else(!is.na(SVSTDTC) && TRTEDT >= SVSTDTC, "Y", "N")) %>% 
      select(-SVSTDTC)
}

first_visit <- sdtm_sv %>% 
   filter(VISITNUM == 1) %>% 
   mutate(VISIT1DT = as_date(SVSTDTC)) %>%
   select(USUBJID, VISIT1DT) 

adsl_fls <- adsl_bmi %>% 
   completer_cal(8, sdtm_sv) %>% 
   completer_cal(16, sdtm_sv) %>% 
   completer_cal(24, sdtm_sv) %>% 
   left_join(first_visit, by= "USUBJID")

## ----Medical History----------------------------------------------------------
adsl_ed <- sdtm_sc %>% 
   filter(SCTESTCD == "EDLEVEL") %>% 
   select(USUBJID, SCSTRESN) %>% 
   rename(EDUCLVL = SCSTRESN) %>% 
   left_join(adsl_fls, ., by = "USUBJID")

adsl_alz <- sdtm_qs %>% 
   group_by(USUBJID) %>% 
   filter(QSCAT == "ALZHEIMER'S DISEASE ASSESSMENT SCALE") %>%
   summarise(MMSETOT = sum(as.numeric(QSORRES), na.rm = TRUE)) %>% 
   left_join(adsl_ed, ., by = "USUBJID")

adsl_mh <- sdtm_mh %>% 
   filter(MHCAT == "PRIMARY DIAGNOSIS") %>% 
   mutate(DISONSDT = as_date(MHSTDTC)) %>%
   select(USUBJID, DISONSDT) %>% 
   left_join(adsl_alz, ., by = "USUBJID") %>% 
   mutate(DURDIS = interval(DISONSDT, VISIT1DT) %/% months(1)) %>% 
   create_cat_var(metacore, DURDIS, DURDSGR1)

## ----Efficacy Flag------------------------------------------------------------
adsl_raw <- sdtm_qs %>% 
   filter(VISITNUM > 3) %>% 
   group_by(USUBJID) %>% 
   summarise(efffl = any(QSTEST == "ADAS-COG(11) Subscore") & any(QSTESTCD == "CIBIC")) %>% 
   left_join(adsl_mh, by = "USUBJID") %>% 
   mutate(EFFFL = if_else(efffl & SAFFL == "Y", "Y", "N")) %>% 
   drop_unspec_vars(metacore) #This will drop any columns that aren't specificed in the metacore object


## ----checks, message=FALSE, warning=FALSE-------------------------------------
adsl_raw %>% 
  xportr_order(metacore) %>% # Sorts the rows by the sort keys 
  xportr_type(metacore) %>% # Coerce variable type to match spec
  xportr_length(metacore) %>% # Assigns SAS length from a variable level metadata 
  xportr_label(metacore) %>% # Assigns variable label from metacore specifications 
  xportr_df_label(metacore) %>% # Assigns datasel label form metacore specficiations
  xportr_write("adsl.xpt") #ssigns dataset label from metacore specifications

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  timber::axecute("./example.R", remove_log_object = TRUE)

