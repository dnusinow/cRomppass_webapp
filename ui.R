library("shiny")

fluidPage(
    sidebarLayout(
        sidebarPanel(
            imageOutput("comppassLogo", height = "115px", width = "361px"),
            fileInput("experimentUploader", "Experiments"),
            fileInput("statsUploader", "External Stats"),
            textInput("normFactor", "Normalization Factor", value = "0.98"),
            div(id="input_instructions_div",
                
                h3("Input Instructions"),
                downloadButton("download.sample.input", "Download Sample Input"),
                br(),
                p("The input file must be a tab-delimited text file with the following five columns:"),
                withTags(
                    ol(li("Experiment ID"),
                       li("Replicate"),
                       li("Bait"),
                       li("Prey"),
                       li("Spectral Count")
                       )
                ),
                
                h4("Input Field Details"),
                withTags(dl(
                    dt(dfn("Experiment ID"),
                       dd("A unique ID for a given AP-MS experiment. Replicates will all share the same Experiment ID")
                       ),
                    dt(dfn("Replicate"),
                       dd("An ID for the replicate in a given experiment")
                       ),
                    dt(dfn("Experiment Type"),
                       dd("This field is ignored and is allowed for backward compatability with the Spotlite website.")
                       ),
                    dt(dfn("Bait"),
                       dd("The ID for the bait used in the experiment. This is usually the gene symbol.")
                       ),
                    dt(dfn("Prey"),
                       dd("The ID for the prey found in the experiment. This is also usually the gene symbol. This ID type should match that used for the Bait.")
                       ),
                    dt(dfn("Spectral Count"),
                       dd("The number of spectra found per bait-prey pair in an experimental replicate.")
                       )
                )),

                h3("Output Description"),
                withTags(dl(
                    dt(dfn("Experiment.ID"),
                       dd("The unique ID for a given AP-MS experiment provided by the input")
                       ),
                    dt(dfn("Bait"),
                       dd("The unique ID for the bait in the AP-MS experiment provided by the input")
                       ),
                    dt(dfn("Prey"),
                       dd("The unique ID for the prey in the AP-MS experiment provided by the input")
                       ),
                    dt(dfn("AvePSM"),
                       dd("The mean spectral counts across all the replicates in an experiment provided by the input")
                       ),
                    dt(dfn("Z"),
                       dd("The Z-Score for the prey given all other experiments provided.")
                       ),
                    dt(dfn("WD"),
                       dd("The WD score defined by Sowa et al.")
                       ),
                    dt(dfn("Entropy"),
                       dd("The Shannon Entropy for each spectral count provided by the input")
                       )
                ))
                )
        ),
        mainPanel(uiOutput("download.scores.button"),
                  dataTableOutput("scores"))
    ),
    title = "CompPASS"
)
