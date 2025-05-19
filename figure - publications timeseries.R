library(ggplot2)
source("utils.R")

if (file.exists("scholar_results.rds")) {
  scholar_results <- readRDS("scholar_results.rds")
} else {
  source("search_google_scholar.R")
}

misformatted <- scholar_results |>
  dplyr::filter((is.na(journal) | is.na(publisher) | is.na(year) | stringr::str_detect(title, "\\[CITATION\\]")))


results_clean <- scholar_results |>

  dplyr::filter(!((is.na(journal) | is.na(publisher) | is.na(year) | stringr::str_detect(title, "\\[CITATION\\]")))) |>
  dplyr::mutate(year = as.numeric(year)) |>
  dplyr::filter(!is.na(year))

genbank_cumsum <- getCumulativeNumberOfPubs(filter  = "AE015451")
refseq_cumsum <- getCumulativeNumberOfPubs(filter  = "NC_002947")

cumsum_data <- dplyr::bind_rows(genbank_cumsum, refseq_cumsum) |>
  dplyr::mutate(query = forcats::fct_relevel(query, c("NC_002947", "AE015451")))


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

ggsave(pub_history, filename = "Fig - publication history", device = Cairo::CairoSVG, path = "../output/panels/", width = 6, height = 5, units = "in", dpi = 300)
