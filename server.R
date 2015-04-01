require("shiny")
require("cRomppass")

function(input, output) {
    
    input.experiment <- reactive({
        indf <- unique(input$experimentUploader)
        if(is.null(indf)) {
            return(NULL)
        }

        validate(need(nrow(indf) == 1,
                      "Only one uploaded file permitted"))
        validate(need(indf[1, "size"] < 5000000,
                      "The uploaded file may not be more than 5 megabytes in size"))

        ## Make sure all the headers are there
        header <- scan(indf[1, "datapath"], what = character(), nlines = 1, sep = "\t", quiet = TRUE)
        
        validate(need(all(c("Experiment ID", "Replicate", "Bait", "Prey", "Spectral Count") %in%
                          header) |
                      all(c("Experiment.ID", "Replicate", "Bait", "Prey", "Spectral.Count") %in%
                          header),
                      "Missing one or more of the required column names in the input"))

        ## Read in the file and validate that the column classes are sane
        ret <- read.delim(indf[1, "datapath"], stringsAsFactors = FALSE)

        validate(need(is.character(ret$Experiment.ID) | is.numeric(ret$Experiment.ID),
                      "The Experiment ID column must be a number or character string"))
        validate(need(is.character(ret$Replicate) | is.integer(ret$Replicate),
                      "The Replicate column must be an integer or character string"))
        validate(need(is.character(ret$Bait),
                      "The Bait column must be a character string"))
        validate(need(is.character(ret$Prey),
                      "The Prey column must be a character string"))
        validate(need(is.integer(ret$Spectral.Count),
                      "The Spectral Count column must be an integer"))

        return(ret)
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
        filename <- normalizePath(file.path("./img", "CompPASS_reflect_logo_smaller.png"))
        list(src = filename, alt = "CompPASS Logo")
    }, deleteFile = FALSE)

}
