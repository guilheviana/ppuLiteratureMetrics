library(ggplot2)
source("utils.R")

if (file.exists("scholar_results.rds")) {
  scholar_results <- readRDS("scholar_results.rds")
} else {
  source("search_google_scholar.R")
}

# reformats the results table removing low-quality entries
scholar_results_filtered <- scholar_results |>
  tidyr::drop_na() |>  # removes entries with incomplete fields
  dplyr::filter(journal != "bioRxiv", publisher != "biorxiv.org|arxiv.org") |>
  dplyr::filter(stringr::str_detect(title, "CITATION|KEYWORDS", negate = TRUE)) |>
  dplyr::filter(stringr::str_detect(year, ",", negate = TRUE)) # removes 2 entries with commas in the year field

# # saves files
# scholar_results|>
#   dplyr::arrange(year) |>
#   readr::write_tsv(file = "raw_results.tsv")
#
# scholar_results_filtered |>
#   dplyr::arrange(year) |>
#   readr::write_tsv(file = "filtered_results.tsv")


# prepares data for plotting
genbank_cumsum <- getCumulativeNumberOfPubs(dataset = scholar_results_filtered, filter  = "AE015451")
refseq_cumsum <- getCumulativeNumberOfPubs(dataset = scholar_results_filtered, filter  = "NC_002947")

cumsum_data <- dplyr::bind_rows(genbank_cumsum, refseq_cumsum) |>
  dplyr::mutate(query = forcats::fct_relevel(query, c("NC_002947", "AE015451")),
                year = as.numeric(year))

# plot
pub_history <- cumsum_data |>
  ggplot(aes(x = year, y = cummulative, fill = query, color = query, group)) +
  geom_area(linewidth = 1) +
  geom_vline(mapping = aes(xintercept = 2016), linetype = "dashed", linewidth = 0.6, color = "gray50") +
  scale_x_continuous(breaks = c(2002, 2006, 2010, 2014, 2018, 2022))+
  scale_y_continuous(expand = expansion(mult = c(0,0.05))) +
  scale_fill_manual(name = "Search term", breaks = c("NC_002947", "AE015451"), values = c("lightsteelblue", "#8cba9d"), labels = c('"NC_002947"', '"AE015451"')) +
  scale_color_manual(name = "Search term", breaks = c("NC_002947", "AE015451"), labels = c('"NC_002947"', '"AE015451"'), values = c("steelblue", "#5b7866")) +
  labs(x = "Year", y = "Cumulative number of publications") +
  theme_light(base_size = 16) +
  theme(
    panel.border = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0.18, 0.85),
    axis.text = element_text(color = "black"),
    axis.line = element_line(color = "black", linewidth = 0.5)
  )

# save plot
ggsave(pub_history, filename = "Fig - publication history", device = Cairo::CairoSVG, path = "../output/panels/", width = 6, height = 5, units = "in", dpi = 300)
