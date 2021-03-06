#' deServer
#'
#' Sets up shinyServer to be able to run DEBrowser interactively.
#'
#' @note \code{deServer}
#' @param input, input params from UI
#' @param output, output params to UI
#' @param session, session variable
#' @return the panel for main plots;
#'
#' @examples
#'     deServer
#'
#' @export
#' @importFrom shiny  actionButton  actionLink  addResourcePath  column 
#'             conditionalPanel  downloadButton  downloadHandler 
#'             eventReactive  fileInput  fluidPage  helpText  isolate 
#'             mainPanel  need  numericInput  observe  observeEvent 
#'             outputOptions  parseQueryString  plotOutput  radioButtons 
#'             reactive  reactiveValues  renderPlot  renderUI  runApp 
#'             selectInput  shinyApp  shinyServer  shinyUI  sidebarLayout 
#'             sidebarPanel  sliderInput  stopApp  tabPanel  tabsetPanel 
#'             textInput  textOutput  titlePanel  uiOutput tags HTML
#'             h4 img icon updateTabsetPanel  updateTextInput  validate 
#'             wellPanel checkboxInput br checkboxGroupInput
#' @importFrom shinyjs show hide enable disable useShinyjs extendShinyjs
#'             js inlineCSS
#' @importFrom d3heatmap d3heatmap renderD3heatmap d3heatmapOutput
#' @importFrom DT datatable dataTableOutput renderDataTable formatStyle
#'             styleInterval
#' @importFrom ggplot2 aes aes_string geom_bar geom_point ggplot
#'             labs scale_x_discrete scale_y_discrete ylab
#'             autoplot
#' @importFrom ggvis add_axis add_legend add_tooltip axis_props
#'             bind_shiny create_broker ggvis ggvisOutput handle_brush
#'             hide_legend layer_bars layer_boxplots layer_points
#'             scale_nominal set_options %>% group_by layer_rects
#'             band scale_numeric hide_axis layer_densities
#' @importFrom gplots heatmap.2 redblue
#' @importFrom igraph layout.kamada.kawai  
#' @importFrom grDevices dev.off pdf
#' @importFrom graphics barplot hist pairs par rect text plot
#' @importFrom stats aggregate as.dist cor cor.test dist
#'             hclust kmeans na.omit prcomp var sd model.matrix
#'             p.adjust
#' @importFrom utils read.table write.table update.packages
#' @importFrom DOSE enrichDO enrichMap gseaplot dotplot
#' @importMethodsFrom AnnotationDbi as.data.frame as.list colnames
#'             head mappedkeys ncol nrow subset keys mapIds
#' @importMethodsFrom GenomicRanges as.factor
#' @importMethodsFrom IRanges as.matrix "colnames<-" mean
#'             nchar paste rownames toupper unique which
#'             as.matrix lapply rev "rownames<-"
#' @importMethodsFrom S4Vectors t grepl
#' @importMethodsFrom SummarizedExperiment cbind order
#' @importFrom jsonlite fromJSON
#' @importFrom methods new
#' @importFrom stringi stri_rand_strings
#' @importFrom ReactomePA enrichPathway
#' @importFrom annotate geneSymbols
#' @importFrom reshape2 melt
#' @importFrom baySeq getLibsizes getLikelihoods getLikelihoods.NB
#'             getPriors getPriors.NB nbinomDensity
#' @importMethodsFrom baySeq "densityFunction<-" "libsizes<-"
#' @importFrom clusterProfiler compareCluster enrichKEGG dotplot 
#' @importFrom DESeq2 DESeq DESeqDataSetFromMatrix results
#' @importFrom edgeR calcNormFactors equalizeLibSizes DGEList glmLRT
#'             exactTest estimateCommonDisp glmFit
#' @importFrom limma lmFit voom eBayes topTable
#' @import org.Hs.eg.db
#' @import org.Mm.eg.db
#' @import V8
deServer <- function(input, output, session) {
    tryCatch(
    {
        if (!interactive()) {
            options( shiny.maxRequestSize = 30 * 1024 ^ 2,
                shiny.fullstacktrace = FALSE, shiny.trace=FALSE, 
                shiny.autoreload=TRUE)
            library(debrowser)
            #library(d3heatmap)
            #library(edgeR)
        }
        observeEvent(input$stopApp, {
            stopApp(returnValue = invisible())
        })
        output$programtitle <- renderUI({
            togglePanels(0, c(0), session)
            getProgramTitle(session)
        })
        output$mainpanel <- renderUI({
            a <- NULL
            if (!is.null(randstr()))
                a <- getMainPanel(randstr())
            a
        })
        output$qcpanel <- renderUI({
            getQCPanel(input)
        })
        output$gopanel <- renderUI({
            getGoPanel(!is.null(init_data()))
        })
        output$cutoffSelection <- renderUI({
            nc <- 1
            if (!is.null(choicecounter$nc)) nc <- choicecounter$nc
            getCutOffSelection(nc)
        })
        output$downloadSection <- renderUI({
            a <- getDownloadSection(TRUE, "QC")
            if (!is.null(input$goDE) && input$goDE &&
                !is.null(comparison()$init_data))
                a <- getDownloadSection(!is.null(comparison()$init_data), 
                    "main")
            a
        })
        output$preppanel <- renderUI({
            getDataPrepPanel(!is.null(init_data))
        })
        output$leftMenu  <- renderUI({
            getLeftMenu()
        })
        output$initialmenu <-renderUI({
            getInitialMenu(input, output, session)
        })
        output$loading <- renderUI({
            getLoadingMsg()
        })
        output$logo <- renderUI({
            getLogo()
        })
        output$startup <- renderUI({
            getStartupMsg()
        })
        output$afterload <- renderUI({
            getAfterLoadMsg()
        })
        output$mainmsgs <- renderUI({
            if (is.null(condmsg$text))
                getStartPlotsMsg()
            else
                condmsg$text 
        })
        
        buttonValues <- reactiveValues(goQCplots = FALSE, goDE = FALSE,
            startDE = FALSE)
        
        output$dataready <- reactive({
            hide(id = "loading-debrowser", anim = TRUE, animType = "fade")    
            return(!is.null(Dataset()))
        })
        outputOptions(output, "dataready", 
            suspendWhenHidden = FALSE)
        
        output$definished <- reactive({
            return(!is.null(filt_data()))
        })
        outputOptions(output, "definished", 
            suspendWhenHidden = FALSE)
        Dataset <- reactive({
            load_data(input, session)
        })
        choicecounter <- reactiveValues(nc = 0, qc = 0)
        observeEvent(input$add_btn, {
            shinyjs::enable("startDE")
            buttonValues$startDE <- FALSE
            choicecounter$nc <- choicecounter$nc + 1}
        )
        observeEvent(input$rm_btn, {
            buttonValues$startDE <- FALSE
            if (choicecounter$nc > 0) 
                choicecounter$nc <- choicecounter$nc - 1
            if (choicecounter$nc == 0) 
               shinyjs::disable("startDE")
        })
        observeEvent(input$goDE, {
            shinyjs::disable("startDE")
            hideObj(c("goQCplots", "goDE"))
            showObj(c("add_btn","rm_btn","startDE", "fittype"))
        })
        observeEvent(input$resetsamples, {
            buttonValues$startDE <- FALSE
            showObj(c("goQCplots", "goDE"))
            hideObj(c("add_btn","rm_btn","startDE"))
            choicecounter$nc <- 0
        })
        samples <- reactive({
            if (is.null(Dataset())) return(NULL)
                getSamples(colnames(Dataset()), index = 2)
        })
        output$sampleSelector <- renderUI({
            if (is.null(samples())) return(NULL)
            if (is.null(input$samples))
                samp <- samples()
            else
                samp <- input$samples
            a <- list(
                selectInput("samples",
                label = "Samples",
                choices = samp, multiple = TRUE,
                selected = samp)
            )
        })
        output$conditionSelector <- renderUI({
            selectConditions(Dataset(), choicecounter, input)
        })
        dc <- reactive({
            dc <- NULL
            if (buttonValues$startDE == TRUE){
                dc <- prepDataContainer(Dataset(), choicecounter$nc, 
                isolate(input))
            }
            dc
        })
        observeEvent(input$startDE, {
            buttonValues$startDE <- TRUE
            buttonValues$goQCplots <- FALSE
            init_data <- NULL 
            togglePanels(1, c( 0, 1, 2, 3, 4), session)
            choicecounter$qc <- 0
        })
        observeEvent(input$goQCplots, {
            choicecounter$qc <- 1
            buttonValues$startDE <- FALSE
            buttonValues$goQCplots <- TRUE
            togglePanels(2, c( 0, 2, 4), session)
        })
        comparison <- reactive({
            compselect <- 1
            if (!is.null(input$compselect))
            compselect <- as.integer(input$compselect)
            dc()[[compselect]]
        })
        conds <- reactive({ comparison()$conds })
        cols <- reactive({ comparison()$cols })
        init_data <- reactive({ 
            if (!is.null(comparison()$init_data))
                comparison()$init_data 
            else
                qcdata()
        })
        filt_data <- reactive({
            if (!is.null(comparison()$init_data) &&
                !is.null(input$padjtxt) &&
                !is.null(input$foldChangetxt))
            applyFilters(init_data(), isolate(cols()), isolate(conds()),
                input)
        })
        randstr <- reactive({ 
            a<-NULL
            if (!is.null(selected$data$randstr))
                a<-selected$data$randstr() 
            a
        })
        selected <- reactiveValues(data = NULL)
        observe({
            setFilterParams(session, input)
        })
        condmsg <- reactiveValues(text = NULL)
        observeEvent(input$startPlots, {
            compselect <- 1
            if (!is.null(input$compselect) ) 
                compselect <- as.integer(input$compselect)
            if (!is.null(isolate(filt_data())) && !is.null(input$padjtxt) && 
                !is.null(input$foldChangetxt)) {
                condmsg$text <- getCondMsg(isolate(dc()), input$compselect,
                    isolate(cols()), isolate(conds()))
                selected$data <- getMainPanelPlots(isolate(filt_data()), 
                    isolate(cols()), isolate(conds()), input, compselect)
            }
        })
        qcdata <- reactive({
            prepDataForQC(Dataset()[,input$samples])
        })
        output$qcplotout <- renderPlot({
            if (!is.null(input$col_list) || !is.null(isolate(df_select())))
                getQCReplot(isolate(cols()), isolate(conds()), 
                   df_select(), isolate(input), inputQCPlot())
        })
        df_select <- reactive({
            if (!is.null(isolate(Dataset())))
                getSelectedCols(Dataset(), datasetInput(), input)
        })
        
        v <- c()
        output$intheatmap <- d3heatmap::renderD3heatmap({
            shinyjs::onclick("intheatmap", js$getNames(v))
            getIntHeatmap(isolate(df_select()), input, inputQCPlot())
        })

        output$columnSelForHeatmap <- renderUI({
            wellPanel(id = "tPanel",
                style = "overflow-y:scroll; max-height: 200px",
                checkboxGroupInput("col_list", "Select col to include:",
                isolate(input$samples), 
                selected=isolate(input$samples))
            )
        })
        output$pcaexplained <- renderPlot({
            a <- NULL
            if (!is.null(input$qcplot)) {
                a <- getPCAexplained(datasetInput(), input )
            }
            a
        })

        inputQCPlot <- reactiveValues(clustering_method = "ward.D2",
            distance_method = "cor", interactive = FALSE, width = 700, height = 500)
        inputQCPlot <- eventReactive(input$startQCPlot, {
            m <- c()
            m$clustering_method <- input$clustering_method
            m$distance_method <- input$distance_method
            m$interactive <- input$interactive
            m$width <- input$width
            m$height <- input$height
            return(m)
        })
        
        goplots <- reactive({
            dat <- getDataForTables(input, init_data(),
                      filt_data(), selected,
                      getMostVaried(),  isolate(mergedComp()))
            getGOPlots(dat[[1]][, isolate(cols())], input)
        })

        inputGOstart <- eventReactive(input$startGO, {
            goplots()
        })
        output$GOPlots1 <- renderPlot({
            if (!is.null(inputGOstart()$p) && input$startGO){
               return(inputGOstart()$p)
            }
        })
      
        output$tables <- DT::renderDataTable({
            dat <- getDataForTables(input, init_data(),
                  filt_data(), selected,
                  getMostVaried(),  isolate(mergedComp()))
            dat2 <- removeCols(c("ID", "x", "y","Legend", "Size"), dat[[1]])
            m <- DT::datatable(dat2,
            options = list(lengthMenu = list(c(10, 25, 50, 100),
            c("10", "25", "50", "100")),
            pageLength = 25, paging = TRUE, searching = TRUE)) %>%
            getTableStyle(input, dat[[2]], dat[[3]], buttonValues$startDE)
            m
        })
        getMostVaried <- reactive({
            a <- NULL
            if (choicecounter$qc == 0)
                a <- filt_data()[filt_data()$Legend=="MV" | 
                                 filt_data()$Legend=="GS", ]
            else
                a <- getMostVariedList(data.frame(init_data()), 
                c(input$samples), input$topn, input$mincount)
        a
        })
      
        output$gotable <- DT::renderDataTable({
            if (!is.null(inputGOstart()$table)){
                DT::datatable(inputGOstart()$table,
                    list(lengthMenu = list(c(10, 25, 50, 100),
                    c("10", "25", "50", "100")),
                    pageLength = 25, paging = TRUE, searching = TRUE))
            }
        })

        mergedComp <- reactive({
            dat <- applyFiltersToMergedComparison(
                isolate(mergedCompInit()), choicecounter$nc, input)
            ret <- dat[dat$Legend == "Sig", ]
            #ret[ret$Legend == "Sig", ] <- NULL
            ret
        })
        
        mergedCompInit <- reactive({
            merged <- getMergedComparison(
                isolate(Dataset()), isolate(dc()), choicecounter$nc, input)
            merged
        })
        datasetInput <- function(addIdFlag = FALSE){
            m <- NULL
            if (choicecounter$qc == 0 ) {
                mergedCompDat <- NULL
                if (input$dataset == "comparisons")
                    mergedCompDat <- mergedComp()
                m <- getSelectedDatasetInput(filt_data(), 
                    selected$data$getSelected(), getMostVaried(),
                    mergedCompDat, input)
            }
            else
                m <- getSelectedDatasetInput(init_data(), 
                    getMostVaried = getMostVaried(),
                    input = input)
            if(addIdFlag)
                m <- addID(m)
            m
        }
        output$downloadData <- downloadHandler(filename = function() {
            paste(input$dataset, "csv", sep = ".")
        }, content = function(file) {
            dat <- getDataForTables(input, init_data(),
                                    filt_data(), selected,
                                    getMostVaried(),  isolate(mergedComp()))
            dat2 <- removeCols(c("x", "y","Legend", "Size"), dat[[1]])
            if(!("ID" %in% names(dat2)))
                dat2 <- addID(dat2)
            write.table(dat2, file, sep = ",", row.names = FALSE)
        })

        output$downloadPlot <- downloadHandler(filename = function() {
            paste(input$qcplot, ".pdf", sep = "")
        }, content = function(file) {
            if (choicecounter$qc == 0)
                saveQCPlot(file, input, datasetInput(), 
                    cols(), conds(), inputQCPlot())
            else
                saveQCPlot(file, input, datasetInput(),
                    inputQCPlot = inputQCPlot())
        })

        output$downloadGOPlot <- downloadHandler(filename = function() {
            paste(input$goplot, ".pdf", sep = "")
        }, content = function(file) {
            pdf(file)
            print( inputGOstart()$p )
            dev.off()
        })
    },
    err=function(errorCondition) {
        cat("in err handler")
        message(errorCondition)
    },
    warn=function(warningCondition) {
        cat("in warn handler")
        message(warningCondition)
    })
}
