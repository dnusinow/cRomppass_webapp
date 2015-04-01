require("shiny")
require("cRomppass")

function(input, output) {
    
    input.experiment <- reactive({
        indf <- input$experimentUploader
        if(is.null(indf)) {
            return(NULL)
        }

        read.delim(indf[1, "datapath"], stringsAsFactors = FALSE)
    })

    input.stats <- reactive({
        indf <- input$statsUploader
        if(is.null(indf)) {
            return(NULL)
        }

        read.delim(indf[1, "datapath"], stringsAsFactors = FALSE)
    })
    
    current.scores <- reactive({
        experiment <- input.experiment()
        stats <- input.stats()
        if(is.null(experiment)) {
            return(NULL)
        }
        comppass(experiment, stats, norm.factor = as.numeric(input$normFactor))
    })
    
    
    output$scores <- renderDataTable({
        current.scores()
    })

    output$download.scores.button <- renderUI({
        if(!is.null(current.scores())) {
            return(downloadButton("download.scores", "Download"))
        }
    })

    output$download.scores <- downloadHandler(
        filename = function() {
            if(is.null(current.scores())) {
                return("#")
            }
            "comppass_scores.tsv"
        },
        content = function(file) {
            if(is.null(current.scores())) {
                return(NULL)
            }
            write.table(current.scores(), file,
                        sep = "\t", row.names = FALSE)
        }
    )

    output$download.sample.input <- downloadHandler(
        filename = function() { "comppass_test_data.tsv" },
        content = function(file) {
            data(comppass_test_data)
            write.table(comppass.test.data, file,
                        sep = "\t", row.names = FALSE)
        }
    )

    output$comppassLogo <- renderImage({
        filename <- normalizePath(system.file("extdata", "CompPASS_reflect_logo_smaller.png",
                                              package = "cRomppass"))
        list(src = filename, alt = "CompPASS Logo")
    }, deleteFile = FALSE)

}