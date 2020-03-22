output$summaryTables <- renderUI({
    dataTableOutput("summaryDT_canton")
})

output$summaryDT_canton <- renderDataTable(getSummaryDT(data_atDate(current_date), "canton_name", selectable = TRUE))
proxy_summaryDT_canton  <- dataTableProxy("summaryDT_canton")

observeEvent(input$timeSlider, {
  data <- data_atDate(input$timeSlider) %>%
    select(canton_name, positive_cases, deceased, active)
  replaceData(proxy_summaryDT_canton, data, rownames = FALSE)
}, ignoreInit = TRUE, ignoreNULL = TRUE)

observeEvent(input$summaryDT_canton_row_last_clicked, {
  selectedRow     <- input$summaryDT_canton_row_last_clicked
  selectedCanton <- unlist(data_atDate(input$timeSlider)[selectedRow, "canton_name"])
  location        <- data_evolution %>%
    distinct(canton_name, lat, long) %>%
    filter(canton_name == selectedCanton) %>%
    summarise(
      lat  = mean(lat),
      long = mean(long)
    )
  leafletProxy("overview_map") %>%
    setView(lng = location$long, lat = location$lat, zoom = 8)
})

summariseData <- function(df, groupBy) {
  df %>%
    group_by(!!sym(groupBy)) %>%
    summarise(
      "Positive Fälle" = sum(positive_cases),
      "Verstorben"  = sum(deceased),
      "Aktive Fälle"    = sum(active)
    ) %>%
    as.data.frame()
}

getSummaryDT <- function(data, groupBy, selectable = FALSE) {
  data <- data_atDate(current_date) %>%
    select(canton_name, positive_cases, deceased, active)
  datatable(
    na.omit(data),
    rownames  = FALSE,
    colnames = c("Kanton", "Positiv", "Verstorben", "Aktiv"),
    options   = list(
      order          = list(1, "desc"),
      scrollX        = TRUE,
      scrollY        = "40vh",
      scrollCollapse = T,
      dom            = 'ft',
      paging         = FALSE
    ),
    selection = ifelse(selectable, "single", "none")
  )
}