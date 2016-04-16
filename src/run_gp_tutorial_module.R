## The Broad Institute
## SOFTWARE COPYRIGHT NOTICE AGREEMENT
## This software and its documentation are copyright (2016) by the
## Broad Institute/Massachusetts Institute of Technology. All rights are
## reserved.
##
## This software is supplied without any warranty or guaranteed support
## whatsoever. Neither the Broad Institute nor MIT can be responsible for its
## use, misuse, or functionality.

# This file contains the code to interface with GenePattern; its responsibility
# is mostly to set up the R computational environment, receive and process the
# arguments from the command line, and then call the core computational method 
# passing along these values.

# Load any packages used to in our code to interface with GenePattern.
# Note the use of suppressMessages and suppressWarnings here.  The package
# loading process is often noisy on stderr, which will (by default) cause
# GenePattern to flag the job as failing even when nothing went wrong. 
suppressMessages(suppressWarnings(library(getopt)))
suppressMessages(suppressWarnings(library(optparse)))

# We don't actually need either of the next two packages; they are included
# here for illustration only.
suppressMessages(suppressWarnings(library(limma)))
suppressMessages(suppressWarnings(library(edgeR)))

# Print the sessionInfo so that there is a listing of loaded packages, 
# the current version of R, and other environmental information in our
# stdout file.  This can be useful for reproducibility, troubleshooting
# and comparing between runs.
sessionInfo()

# Get the command line arguments.  We'll process these with optparse.
# https://cran.r-project.org/web/packages/optparse/index.html
arguments <- commandArgs(trailingOnly=TRUE)

# Declare an option list for optparse to use in parsing the command line.
option_list <- list(
  # Note: it's not necessary for the names to match here, it's just a convention
  # to keep things consistent.
  make_option("--libdir", dest="libdir"),
  make_option("--input.file", dest="input.file"),
  make_option("--increment.value", dest="increment.value", type="numeric", default=10),
  make_option("--print.debug.message", dest="print.debug.message", type="logical"),
  make_option("--extra.debug.message", dest="extra.debug.message", type="character", default=NULL),
  make_option("--output.file", dest="output.file")
  )

# Parse the command line arguments with the option list, printing the result
# to give a record as with sessionInfo.
opt <- parse_args(OptionParser(option_list=option_list), positional_arguments=TRUE, args=arguments)
print(opt)
opts <- opt$options

# Load some common GP utility code for handling GCT files and so on.  This is included
# with the module and so it will be found in the same location as this script (libdir).
libdir <- opts$libdir
source(file.path(libdir, "common.R"))

# Load the core method code.  This keeps it separate from the code to interface with GP
# so that it can be worked on separately outside of GP (in an R session, for example).
# This is obviously not necessary with such a simple calculation; again, it's just done
# for illustrative purposes.
source(file.path(libdir, "gp_tutorial_module.R"))

# Process the parameters.  
# Note that since extra.debug.message is optional, we must be prepared to receive no value
# Also check for blank values since these are ignored.
if (is.null(opts$extra.debug.message) || grepl("^[[:space:]]*$", opts$extra.debug.message)) {
   extra.debug.message <- NULL
} else {
   extra.debug.message <- opts$extra.debug.message
}

# Optparse will validate increment.value and convert it to a numeric value or give it the
# default value of 10 if missing.  We must check for NA however (and NULL, to be safe) as
# it will use that for non-numeric values.
if (is.null(opts$increment.value) || is.na(opts$increment.value)) {
   stop("Parameter increment.value must be numeric")
} else {
   increment.value <- opts$increment.value
}

# Due to the choices presented in the manifest, GP will *only* allow the strings "true" and "false" 
# here, so there's no need to convert it to a logical value; optparse will take care of that for us.

# Load the GCT input file.
gct <- read.gct(opts$input.file)

# Call the main computational method.
GP.tutorial.module.method(gct, opts$print.debug.message, extra.debug.message, 
                          increment.value, opts$output.file)

# Print the sessionInfo once more on the way out.  This is not strictly necessary
# but gives us another snapshot of the environment in final form as another point
# for troubleshooting in case anything has changed.
sessionInfo()