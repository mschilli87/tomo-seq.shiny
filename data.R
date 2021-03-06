# SPACEGERM shiny app data loading script
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

# file:         data.R
# author(s):    Marcel Schilling <marcel.schilling@mdc-berlin.de>
# created:      2017-02-23
# last update:  2018-05-31
# license:      GNU Affero General Public License Version 3 (GNU AGPL v3)
# purpose:      load input data for SPACEGERM shiny app


######################################
# change log (reverse chronological) #
######################################

# 2018-05-31: replaced gene profiles RDS input by SQLite database
#             replaced slice data RDS input by SQLite database
# 2018-05-30: removed slice width calculation (provided in input)
#             replaced shift/stretch RDS input by SQLite database
# 2018-05-17: replaced require by library
# 2018-05-16: renamed app for publication
# 2018-04-13: added extraction of gene names
# 2018-04-04: added default shift/stretch file loading and formatting
# 2018-03-20: added slice width calculation
#             added gonad model loading
# 2017-04-18: fixed changelog comments (broken since 2017-03-29/baea8e9)
#             added gene type extraction
#             fixed copy/paste-error in comment
# 2017-04-13: replaced unique by distinct
# 2017-04-12: added missing changelog entry
#             made dplyr an explicit dependency
#             switched to tidy gene profile input data
# 2017-03-29: added gene profile loading (incl. sample descriptions & genotypes extraction)
# 2017-03-28: added missing explicit magrittr loading
# 2017-02-24: added license comment
# 2017-02-23: added sample names extraction
#             initial version (double-sourcing check & slice data loading)


#############
# libraries #
#############

# get dlply
library(plyr)

# get %>% & distinct
# Note: dplyr must be loaded after plyr!
library(dplyr)
library(magrittr)


##############
# parameters #
##############

# load parameter definitions
source("params.R")


########
# data #
########

# ensure input data are not loaded already
if(!exists("input.data"))

  # begin data loading
  {

    data.db <- src_sqlite(params$data.sqlite)

    # load input data
    input.data <- list(slice.data = tbl(data.db, "slice.data"),
                       shift.stretch = tbl(data.db, "shift.stretch"),
                       gene.profiles = tbl(data.db, "gene.profiles"),
                       gonad.model = readRDS(params$gonad.model.file))

    # get sample names
    input.data$sample.names <-
      input.data$slice.data %>%
      distinct(sample.name) %>%
      collect %>%
      unlist %>%
      unname

    # get default sample shifts
    input.data$sample.shift.defaults <-
      data_frame(sample.name = input.data$sample.names) %>%
      left_join(input.data$shift.stretch, copy = TRUE) %>%
      mutate(
        shift.default = ifelse(is.na(shift.default),
                               params$sample.shifts.input.default,
                               shift.default),
        shift.default = ifelse(shift.default < params$sample.shifts.input.min,
                               params$sample.shifts.input.min, shift.default),
        shift.default = ifelse(shift.default > params$sample.shifts.input.max,
                               params$sample.shifts.input.max,
                               shift.default)) %$%
        setNames(shift.default, sample.name)

    # get default sample stretches
    input.data$sample.stretch.defaults <-
      data_frame(sample.name = input.data$sample.names) %>%
      left_join(input.data$shift.stretch, copy = TRUE) %>%
      mutate(stretch.default = ifelse(is.na(stretch.default),
                                params$sample.stretches.input.default,
                                stretch.default),
             stretch.default =
               ifelse(stretch.default < params$sample.stretches.input.min,
                      params$sample.stretches.input.min, stretch.default),
             stretch.default =
               ifelse(stretch.default > params$sample.stretches.input.max,
                      params$sample.stretches.input.max, stretch.default)) %$%
      setNames(stretch.default, sample.name)

    # get sample descriptions
    input.data$sample.descriptions <-
      input.data$gene.profiles %>%
      distinct(sample.description) %>%
      collect %>%
      unlist %>%
      unname

    # get genotypes per sample description
    input.data$genotypes <-
      input.data$gene.profiles %>%
      distinct(sample.description, genotype) %>%
      collect %>%
      dlply("sample.description", with, unique(genotype))

    # get gene types per sample description & genotype
    input.data$gene.types <-
      input.data$gene.profiles %>%
      distinct(sample.description, genotype, gene.type) %>%
      collect %>%
      dlply("sample.description", distinct, genotype, gene.type) %>%
      llply(dlply, "genotype", with, unique(gene.type))

  input.data$genes.names <-
    input.data$slice.data %>%
    distinct(gene.name) %>%
    collect %>%
    unlist %>%
    unname}
