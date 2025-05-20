# Historical publication records for _P. putida_ KT2440 genome annotations

This repository contains scripts for downloading and processing publication metadata from Google Scholar in R using [RSelenium](https://github.com/ropensci/RSelenium) and the [Chromium](https://github.com/chromium/chromium) web browser.

It is part of an upcoming publication analyzing the usage of different _P. putida_ genome annotation versions across the literature

## Main file structure
- `search_google_scholar.R` : Main script. Defines the function for retrieving search results from Google Scholar and runs these searches with GenBank and RefSeq _P. putida_ genomic accession codes. The retrieved results are available as an R binary data file (`scholar_results.rds`), and as TSV files (see below).
- `utils.R` : Auxiliary functions used in this analysis. In this repository, contains a single function for obtaining the cumulative number of publications for a given accession code over the years.
- `figure - publications timeseries.R` and `figure - version history timeseries.R` : Scripts used for generating the plots found in the final manuscript.
- `raw_results.tsv` and `filtered_results.tsv` : tables containing, respectively, the complete and curated search results for _P. putida_ genome annotation keywords "NC_002947" and "AE015451" in Google Scholar, respectively.

## Contact info
If you have any questions or feedback, please contact the first author Guilherme (Gui) Viana de Siqueira at gmvsiq@gmail.com.
