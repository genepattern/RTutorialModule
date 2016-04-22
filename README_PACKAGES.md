# Using R Packages in GenePattern Modules

## Introduction

The GenePattern [Programmers Guide](http://www.broadinstitute.org/cancer/software/genepattern/programmers-guide#Using_R_Packages) has detailed information on the use of the r.package.info file to specify a list of packages to be used in a module.  While that should be considered the official reference, this README provides further background and explanations as well as tips for developing with R packages.

Let's start out by first discussing the problem we are trying to solve.  From the Gene Pattern team's point of view, it's important that modules are **portable** and that the results they produce are **reproducible**.  This requires a consistent environment wherever the modules are to be installed.  While we can never reach total perfection in that regard, ensuring that modules run on both a specified version of R and with a consistent library of packages (of specified versions) goes a long way towards the goal.

R itself makes no guarantees about forward- or backward-compatibility, either in the runtime or among package versions.  The same program can give different behavior when run even on a different point-version (say 2.15.2 instead of 2.15.3), let alone with a different *major* or *minor* version (2.14.2 or 3.0.3).  Using a different package version than originally intended can do likewise.  It's quite possible for a program to **not run at all** with the wrong version.

The Bioconductor project has recognized this issue and largely solved it by having regular well-tested releases tied to particular versions of R that do not change post-release: package versions are fixed.  Thus, packages installed from a given release will always have the same versions in the future as in the present.  While it's possible to override this behavior, that's the default and you have to go out of your way to change it.  This is important for our goals of portability and reproducibility, as a GenePattern module may be installed on a new server several years after initial release.

By contrast, installing a package from CRAN will try to install the latest version available for that version of R, so versions for future installations can quite easily be different from the present.  This is the default behavior and it is also quite difficult to change.

## Package Versions During Module Development

If you are developing a new module all of this might sound like a distraction.  I won't argue the point; during development this largely *is* a distraction.  If you're working with a relatively recent version of R, the exact package versions probably don't matter much since they are likely to be recent as well.  Whichever versions are installed will probably be fine.

Nailing down the exact versions is really only a concern when it comes to finalizing your module for distribution to others.  Until you reach that point you probably will not have to worry about it unless other issues come up during development.  You can install without regard to version - either in an R session or using the format described in the next section - and sort it prior to distribution.

Later in this README I'll cover an approach for this final sorting-out process.

## Use of the r.package.info File

The r.package.info file is a mechanism for declaring package dependencies to GenePattern.  As of GenePattern 3.9.6 and more fully expanded in 3.9.7, GenePattern will automatically detect this file and use it to install any packages missing from the server.  The idea is that the module author should declare what is needed without having to worry about how they are installed on the server, where they reside on the file system, or how GenePattern makes them available to the module code.  The burden for all of that falls to the GenePattern server and the server administrators.

The format is explained in the Programming Guide and illustrated in this module's example file, so there's no need to repeat it here in this README.  If anything, this module's example r.package.info is too verbose.  Just so that it's clear how concise this file can be, a stripped-down minimal file is shown here:

    package,requested_version,archive_name,src_URL,Mac_URL,Windows_URL
    getopt,1.20.0,CRAN
    optparse,1.3.2,CRAN
    limma
    edgeR

As you can see, we are pinning any CRAN packages to specific versions.  This is not necessary with Bioconductor packages: so long as they are installed using the correct version of R, the Bioconductor repository will always supply the same package versions.

During development, if you don't want to think about package versions you can use this slightly simpler file instead:

    package,requested_version,archive_name,src_URL,Mac_URL,Windows_URL
    getopt
    optparse
    limma
    edgeR

The version specifics would be added later, when preparing the module for final distribution to others.

This should be a list of all the required packages, including their dependencies (e.g. `optparse` requires `getopt`).  While the `install.packages()` and `biocLite()` functions can automatically install dependencies, using that feature would allow their versions to drift over time. 

We recommend loading each explicitly in your R code as well, just for clarity.  This is not strictly necessary, however.  You can list just the top-level packages if you prefer.

## An Exception: Annotations

While we ask you use r.package.info to list all possible packages needed by your module, there is an important exception.  In the case of annotation packages and similar, you may not know up front exactly which will be used but it's probably also impractical to preemptively install them all in advance in case they are needed.  Our ExpressionFileCreator and AffySTExpressionFileCreator modules are examples: while analysis of human or mouse arrays could be expected, there are dozens of other organisms which may never be needed on a given GenePattern server.

In such cases, it's up to you to manage the `install.packages()` or `biocLite()` calls for yourself.  See those two modules for example code (AffyST EFC is recommended as it is the more recent of the two).

Note that the GenePattern team reserves the right to disallow modules using `install.packages()` or `biocLite()` from our public servers and repositories in order to keep our server environments under control, so we will need to review the code more closely in such cases.  If you require only a few annotation packages, you might consider simply listing them all in r.package.info and allowing the GenePattern server to handle them.

## Managing Package Libraries

Installing and using R from CRAN with the default configuration with no other measures will result in packages being installed into the base R library location.  While this is generally fine for an individual developer, it makes it difficult to sort things out later when it comes to exact package requirements for distribution.

Keep in mind that wiping out and rebuilding your package library is a common troubleshooting technique when dealing with R.  This is harder to do if packages are installed directly into the base.

You can keep this base location clean and better manage your packages by keeping a separate library location.  This can be the default user library (e.g. ~/Library/R on a Mac) or a some other dedicated location defined in an R_Environ file.  This allows you to freely clean out and reinstall your packages without affecting the base R installation.  This is highly recommended, both while running in GenePattern and also when using external R sessions.

As of v3.9.7, GenePattern will install special wrapper scripts that configure its own separate, dedicated library.  These will be enabled by default on a Mac but require some hand-configuration on Linux; more details can be found in our Admin Guide.
It's still a good idea to configure a dedicated library for outside R sessions and keep packages out of the base; it's fine to use the GP library for this.  More details later.

## Installing Packages for Development

If you have set up a package library for use both inside and outside of GenePattern, then it's perfectly fine to use `install.packages()` or `biocLite()` from an R session to install packages for development.  You can also create a "stub" module with an r.package.info file but no real code and use GenePattern to install the packages.

There is also a family of InstallRPackages modules (one for each version starting at R-2.15) available from our Beta repository.  These accept the r.package.info format and use the same underlying code as the GenePattern installer.  Note that its jobs will usually fail due to R's propensity to emit non-fatal warnings or plain informational messages on stderr.  Just review both stdout and stderr to make sure everything went well.

These modules come in handy when trying to sort out exact package versions, a point that will be discussed later.

### Non-Package Dependencies

Some packages have system-level dependencies outside of other R packages; on Linux, XML\_3.98-1.1 requires libxml2 and RCurl\_1.95-4.1 requires libcurl, for example.  The r.package.info format doesn't provide any way to specify these dependencies.

We're considering possible solutions, but for now please note any such requirements in your module documentation.

## Sorting Out the Package List

Sorting out the exact versions of packages is mostly the responsibility of the GenePattern team.  Since there's only one package library per version of R, there will be only one version of each package available on the server.  We need to manage versions across all modules to ensure compatibility and stability.  We may consider changing this in the future, but for now this means it's a system administration task.

You can still help us by giving us a list of the packages used by your module with the versions used during development in the correct order of installation.  We will likely need to modify the list somewhat for cross-module compatibility but this gives us an excellent starting point.

### An Approach for Finding Required Package Versions

Most developers will not need to worry about this section given that finding exact versions is the responsibility of the GenePattern team.  It's provided here for our own documentation but also to show others what goes into the process in case the need comes up.

First, note that this is just one possible approach.  It's the approach that I use but other methods may work just as well.  Also realize that this is an outline and you may need to vary at points.

Assuming that you have a new R script, complete with library() or require() calls to load the required packages you have presumably gone most of the way towards identifying what packages you need: they are already named in the these calls.  This is only a partial list, however, since each of these package may have its own list of required packages.

Start with a clean, separate dedicated library location, meaning no packages installed in the base and no personal (user) package libraries.  I will usually work with the GenePattern package library but at times it can be useful to work with a complete separate location as well.

    rm -rf ~/.genepattern/patches/Library/R/3.1  # ...modify for your GP location
    mkdir -p ~/.genepattern/patches/Library/R/3.1

If you don't want to lose your existing installed packages, you can temporarily rename this directory instead and create a clean location in its place:

    mv ~/.genepattern/patches/Library/R/3.1 ~/Library/holdR3.1   #...or whatever
    mkdir -p ~/.genepattern/patches/Library/R/3.1

Now, fire up a new R session, setting this directory as your default library location.  That can be set via an R environment file or even just a `.libPaths()` call.  Re-install each of your top-level package requirements using the usual `install.packages()` or `biocLite()` calls with full verbosity.  Note any supporting packages downloaded and installed in the process along with their exact versions and the order.

- **Always** use the final point update for that version of R.  That is, R-2.15.**3**, 3.0.**3**, 3.1.**3**.  We need to be consistent across environments to avoid dependency drift.
- It's not necessary or even desirable to list CRAN versions at first, but these must be **locked down** to make the declaration final otherwise we'll have drift.

Transcribe this information into an r.package.info file, including the version and CRAN archive tag to pin those packages coming from CRAN.  On the off chance that the module uses a custom package not available from CRAN or Bioconductor, include the URLs for those bundles from wherever they are hosted.

- Note for the future: we may need to add direct support for other repositories such as RForge at some point.  None of our modules have this need at present, so allowing for URLs is enough for now.

Alternatively, if we already have a number of modules using that particular version of R we may have a substantial list of known-to-work package versions.  In that case, it's better to pull in that information from existing r.package.info files and use that for a starting point.

Now, clean out the GenePattern package library once again and feed this file to the InstallRPackages module.  Check the log to make sure everything went well, plus the stdout and stderr for details.  As mentioned earlier, remember that the job will likely fail due to R's propensity for non-fatal stderr messaging.  That's irrelevant to us so long as there are no true errors.

I develop on a Mac, where R downloads binary packages and the installation process is fairly quick.  This is a good way to get a first pass, but it's also necessary to try on a Linux server to be sure.  This will give a more accurate picture but is often tougher than working on a developer laptop:

- If it's one of our shared servers, it's not safe to wipe out the GenePattern package library as it affects other modules and other users.  Also, we often don't have full admin rights to install system-level dependencies outside of R packages.
- You can use a VM, though it requires more set-up to get it correct.  This is probably the best option, though, because you have full control of the environment.
- In any case, all packages will be installed **from source** which will take a good deal longer.  Working with platform-specific binaries for most of the work is preferred for speed and simplicity.

You can use the InstallRPackages module here once again.  There are times where installing from source on Linux will pull in extra packages not required when installing binaries, so pay close attention to the log, stdout, and stderr.  Transcribe any additional packages (and their versions) as necessary.  With luck, the earlier runs with binary packages caught them all.

- The logs list the version of a package that was downloaded.  Get the exact CRAN version string reported in stdout and add it to the appropriate declaration column.  The mechanism used for report.log sometimes munges that string.
- Don't declare Bioconductor package versions; BC is strict on versioning and gets things right.
- Troubleshoot any errors.  I'll add more notes below, but the most common issue is hidden dependencies: `Error: dependencies 'x' and 'y' are not available for package 'z'`.  Declare these new packages above the one that needs them.  Unfortunately you may only find a few at a time, which makes this an iterative process.
- Iterate with the updated file: I usually clean out site-library again at this point, though you can go several iterations without.  Your final run-through should be clean, however.

That should get you 95% or more of the way there.  There will occasionally be issues due to the particular mix of packages, a declaration error in CRAN, or missing system-level dependencies (like the aforementioned libxml2 or libcurl).

We’ll cover troubleshooting possible issues as well as porting to Linux later, but in the absence of problems you are all set.  Feel free to move your ‘holdR3.1’ library back into place at this point.

Here are some notes on troubleshooting and other tips:

- Remember that the site-library applies to all modules for a version of R.  Downside: one module may break with a specific package version where another works (unlikely; I've never seen it).  Upside: if an existing module already uses any of your dependencies, you should be able to just forward that same info to the new declaration.
- List CRAN packages before BC packages.  BC packages may depend on CRAN but I've never seen the reverse.
- Order is important; a package must be installed after its dependencies.
- The order of packages in an error message ('x' and 'y' above) may not match the required order of installation.  Be prepared to switch them while iterating.
- Watch out for personal R libraries!  These are most often in the user's home directory, like ~/Library/R/2.15/library.  They are generally dangerous to keep around as they may mask dependencies.  They do occasionally have their place, but I usually remove them for safety during GenePattern module development.
- Error diagnosis usually comes down to Google, Stack Overflow, etc.  Try searching the specific R version + package name w/version + error message.
- You may get errors unrelated to packages, often for system-level dependencies like Cairo or X11.  These often show up on Linux in the form of missing header files or libraries.  They are **not** often discovered with platform-specific binaries. 
- You may occasionally have the need to use an earlier version of a package than what is installed by default.  For example, the default version of RSQLite in CRAN for R-2.15 won't work with cummeRbund.  The fix is usually to pin that package to an earlier version in r.package.info.  Check the package archives, e.g. https://cran.r-project.org/src/contrib/Archive/RSQLite/ .

Finally, note that all of the above steps merely ensure that the required packages install, not that they behave properly and produce correct results.  To state the obvious, after the packages are installed it's important to then *install and test* the module, ideally with some form of automated testing such as GpUnit.  If version adjustments were required then it's quite possible that previously run expected result files will differ; the new results must then be reviewed to be sure that they are *scientifically correct* even if there are differences.
