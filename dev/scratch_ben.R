
x
names(x)
names(x$clinicalData)

x$clinicalData$itemGroupData$IG.DM$items[[22]]$label

$clinicalData$itemGroupData$IG.DM$items[[22]]$type
[1] "string"

$clinicalData$itemGroupData$IG.DM$items[[22]]$length
[1] 28


$clinicalData$itemGroupData$IG.DM$items[[23]]
$clinicalData$itemGroupData$IG.DM$items[[23]]$OID
[1] "IT.DM.ACTARMCD"

$clinicalData$itemGroupData$IG.DM$items[[23]]$name
[1] "ACTARMCD"

$clinicalData$itemGroupData$IG.DM$items[[23]]$label
[1] "Actual Arm Code"

$clinicalData$itemGroupData$IG.DM$items[[23]]$type
[1] "string"

$clinicalData$itemGroupData$IG.DM$items[[23]]$length
[1] 8


$clinicalData$itemGroupData$IG.DM$items[[24]]
$clinicalData$itemGroupData$IG.DM$items[[24]]$OID
[1] "IT.DM.ACTARM"

$clinicalData$itemGroupData$IG.DM$items[[24]]$name
[1] "ACTARM"

$clinicalData$itemGroupData$IG.DM$items[[24]]$label
[1] "Description of Actual Arm"

$clinicalData$itemGroupData$IG.DM$items[[24]]$type
[1] "string"

$clinicalData$itemGroupData$IG.DM$items[[24]]$length
[1] 28


$clinicalData$itemGroupData$IG.DM$items[[25]]
$clinicalData$itemGroupData$IG.DM$items[[25]]$OID
[1] "IT.DM.ARMNRS"

$clinicalData$itemGroupData$IG.DM$items[[25]]$name
[1] "ARMNRS"

$clinicalData$itemGroupData$IG.DM$items[[25]]$label
[1] "Reason Arm and/or Actual Arm is Null"

$clinicalData$itemGroupData$IG.DM$items[[25]]$type
[1] "string"

$clinicalData$itemGroupData$IG.DM$items[[25]]$length
[1] 14


$clinicalData$itemGroupData$IG.DM$items[[26]]
$clinicalData$itemGroupData$IG.DM$items[[26]]$OID
[1] "IT.DM.ACTARMUD"

$clinicalData$itemGroupData$IG.DM$items[[26]]$name
[1] "ACTARMUD"

$clinicalData$itemGroupData$IG.DM$items[[26]]$label
[1] "Description of Unplanned Actual Arm"

$clinicalData$itemGroupData$IG.DM$items[[26]]$type
[1] "string"

$clinicalData$itemGroupData$IG.DM$items[[26]]$length
[1] 200


$clinicalData$itemGroupData$IG.DM$items[[27]]
$clinicalData$itemGroupData$IG.DM$items[[27]]$OID
[1] "IT.DM.COUNTRY"

$clinicalData$itemGroupData$IG.DM$items[[27]]$name
[1] "COUNTRY"

$clinicalData$itemGroupData$IG.DM$items[[27]]$label
[1] "Country"

$clinicalData$itemGroupData$IG.DM$items[[27]]$type
[1] "string"

$clinicalData$itemGroupData$IG.DM$items[[27]]$length
[1] 3

library(rjson)

source("read_dataset_json.R")

dm_url <-"https://raw.githubusercontent.com/cdisc-org/DataExchange-DatasetJson/master/examples/sdtm/dm.json"

dm <- read_dataset_json(dm)


# Glimpse the records before reading them into environment?
# Why just view it regulary glimpse?
dm_url <-"https://raw.githubusercontent.com/cdisc-org/DataExchange-DatasetJson/master/examples/sdtm/dm.json$itemGroupData"

fromJSON(dm_url, simplifyVector=TRUE)

glimpse_json <- function( )

write_dataset_join <- function(){



}

dm <- jsonlite::fromJSON(url("https://raw.githubusercontent.com/cdisc-org/DataExchange-DatasetJson/master/examples/sdtm/dm.json"), simplifyVector=FALSE)

dm$clinicalData$studyOID
dm$clinicalData$metaDataVersionOID

clinicalData <- vector(mode="list", length=3)

clinicalData[[1]] <- c("studyOID: cdisc.com/CDISCPILOT01", "metaDataVersionOID: MDV.MSGv2.0.SDTMIG.3.3.SDTM.1.7")
#clinicalData[[2]] <- c("MDV.MSGv2.0.SDTMIG.3.3.SDTM.1.7")
#clinicalData[[3]] <- vector(mode="list", length=3)
#clinicalData[[3]][[1]] <- c("itemGroupData")


jsonData <- toJSON(clinicalData)

write(jsonData, "output.json")


library(rjson)
data <- list(clinicalData=c("studyOID", "metaDataVersionOID"),b=2,c=3)
json <- toJSON(data)
json

cat(json, file="data.json")
