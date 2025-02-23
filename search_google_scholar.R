
# if rsDriver does not work, make sure you have both google-chrome and
# its driver installed in your machine (RSelenium does not update it past ver. 114)
# To find the driver, look up your current chrome version and download
# the proper file from https://developer.chrome.com/docs/chromedriver/downloads
# Then extract it in the exact path your other drivers are
# e.g. /local/share/binman_chromedriver/
# The folder containing the driver should not have any additional files
# (eg LICENSE.chromedriver)

getDataFromGoogleScholar <- function(query) {

  # starts the RSelenium session
  server <- RSelenium::rsDriver(browser = "chrome",
                              phantomver = NULL,
                              chromever = "131.0.6778.87",
                              geckover = NULL,
                              port = 4435L,
                              check = TRUE)
  client <- server$client

  # initialize the loop variables
  titleinfo <- NA
  pubinfo <- NA
  startidx <- 0
  publication_data <- NULL


  while(length(pubinfo) > 0 && length(titleinfo) > 0) {
    url <- glue::glue('https://scholar.google.com/scholar?start={startidx}&q="{query}"')
    client$navigate(url)


    # when RSelenium navigate to the url, google might ask you if you are a robot
    # solve the captcha on the broweser and let R take care of the data
    # For this, the script waits 20 seconds before proceeding...
    Sys.sleep(20)

    # gets publications titles
    titleinfo <- client$findElements(using = "css", ".gs_rt") |>
      purrr::map_chr(~ {
        title <- .x$getElementText() |> unlist()
        return(title)
        })

    # gets author, journal, year, etc...
    pubinfo <- client$findElements(using = "css",".gs_a")|>
      purrr::map_chr(~ {
        info <- .x$getElementText() |> unlist()
        return(info)
      })

    # checks if we reached the end of the search results -- then exits the loop accordingly
    if( length(pubinfo) == 0 && length(titleinfo) == 0) break

    # formats titles
    titledata <- titleinfo |>
      stringr::str_remove_all("\\[HTML\\]|\\[PDF\\]") |> # removes leftover brackets from the title
      stringr::str_squish()

    # formats metadata and joins the title
    pubdata <- pubinfo |>
      stringr::str_split(pattern = "-\\s") |>
      purrr::map( ~ {
        data.frame(authors = .x[1], article = .x[2], publisher = .x[3])
      }) |>
      dplyr::bind_rows() |>
      tidyr::separate_wider_delim(cols = article,
                                  delim = ",",
                                  names = c("journal", "year"),
                                  too_few = "align_end",
                                  too_many = "merge") |>
      dplyr::mutate(title = titledata) |>
      dplyr::relocate(all_of(c("authors", "journal", "year", "publisher", "title")))


    # appends the new information to the overall results dataframe
    publication_data <- dplyr::bind_rows(publication_data, pubdata)

    # goes to the next page...
    startidx <- startidx + 10
  }

  # closes the conection
  server$server$stop()

  return(publication_data)
}

# getting GenBank results
genbank <- getDataFromGoogleScholar("AE015451") |>
  dplyr::mutate(query = "AE015451")

# getting refseq results
refseq <- getDataFromGoogleScholar("NC_002947") |>
  dplyr::mutate(query = "NC_002947")

scholar_results <- dplyr::bind_rows(genbank, refseq)

saveRDS(scholar_results, "scholar_results.rds")

## saves the new table
# if (!file.exists("../output/tables/scholar_results.tsv")) {
#   res <- readRDS("scholar_results.rds")
#   readr::write_tsv(x = res, "../output/tables/scholar_results.tsv")
# }
