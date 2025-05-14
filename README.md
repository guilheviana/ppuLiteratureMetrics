# Historical publication records for _P. putida_ KT2440 genome annotations

This repository contains scripts for downloading publication metadata from Google Scholar using [RSelenium](https://github.com/ropensci/RSelenium) and the [Chromium](https://github.com/chromium/chromium) web browser.

It is part of an upcoming publication analyzing the usage of different _P. putida_ genome annotation versions across the literature

## Main file structure
- `search_google_scholar.R` : Main script. Defines the function for retrieving search results from Google Scholar and runs these searches with GenBank and RefSeq _P. putida_ genomic
accession codes. The retrieved results are available as an R binary data file (`scholar_results.rds`).
- `utils.R` : Auxiliary functions used in this analysis. In this repo, contains a single function for obtaining the cumulative number of publications for a given accession code over the years.
- `figure 4 - publications timeseries.R` and `figure 4 - version history timeseries.R` : Functions used for generating the plots found in the final manuscript.

## Contact info
If you have any questions or feedback, please contact the first author Guilherme (Gui) Viana de Siqueira at **guiviana@proton.com**.
