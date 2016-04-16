## The Broad Institute
## SOFTWARE COPYRIGHT NOTICE AGREEMENT
## This software and its documentation are copyright (2016) by the
## Broad Institute/Massachusetts Institute of Technology. All rights are
## reserved.
##
## This software is supplied without any warranty or guaranteed support
## whatsoever. Neither the Broad Institute nor MIT can be responsible for its
## use, misuse, or functionality.

# This file contains the core "computational method" for this module, in this
# case just incrementing the values in the input GCT matrix.

# Assumes GenePattern's common.R has been sourced (for functions to read/write GCT)
# and that necessary packages have been loaded.
GP.tutorial.module.method <- function(gct, print.debug.message, extra.debug.message, increment.value, output.file) {

   # Print a debug message if requested.
   if (print.debug.message) {
      write("Here is a debug message, as requested", stdout())
      # Also print an extra message, if available
      if (! is.null(extra.debug.message)) {
         write(extra.debug.message, stdout())
      }

      write("\n", stdout())
   }

   # Increment the matrix.
   gct$data <- gct$data + increment.value

   # Write the output GCT into the current working directory as required by GenePattern.      
   write.gct(gct, file.path(getwd(), output.file))
}
