# SPACEGERM shiny app user interface script
# Copyright (C) 2017-2018  Marcel Schilling
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#######################
# general information #
#######################

# file:         ui.R
# author(s):    Marcel Schilling <marcel.schilling@mdc-berlin.de>
# created:      2017-02-21
# last update:  2018-08-16
# license:      GNU Affero General Public License Version 3 (GNU AGPL v3)
# purpose:      define front end for SPACEGERM shiny app


######################################
# change log (reverse chronological) #
######################################

# 2018-08-16: added location measure input panel
# 2018-05-17: re-ordered tabs for publication
#             added app subtitle
#             replaced require by library
# 2018-05-16: renamed app for publication
# 2018-04-23: added 3D model plot options input panel & expression range inputs
# 2018-04-16: renamed y-axis limits inputs to expression range inputs
# 2018-04-13: relabeled 3D model gene input panel
#             removed sample shift input panel
#             removed sample description input panel for heatmap
#             added 3D model span input panel
#             added 3D model gene name & genotype input panels
#             added 3D model tab & plot output panel
# 2018-04-09: removed sample stretches input panel
# 2018-04-03: added smoothing point count input panel parameters
#             added smoothing span input panel parameters
# 2018-03-21: added abundance unit input panel
# 2017-10-23: added isoform level input panel
# 2017-10-17: replaced plotlyOutput by (new) iheatmaprOutput
# 2017-05-29: added dynamically generated sample stretches input panel
# 2017-05-23: added minimum peak CPM input panel
# 2017-05-22: added manual y-axis limits plot option & corresponding minimum/maximum input panels
# 2017-05-17: replaced heatmap options input panel by abundance measure input panel
#             added row normalization input panel
# 2017-04-19: added distance metric input panel
# 2017-04-18: added dynamically generated gene type input panel
# 2017-04-11: added gene list file import panel
# 2017-04-10: added gene table XLSX export button
# 2017-04-06: added gene table output
# 2017-04-05: fixed code indentation
#             added heatmap options input panel
#             added gene cluster count input panel
# 2017-03-29: added heatmap tab panel (incl. sample description & genotype input & heatmap output
#             panels)
# 2017-03-19: added plot columns count input panel
#             fixed copy-and-paste error in comment
# 2017-02-24: added license comment
#             added dynamically generated sample shifts input panel
# 2017-02-23: added plot options input panel
#             added sample names input panel
#             replaced gene names output panel by profile plot output panel
# 2017-02-21: added gene names input/output panels
#             initial version (app title only)


#############
# libraries #
#############

# get pipe operators
library(magrittr)
library(markdown)
library(iheatmapr)
library(plotly)


##############
# parameters #
##############

# load parameter definitions
source("params.R")


########
# data #
########

# load input data
source("data.R")


########################
# shiny user interface #
########################

# generate single page user interface with title panel

# generate title panel
titlePanel(

  # set app title
  title = params$app.title,
  windowTitle = params$app.title

  # end title panel definition
  ) %>%

# embed title panel in page
fluidPage(

  HTML("<!-- if in doubt: http://isotropic.org/papers/chicken.pdf -->"),
  ., # Make sure the above comment ends up on line 42 of the HTML. ;-)
  HTML(markdownToHTML(text = params$app.subtitle.md,
                      fragment.only = TRUE)),

  # add gene name input panel
  textInput(

    # name gene names input
    inputId="gene.names"

    # label gene names input panel
    ,label=params$gene.names.input.label %>%

      # make label 3rd level header
      h3

    # set default input gene names
    ,value=params$gene.names.input.default

    # set gene names input placeholder
    ,placeholder=params$gene.names.input.placeholder

    # end gene names input panel definition
    ) %>%

  # embed gene name input panel in sidebar
  sidebarPanel(

    # add isoform level input panel
    radioButtons(

      # name isoform level input
      inputId="isoform.level"

      # label isoform level input panel
      ,label=params$isoform.level.input.label %>%

        # make label 3rd level header
        h3

      # set choices for isoform level input panel
      ,choices=params$isoform.level.input.choices

      # set default selection for isoform level input panel
      ,selected=params$isoform.level.input.default

      # end isoform level input panel definition
      ),

      selectInput(inputId="abundance.unit",
                  label=h3(params$abundance.unit.input.label),
                  choices=params$abundance.unit.input.choices,
                  selected=params$abundance.unit.input.default),
      selectInput(inputId = "location.measure",
                  label = h3(params$location.measure.input.label),
                  choices = params$location.measure.input.choices,
                  selected = params$location.measure.input.default)

    # add sample names input panel
    ,checkboxGroupInput(

      # name sample names input
      inputId="sample.names"

      # label gene names input panel
      ,label=params$sample.names.input.label %>%

        # make label 3rd level header
        h3

      # set choices for sample names input panel
      ,choices=input.data$sample.names

      # set default selection for sample names input panel
      ,selected=params$sample.names.input.default

      # end sample names input panel definition
      )

    # add plot options input panel
    ,checkboxGroupInput(

      # name plot options input
      inputId="plot.options"

      # label plot options input panel
      ,label=params$plot.options.input.label %>%

        # make label 3rd level header
        h3

      # set choices for plot options input panel
      ,choices=params$plot.options

      # set default selection for plot options input panel
      ,selected=params$plot.options.input.default

      # end plot options input panel definition
      ),

    uiOutput(outputId = "manual.exprmin.input"),
    uiOutput(outputId = "manual.exprmax.input"),

    # add plot columns count input panel
    numericInput(

      # name plot columns count input
      inputId="ncols.plot"

      # label plot columns count input panel
      ,label=params$ncols.plot.input.label %>%

        # make label 3rd level header
        h3

      # set minimal value for plot columns count input panel
      ,min=params$ncols.plot.input.min

      # set default value for plot columns count input panel
      ,value=params$ncols.plot.input.default

      # end plot columns count input panel definition
      ),

    numericInput(inputId = "smoothing.n",
                 label = h3(params$smoothing.n.input.label),
                 min = params$smoothing.n.input.min,
                 value = params$smoothing.n.input.default),
    numericInput(inputId = "smoothing.span",
                 label = h3(params$smoothing.span.input.label),
                 min = params$smoothing.span.input.min,
                 max = params$smoothing.span.input.max,
                 value = params$smoothing.span.input.default)) %>%

  # initialize side bar layout
  sidebarLayout(

    # generate gene names output panel
    plotOutput(

      # name gene names output
      outputId="profile.plot"
      ) %>%

    # embed gene names output panel in main panel
    mainPanel

    # end layout definition
    ) %>%

  # embed gene profiles page into tab panel
  tabPanel(

    # label gene profiles tab panel
    title=params$gene.profiles.tab.title

    # end gene profiles tab panel definition
    ) %>%

  # embed gene profiles tab panel in tabset panel
  tabsetPanel(

    tabPanel(
      title = params$model3d.tab.title,
      sidebarLayout(
        sidebarPanel(uiOutput(outputId = "genotype3d.input"),
                     selectizeInput(inputId = "gene3d",
                                    label = h3(params$gene3d.input.label),
                                    choices  = NULL),
                     checkboxGroupInput(inputId = "plot.options3d",
                                        label = h3(params$plot.options.input.label),
                                        choices = params$plot.options3d,
                                        selected = params$plot.options3d.input.default),
                     uiOutput(outputId = "manual.exprmin3d.input"),
                     uiOutput(outputId = "manual.exprmax3d.input"),
                     numericInput(inputId = "span3d",
                                  label = h3(params$smoothing.span.input.label),
                                  min = params$smoothing.span.input.min,
                                  max = params$smoothing.span.input.max,
                                  value = params$smoothing.span.input.default)),
        mainPanel(plotlyOutput(outputId = "model3d")))),

    # add heatmap tab panel
    tabPanel(

      # label heatmap tab panel
      title=params$heatmap.tab.title

      # add sidebar layout to heatmap tab panel
      ,sidebarLayout(

        # define sidebar panel for heatmap tab panel
        sidebarPanel(

          # add dynamically generated genotype input panel
          uiOutput(

            # name genotype input panel output
            outputId="genotype.input"

            # end genotype input panel definition
            )

          # add dynamically generated gene type input panel
          ,uiOutput(

            # name gene type input panel output
            outputId="gene.type.input"

            # end gene type input panel definition
            )

          # add gene cluster count input panel
          ,numericInput(

            # name gene cluster count input
            inputId="nclust.genes"

            # label gene cluster count input panel
            ,label=params$nclust.genes.input.label %>%

              # make label 3rd level header
              h3

            # set minimal value for gene cluster count input panel
            ,min=params$nclust.genes.input.min

            # set default value for gene cluster count input panel
            ,value=params$nclust.genes.input.default

            # end plot columns count input panel definition
            )

          # add abundance measure input panel
          ,selectInput(

            # name abundance measure input
            inputId="abundance.measure"

            # label abundance measure input panel
            ,label=params$abundance.measure.input.label %>%

              # make label 3rd level header
              h3

            # set choices for abundance measure input panel
            ,choices=params$abundance.measure.input.choices

            # set default selection for abundance measure input panel
            ,selected=params$abundance.measure.input.default

            # end abundance measure input panel definition
            )

          # add row normalization input panel
          ,selectInput(

            # name row normalization input
            inputId="row.normalization"

            # label row normalization input panel
            ,label=params$row.normalization.input.label %>%

              # make label 3rd level header
              h3

            # set choices for row normalization input panel
            ,choices=params$row.normalization.input.choices

            # set default selection for row normalization input panel
            ,selected=params$row.normalization.input.default

            # end row normalization input panel definition
            )

          # add distance metric input panel
          ,selectInput(

            # name distance metric input
            inputId="distance.metric"

            # label distance metric input panel
            ,label=params$distance.metric.input.label %>%

              # make label 3rd level header
              h3

            # set choices for distance metric input panel
            ,choices=params$distance.metric.input.choices

            # set default selection for sdistance metric input panel
            ,selected=params$distance.metric.input.default

            # end distance metric input panel definition
            )

          # add gene list file import panel
          ,fileInput(

            # name gene list file input
            inputId="gene.list.file"

            # label gene list file import panel
            ,label=params$gene.list.import.label %>%

              # make label 3rd level header
              h3

            # set accepted MIME types for gene list file import
            ,accept=params$gene.list.file.import.mime.accept

            # label gene list file import button
            ,buttonLabel=params$gene.list.file.import.button.label

            # set gene list file import placeholder
            ,placeholder=params$gene.list.file.import.placeholder

            # end gene list file import
            )

          # add minimum peak CPM input panel
          ,numericInput(

            # name minimum peak CPM input
            inputId="min.cpm.max"

            # label minimum peak CPM input panel
            ,label=params$min.cpm.max.input.label %>%

              # make label 3rd level header
              h3

            # set minimal value for minimum peak CPM input panel
            ,min=params$min.cpm.max.input.min

            # set maximal value for minimum peak CPM input panel
            ,max=params$min.cpm.max.input.max

            # set default value for minimum peak CPM input panel
            ,value=params$min.cpm.max.input.default

            # end plot columns count input panel definition
            )

          # end sidebar panel definition for heatmap tab panel
          )

        # define main panel for heatmap tab panel
        ,mainPanel(

          # generate heatmap output panel
          iheatmaprOutput(

            # name heatmaps output
            outputId="heatmap"

            # end heatmap output panel definition
            )

          # generate gene table output panel
          ,dataTableOutput(

            # name gene table output
            outputId="gene.table"

            # end gene table output panel definition
            )

          # generate gene table XLSX export button
          ,downloadButton(

            # name gene table XLSX export button
            outputId='gene.table.xlsx.export.button'

            # label gene table XLSX export button
            ,label=params$gene.table.xlsx.export.button.label

            # end gene table XLSX export button definition
            )

          # end main panel definition for heatmap tab panel
          )

        # end heatmap tab panel sidebar layout definition
        )

      # end heatmap tab panel definition
      ), .)) %>%

# initialize user interface
shinyUI
