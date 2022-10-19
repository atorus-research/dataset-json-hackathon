# xportrjson


# Purpose

This is a proof of concept R extension package developed for the CDISC Open-Source Alliance (COSA) Hackathon in the Fall of 2022.  We envision extending the `{xportr}` package, which currently allows users to write out xpt files with an appropriately created specification file.  The extension package would allow users to both read and write JSON files while being able to use `{xportr}` functions to update metadata on the dataset.  

## Motivation

Clinical Programmers and Statisticians need to be able to read in and write out data while working on SDTMs, ADaMs or TLFs.  We feel that a simple R package that has the ability to seamlessly read in and write out JSON dataset files will ease this burden of JSON adoption.  A Clinical Programmer or Statistician can then easily use all their current tools within `{tidyverse}` and `{pharmaverse}` packages while working with `.sas7bdat`, `rda`, `xpt` or `JSON` files in a R session.

## Current Scope of Work

The current work for this extension package is very limited with simple readers and writers created to work with JSON files. A user wishing to use the writer functions will need to create a simple specification file that can apply the type, length and labels for newly created variables.  A user wishing to use the reader functions just needs to find an appropriately made JSON dataset file specific to clinical trial datasets.

## Future Scope of Work

1) We have some concerns with R's ability to write out large datasets to JSON.  We did not perform any benchmarks analysis or work with any large datasets.
2) Finish write functions for JSON files.
3) Develop Unit Testing for functions.
4) Develop more examples to work with `{xportr}` functions.
5) Explore why `xportr_type()` function is not working.
5) Develop more examples to show working with datasets using packages like `{admiral}`.

## Source
[Dataset-JSON Hackathon](https://wiki.cdisc.org/display/DSJSONHACK/Dataset-JSON+Hackathon+Home)
