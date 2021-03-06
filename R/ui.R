#' deUI
#'
#' Creates a shinyUI to be able to run DEBrowser interactively.
#'
#' @note \code{deUI}
#' @return the panel for main plots;
#'
#' @examples
#'     x<-deUI()
#'
#' @export
#'

deUI <- function() {
    heatmapJScode <- 
        "shinyjs.getNames = function(){
        var count = document.getElementsByClassName('tick').length; 
        var start = 0;  
        while(document.getElementsByClassName('tick')[start].getElementsByTagName('line')[0].getAttribute('x2') == 0){
        start += 1;
        }  
        var out = ''; 
        for (i = start; i < count; i++) 
        { 
        if('opacity: 1;' == document.getElementsByClassName('tick')[i].getAttribute('style')){ 
        out += document.getElementsByClassName('tick')[i].getElementsByTagName('text')[0].innerHTML + ',';
        }
        } 
        //document.getElementById('genenames').innerHTML = out;
        Shiny.onInputChange('genenames', out);
    };"
    addResourcePath(prefix = "www", directoryPath =
        system.file("extdata", "www", 
        package = "debrowser"))
    shinyUI(fluidPage(
    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(text = heatmapJScode, functions = c("getNames")),
    shinyjs::inlineCSS("
        #loading-debrowser {
        position: absolute;
        background: #000000;
        opacity: 0.9;
        z-index: 100;
        left: 0;
        right: 0;
        height: 100%;
        text-align: center;
        color: #EFEFEF;
}"),
    # Loading message
    tags$div(h4("Loading DEBrowser"), id = "loading-debrowser",
        tags$img(src = "www/images/initial_loading.gif")),
    uiOutput("logo"),
    uiOutput("programtitle"),
    textOutput("text"),
    sidebarLayout(
        sidebarPanel(
        uiOutput("loading"),
        width = 2,
        uiOutput("initialmenu"),
        conditionalPanel(condition = "(output.dataready)",
            uiOutput("leftMenu")),
        conditionalPanel(condition = "(output.dataready)",
            uiOutput("downloadSection")),
        conditionalPanel(condition = "(output.dataready)",
            uiOutput('cutoffSelection'))
    ),
    mainPanel(
    tags$head(
    tags$style(type = "text/css",
                 "#methodtabs.nav-tabs {font-size: 14px} ")),
    tabsetPanel(id = "methodtabs", type = "tabs",
                tabPanel(title = "Data Prep", value = "panel0", id="panel0",
                         uiOutput("preppanel")),
                tabPanel(title = "Main Plots", value = "panel1", id="panel1",
                         uiOutput("mainmsgs"),
                         conditionalPanel(condition = "input.demo || 
                             output.dataready", uiOutput("mainpanel"))),
                tabPanel(title = "QC Plots", value = "panel2", id="panel2",
                         uiOutput("qcpanel")),
                tabPanel(title = "GO Term", value = "panel3", id="panel3",
                         uiOutput("gopanel")),
                tabPanel(title = "Tables", value = "panel4", id="panel4",
                         DT::dataTableOutput("tables")))
        ))
    ))
}


