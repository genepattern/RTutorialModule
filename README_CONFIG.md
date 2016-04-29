# Configuring R for GenePattern

As of v3.9.7, a fresh installation of GenePattern will automatically configure wrapper scripts set up to use the various versions of R relevant for our modules using the default paths for the CRAN executables (e.g. `/Library/Frameworks/R.framework/Versions/2.15/Resources/bin/Rscript` for R-2.15.3 on a Mac).  There should be no need for any additional configuration of GenePattern, so long as those versions of R are properly installed (and patched, on a Mac).

When upgrading to v3.9.7 from an older version of GenePattern, for now it is necessary to merge the relevant properties into your existing custom configuration (we plan to have this done automatically in a future version).  By default, these can be found in (respectively):

    ~/.genepattern/resources/wrapper_scripts/wrapper.custom.properties
    ~/.genepattern/resources/custom.properties

Just insert the contents of the first file into the second, removing any existing entries in the process.  After that, restart your GenePattern server to pick up the new changes. 

Beyond that, this default configuration enables use of R\_Environment and R\_Profile files for the more recent versions of R (2.15.3 and newer), which have the standard meaning and behavior here as they do for R in general to specify default mirrors, proxy settings, etc.  As they are completely standard, their use will not be covered here.  See the following for more details:

- [Introduction to R](https://cran.r-project.org/doc/manuals/r-release/R-intro.html)
- [R Installation and Administration](https://cran.r-project.org/doc/manuals/r-release/R-admin.html)
- [List of environment variables affecting an R session](https://stat.ethz.ch/R-manual/R-devel/library/base/html/EnvVar.html)
- [Initialization at Start of an R Session](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html)
- [R Reference Index](https://cran.r-project.org/doc/manuals/r-release/fullrefman.pdf)

# Supported versions of R
We always aim for the “last of the line” for a particular major.minor version of R.  For the various modules in our legacy portfolio, that gives us at present:

- Legacy: don’t develop new modules for these
-- R-2.0.1, R-2.4.1: *no Mac patches available*
-- R-2.5.1, R-2.7.2: *Mac patches available*
-- R-2.15.3: *Mac patches available*.  **Avoid for new modules; possibly still useful as a port target for older 2.x modules**

- Supported for current development
-- R-3.0.3, R-3.1.3
-- R-3.2.5: *not yet supported, but coming soon as a future development target*

We plan to port the few remaining R-2.0.1, R-2.4.1 & R-2.7.2 modules to current versions at some point but this has not yet happened.  R-2.15.3 will likely be supported for some time as it is relatively recent.  We have so many R-2.5.1 modules that it is unlikely we will be able drop support any time soon.  

Nonetheless, we discourage any new work with these versions; their support is continued for legacy reasons only.  In many cases, the CRAN binaries for these cannot even be installed on modern versions Windows and OS X.  For any development work on modules requiring these versions, porting to a more current version of R should be considered essential.

At certain of our High Performance Computing sites, GenePattern is configured to use slightly different point-versions of R (e.g. R-3.0.2 instead of R-3.0.3) because that is the best that is available.  You are still encouraged to use the versions from the above list for your own GenePattern servers and development.  We intend to update these site when the opportunity arises.