#getMethodDetails
#'
#' get the detail boxes after DE method selected 
#'
#' @param num, panel that is going to be shown
#' @param input, user input
#' @examples
#'     x <- getMethodDetails()
#'
#' @export
#'
getMethodDetails <- function(num = 0, input = NULL) {
    if (num > 0)
        a <- list(
            conditionalPanel(
               (condition <- paste0("input.demethod",num," == 'DESeq2'")),
                   getSelectInputBox("fitType", "Fit Type", num, 
                   c("parametric", "local", "mean"), 
                   selectedInput("testType", num, "parametric", input)),
               column(2, textInput(paste0("betaPrior", num), "Beta Prior", 
                    value = isolate(selectedInput(
                    "betaPrior", num, "0", input)) )),
               getSelectInputBox("testType", "Test Type", num, 
                    c("Wald", "LRT"),  
                    selectedInput("testType", num, "Wald", input))),
            conditionalPanel(
               (condition <- paste0("input.demethod",num," == 'EdgeR'")),
                   getSelectInputBox("edgeR_normfact", "Normalization", num, 
                       c("TMM","RLE","upperquartile","none"), 
                       selectedInput("edgeR_normfact", num, "TMM", input)),
               column(2,textInput(paste0("dispersion", num), "Dispersion", 
                        value = isolate(selectedInput("dispersion", 
                        num, "0", input) ))),
               getSelectInputBox("edgeR_testType", "Test Type", num, 
                       c("exactTest", "glmLRT"), 
                       selectedInput("edgeR_testType", num, "exactTest", input))),
            conditionalPanel(
               (condition <- paste0("input.demethod",num," ==  'Limma'")),
                   getSelectInputBox("limma_normfact", "Normalization", num, 
                       c("TMM","RLE","upperquartile","none"), 
                       selectedInput("limma_normfact", num, "TMM", input)),
                   getSelectInputBox("limma_fitType", "Fit Type", num,
                       c("ls", "robust"), 
                           selectedInput("limma_fitType", num, "ls", input)),
                   getSelectInputBox("normBetween", "Norm. Bet. Arrays", num,
                       c("none", "scale", "quantile", "cyclicloess",
                           "Aquantile", "Gquantile", "Rquantile","Tquantile"),
                           selectedInput("normBetween", num, "none", input))),
            column(2,textInput(paste0("rowsumfilter", num), "row.sum filter", 
                value = isolate(selectedInput("rowsumfilter", num,
                    "10", input) ))),
            br())

}

#' getConditionSelector
#'
#' Selects user input conditions to run in DESeq.
#'
#' @param num, panel that is going to be shown
#' @param choices, sample list
#' @param selected, selected smaple list
#' @examples
#'     x <- getConditionSelector()
#'
#' @export
#'
getConditionSelector<- function(num=0, choices = NULL, selected = NULL) {
    if (!is.null(choices))
        a <- list(column(6, selectInput(paste0("condition", num),
            label = paste0("Condition ", num),
            choices = choices, multiple = TRUE,
            selected = selected)))
}

#' selectedInput
#'
#' Selects user input conditions to run in DESeq.
#'
#' @param id, input id
#' @param num, panel that is going to be shown
#' @param default, default text
#' @param input, input params
#' @examples
#'     x <- selectedInput()
#'
#' @export
#'
selectedInput <- function(id = NULL, num = 0, default = NULL, 
    input = NULL) {
    if (is.null(id)) return(NULL)
    m <- NULL
    if (is.null(input[[paste0(id, num)]]))
        m <- default
    else
        m <- input[[paste0(id, num)]]
    m
}

#' getSelectInputBox
#'
#' Selects user input conditions to run in DESeq.
#'
#' @param id, input id
#' @param name, label of the box
#' @param num, panel that is going to be shown
#' @param choices, sample list
#' @param selected, selected smaple list
#' @examples
#'     x <- getSelectInputBox()
#'
#' @export
#'
getSelectInputBox <- function(id = NULL, name = NULL, 
    num = 0, choices = NULL, selected = NULL) {
    if (is.null(id)) return(NULL)
    if (!is.null(choices))
        a <- list(column(2, selectInput(paste0(id, num),
                label = name,
                choices = choices, multiple = FALSE,
                selected = selected)))
}


#' selectConditions
#'
#' Selects user input conditions, multiple if present, to be
#' used in DESeq.
#'
#' @param Dataset, used dataset 
#' @param choicecounter, total number of comparisons
#' @param input, input params
#' @note \code{selectConditions}
#' @return the panel for go plots;
#'
#' @examples
#'     x<- selectConditions()
#'
#' @export
#'
selectConditions<-function(Dataset = NULL,
    choicecounter, input = NULL) {
    if (is.null(Dataset)) return(NULL)
    selectedSamples <- function(num){
        if (is.null(input[[paste0("condition", num)]]))
            getSampleNames(input$samples, num %% 2 )
        else
            input[[paste0("condition", num)]]
    }
    nc <- choicecounter$nc
    if (nc >= 0) {
        allsamples <- getSampleNames( input$samples, "all" )
        lapply(seq_len(nc), function(i) {
            selected1 <- selectedSamples(2 * i - 1)
            selected2 <- selectedSamples( 2 * i )
            list(column(12, getConditionSelector((2 * i - 1), 
                allsamples, selected1),
            getConditionSelector((2 * i), 
                allsamples, selected2)),
            column(12, 
            column(1, helpText(" ")),
            getSelectInputBox("demethod", "DE Method", i, 
                c("DESeq2", "EdgeR", "Limma"), selectedInput("demethod", i, "DESeq2", input)),
            getMethodDetails(i, input)))
    })
    }
}
