library(ggplot2)
source("utils.R")

refseq_url <- "https://www.ncbi.nlm.nih.gov/nuccore/NC_002947.4?report=girevhist"
genbank_url <- "https://www.ncbi.nlm.nih.gov/nuccore/AE015451.2?report=girevhist"

version_history <- purrr::map(c(refseq_url, genbank_url), ~ {
                        rvest::read_html(.x) |>
                          rvest::html_table() |>
                          purrr::pluck(1) |>
                          dplyr::select(Version:`Update Date`)
                     }) |>
                     purrr::list_rbind()

vh_formatted <- version_history |>
  dplyr::mutate(`Update Date` = lubridate::mdy_hm(`Update Date`),
                Accession = stringr::str_remove_all(Accession, "\\.+\\d"),
                Year = lubridate::year(`Update Date`),
                individual.record = 1) |>
  dplyr::arrange(Accession, `Update Date`) |>
  dplyr::group_by(`Accession`, Year) |>
  dplyr::reframe(n.versions = sum(individual.record)) |>
  dplyr::group_by(Accession) |>
  dplyr::mutate(`Cumulative Number of Updates` = cumsum(n.versions)) |>
  dplyr::select(-n.versions) |>
  dplyr::bind_rows( # fills out some of the information for the plot
    tibble::tibble(
      Accession = c("AE015451"),
      Year = c(2023),
      `Cumulative Number of Updates` = c(12))
  )

# getting the year major releases were rolled out (if needed)
major_releases <- version_history |>
  dplyr::mutate(
    `Update Date` = lubridate::mdy_hm(`Update Date`),
    Year = lubridate::year(`Update Date`))
  dplyr::group_by(Accession) |>
  dplyr::slice_min(`Update Date`, n = 1)

version_history_plot <- vh_formatted |>
  ggplot(aes(x = Year,  y = `Cumulative Number of Updates`, group = Accession, color = Accession)) +
  geom_vline(mapping = aes(xintercept = 2016), linetype = "dashed", linewidth = 0.6, color = "gray50") +
  geom_step(linewidth = 2) +
  scale_color_manual(name = "Accession", breaks = c("NC_002947", "AE015451"), values = c("steelblue", "#8cba9d"))+
  scale_x_continuous(breaks = c(2002, 2006, 2010, 2014, 2018, 2022)) +
  scale_y_continuous(expand = expansion(mult = c(0.025,0.05)), breaks = c(0, 20, 40, 60), labels = c(0, 20, 40, 60)) +
  labs(x = "Year", y = "Cumulative number of revisions") +
  theme_light(base_size = 16) +
  theme(
    panel.border = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0.15, 0.85),
    axis.text = element_text(color = "black"),
    axis.line = element_line(color = "black", linewidth = 0.5)
  )


ggsave(version_history_plot, filename = "Fig 4. - version history", device = Cairo::CairoSVG, path = "../output/panels/", width = 6, height = 5, units = "in", dpi = 300)

