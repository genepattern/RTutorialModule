<style type="text/css">
  table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
  }
  th, td {
    padding: 8px;
  }
</style>

# David’s Crash Guide to developing R modules for GenePattern

## Introduction

This is a guide for R developers to get up-and-running with GenePattern module development in the spirit of getting out information as rapidly as possible.  I’m calling it a ‘crash guide’ both because of its rough format and because it focuses on how-to instructions while avoiding much of the details, reasons, and low-level issues behind those instructions.

## R modules and the command-line

As with all other GenePattern modules, running a module in R means executing a command-line call with the parameter values received from the GenePattern server.  This is not R’s interactive “read-eval-print loop” but rather the equivalent of a call from a UNIX shell like bash or Mac’s Terminal.app.  That’s not the exact mechanism but it’s a convenient way to think about it.  All GenePattern modules are executed this way and R modules are no different.

In the R world, the recommended way to build UNIX command-line programs is the Rscript utility and this is how GenePattern does it.  You set up the module manifest to pass your own file of R code (script) to the Rscript program along with any parameters from GenePattern; see our documentation elsewhere for details of specifying module params.

Let’s have a look at an example manifest command-line as found in this R Tutorial module.  For readability, this has been spread across multiple lines; this is signified with the trailing ‘\’ character, a convention we’ll continue throughout this guide:

    commandLine=<R3.1_Rscript> --no-save --quiet --slave --no-restore \
        <libdir>run_gp_tutorial_module.R --libdir\=<libdir> \
        --input.file\=<input.file> <increment.value> \
        --print.debug.message\=<print.debug.message>  <extra.debug.message> \
        --output.file\=<output.file>

What’s happening here?  We’re telling GenePattern to run the Rscript utility for a particular version of R (R-3.1 in this case) with some standard R flags, passing it a reference to the Tutorial module R code along with a number of parameters expected by that code.

Let’s dig into the parts of this commandLine so there’s no mystery about how this works.

<table>
  <tr>
    <td> &lt;R3.1_Rscript&gt; </td>
    <td> This is a command substitution telling GenePattern how to find and run the R-3.1 version of the Rscript command.  See the <a gref="http://www.broadinstitute.org/cancer/software/genepattern/administrators-guide">Admininstrators Guide</a> </td>
  </tr>
  <tr>
    <td> --no-save --quiet <br />
         --slave --no-restore </td>
    <td> Standard command-line options to tell R to run as quietly as possible and not to automatically save the session to or restore it from a saved image.  There are more details at the given link.  We are perhaps a bit redundant in our declarations here.
  </tr>
  <tr>
    <td> &lt;libdir&gt;run_gp_tutorial_module.R </td>
    <td> This is the GenePattern-standard way to reference a module support file, in this case the file of R code.  We’re just telling Rscript where to find the file. </td>
  </tr>
  <tr>
    <td class=".nobr"> --libdir\=&lt;libdir&gt; <br />
         --input.file\=&lt;input.file&gt; <br />
         --output.file\=&lt;output.file&gt;
    </td>
    <td> These substitutions are path references expected by the module’s R code.  GenePattern will prepare the corresponding file or directory and then pass a file system path reference to the R code as a string.  The embedded '\' before the equals-sign is highly recommended when working with the GP manifest format (based on the Java Properties format).
    </td>
  </tr>
  <tr>
    <td> &lt;increment.value&gt; <br />
        --print.debug.message\= <br />
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;print.debug.message&gt; <br />
         &lt;extra.debug.message&gt;
    </td>
    <td> Additional parameters of various types: numeric, boolean, and string values, respectively.  The &lt;increment.value&gt; and &lt;extra.debug.message&gt; are optional parameters; we'll discuss these later.
    </td>
  </tr>
</table>

We are passing a number of GenePattern parameters through to the R code.  Later on we’ll cover a possible approach to handling these, but for now the main point is that the responsibility for this is on the R code.  That’s exactly the way it would be with any other use of Rscript or indeed any other UNIX shell script.

## Why `<R3.1_Rscript>`? Why not `<R>` or `<Rscript>`?
We need to be precise when specifying which version of R to use.  A key point to recognize is that R makes no guarantees about backward or forward compatibility and in fact can easily vary between versions in behavior, computed results, and even runnability.  Thus, we need these substitutions to identify exactly which version of R should be used when executing the job.  Code written for R-2.0 may not behave identically under R-3.1 and might not even run at all.

Now with that said, we obviously do not tie you to R-3.1 only.  We have substitutions available for many versions of R, from R-2.0 up to the modern versions.  Moreover, you can always create your own substitutions as you please; these are just standard GenePattern command substitutions as defined in our Admin Guide.  Using the given terminology standard will make it more likely you’ll remain compatible and supported in the future, but you are of course free to do whatever you want.

As an important historical note, early versions of GenePattern and its modules did indeed use the <R> command substitution to reference the path to R on the computer, and some of these references remain.  This was introduced in earlier days of R when the philosophy around compatibility was perhaps not as clear: in R version terms, the <R> substitution corresponds to R-2.0, released circa 2004.

While you could hijack this substitution to stand in for R-3.1 or R-3.2 it is not recommended.  First, the behavior of any old modules using that substitution would be undefined under this new version of R.  Likewise, there are internal references to this within the GenePattern server code base and the corresponding behavior would again be undefined.  Second, we consider this substitution to be deprecated and may remove it in the future.  Third, and perhaps most practically, you as a module author are not being explicit about which version of R your code expects to use.  Such modules are not portable to other users and certainly not reproducible elsewhere.

The bottom line is that you should consider the substitution a historical curiosity and avoid it unless you need to run very old modules that rely on it.

## Basics of coding R for GenePattern
As we discussed earlier, the way GenePattern calls R is essentially identical to using  Rscript at the UNIX shell command line.  Your R code should expect and handle any command line arguments, parse and process them, and then call your underlying method code in the same way as it would do in the context of Rscript.

The following discussion will thus largely cover basic concepts of coding for the command line in R with only a few GenePattern-specific items.  If you find this too basic for your tastes you might wish to skip ahead.

## Simple command-line argument handling
Command line arguments are available to at run time via a standard R function call: 

    arguments <- commandArgs(trailingOnly=TRUE)

This is a core part of R (at least modern R) and will always be available to you.  You can consult the standard reference for more details, but in short this returns a character vector holding your command line arguments, which are the items listed after your R code file reference.  Note that Rscript assumes that you’ll be using `trailingArgs=TRUE` and is configured accordingly.

Having done this, any values passed to your R code are available - in order, starting at index 1 - within this arguments character vector.  This may suffice if your needs are very simple, for example if all of your parameters are required and will always be present on the command line.  A simple example of this is shown in the [Programmers Guide](http://www.broadinstitute.org/cancer/software/genepattern/programmers-guide#Using_Parameter_Flags).  We’ll discuss a more advanced alternative shortly.

## Using supporting scripts
I often structure my R code as a pair of files, one containing the method (e.g. statistical) code and another separate “wrapper” file meant to be called by Rscript that handles parameter processing and the like.  That allows me to work with the method code on its own in an R session without having to worry about the command line plumbing.

Remember that `<libdir>` reference on the manifest commandLine?  The wrapper script will use it to find any supporting scripts, data files, etc.  This is not a module parameter but instead is a standard GenePattern substitution that is always available; that is, it will never be empty or null.

    # Load a supporting script
    source(file.path(libdir, "gp_tutorial_module.R"))

## Loading R packages
Assuming that your GenePattern server and installation of R have been configured according to our updated guidelines, any packages in the GenePattern site library will be available to your R code at run time by the standard mechanisms.  That is, you can load these using the usual library() or require() calls.  We recommend the use of library() as it will immediately complain if the package is missing, but you are free to use your own preferences.

Declaration and installation of these packages for portability is covered in the [Programmers Guide](http://www.broadinstitute.org/cancer/software/genepattern/programmers-guide#Using_R_Packages) and in further detail in this module's README_PACKAGES.md file.

### Pitfall: R is noisy on stderr
As a general rule, GenePattern will consider a job as having failed if it produces any output on stderr.  In contrast, many components in the R ecosystem emit non-fatal warnings and even basic informational messages on stderr; while not noticeable in an R session, it becomes clear when code is run from Rscript.  These two approaches are obviously at odds.
Loading packages is common source of this noise.  Take this for example:

    > library(bit)
    Attaching package bit
    package:bit (c) 2008-2012 Jens Oehlschlaegel (GPL-2)
    creators: bit bitwhich
    coercion: as.logical as.integer as.bit as.bitwhich which
    operator: ! & | xor != ==
    querying: print length any all min max range sum summary
    bit access: length<- [ [<- [[ [[<-
    for more help type ?bit

    Attaching package: ‘bit’

    The following object is masked from ‘package:base’:

        xor

If this output isn’t important to your module, R provides a couple of ways to deal with it:

    suppressPackageStartupMessages(library(bit))
    # Or...
    suppressMessages(suppressWarnings(library(bit))

This comes up in many other places outside of package loading and that second form is useful for handling it in general, provided the extra output is not germane to your module’s behavior or results.

Alternatively, if the output is important or if you just want users to have access to it, you can instead use mechanisms like tryCatch() or withCallingHandlers() to wrap the noisy calls and then print the messages and warnings to stdout; see the R reference manual for details.

Finally, you can also configure your module so that GenePattern will not consider the presence of stderr output to signal an job error by adding the following lines to your manifest:

    job.error_status.stderr=false
    job.error_status.exit_value=true

With these settings, GenePattern expects a non-zero exit code to signal an error.  That's a good idea in any case.  You can use the `stop()` function to do this in known-error situations:

    stop(paste0("Error: invalid increment.value parameter value '", increment.value, "'"))

## More sophisticated command-line argument handling
The basic command-line argument handling style presented in the Programmers Guide is sufficient for many simple uses.  For even slightly more sophisticated needs, however, this quickly gets cumbersome; just dealing with format validation and optional arguments is better handled by a dedicated CRAN package.  We've found `optparse` useful for this purpose.

A full introduction to this is beyond the scope of this guide, but a simple example is shown in the code for this tutorial.  Check the [package page in CRAN](https://cran.r-project.org/web/packages/optparse/index.html) for more details.
