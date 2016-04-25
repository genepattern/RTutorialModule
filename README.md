# RTutorialModule

This is a tutorial module for writing GenePattern modules in R.  It contains a very simple module that accepts a GCT as input and increments it based on an input value, writing the resulting matrix to a new output GCT.  While this is not by itself a very interesting module, it illustrates some basic techniques useful to an R developer trying to get started with GenePattern.

A new developer should have a look at the R code, the r.package.info file, and the manifest to get started.  The first two are most specific to R development and will be the most immediately useful.  While the manifest is a fairly typical example for any GenePattern module, it's the bridge from GenePattern to the R code and sets up the interface between the two.  All three files are heavily annotated so that information will not be repeated here.

The [Packages guide](README\_PACKAGES.md) contains detailed information for working with R packages within GenePattern beyond what is described in our [Programmers Guide](http://www.broadinstitute.org/cancer/software/genepattern/programmers-guide#Using_R_Packages).

The [Developers Crash Guide](README\_CRASH\_GUIDE.md) contains some of my tips, tricks, and pitfalls for developing GenePattern modules in R.  Like the Packages guide, I considered these somewhat too detailed to include in the Programmers Guide.

The [Mac platform guide](README\_MAC.md) contains detailed info for working with R in GenePattern on Mac OS X as there are special challenges for this platform.  A good deal of this information is in our [Administrators Guide](http://www.broadinstitute.org/cancer/software/genepattern/administrators-guide) but is more up-to-date.  There is some repetition between the two guides but also not complete overlap; the intention is to eventually merge and rectify the two documents.  For now, it's important to at least have the info available in some form. 

The [Configuration guide](README\_CONFIG.md) contains some information on configuring R for GenePattern.  Again, most if not all of this information will end up in the Administrators Guide eventually.
