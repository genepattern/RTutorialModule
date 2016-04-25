# David’s crash guide to R + GenePattern for Mac users

## Introduction

This is a guide for Mac OS X users to get up-and-running with R + GenePattern.  I'm calling it a crash guide as we will very quickly dive into some low-level hacks and workarounds involved in developing R modules for GenePattern on this platform.

Right off as a quick piece of key background, all GenePattern modules are tied to a specific version of R both for reproducibility and because R is neither full backward- or forward-compatible across versions.  In other words, we do this to ensure that the code will actually continue to run and produce the expected results.

This has a profound effect on the way we must deal with R because it is at-odds with the way that R itself is distributed for OS X (unlike Windows or Linux).  In particular, the distributed CRAN binaries generally assume there is only one version present on the Mac.  Having more than one version present is not officially supported (and is discouraged) by CRAN.

If you are developing only a single module or are working with a set of modules confined to one version of R then this may not be an issue.  However, if you need to work with modules spanning multiple versions of R then there are several issues to deal with.  This is where the low-level hacks and workarounds come into the picture.  For this reason, we **highly** recommend that you stick with one of our public servers rather than trying to install your own on OS X.

### Pitfall: installing multiple versions of R
On trying to install more than one version of R from CRAN, the Mac user will be faced with several issues.  Most immediately, the OS X CRAN binary installers will by default remove previously installed versions of R, leaving only one installed version.  There are instructions to avoid this within the installer wizard but most people will simply click through without seeing them.

If you already have one version of R installed and are preparing to install another, first open a Terminal and execute the following command:

    sudo pkgutil --forget org.r-project.R.Leopard.fw.pkg

For the much older versions of R (pre-2.10), the instructions differ slightly:

    sudo pkgutil --forget org.r-project.R.framework

Many “classic” GP modules require R-2.5 so both commands are definitely warranted.  It’s simplest to just execute both and not worry about which R versions you expect to install.  In practice, OS X seems to be good about remembering these directives, so it’s not necessary to re-execute these before every R version installation.  It will occasionally reset (possibly on OS X upgrades?), causing a subsequent R install to wipe out all your previous versions.

- While we have been actively trying to both update our modules to newer versions of R and also cut down the total number of different supported versions, there are so many modules in our repositories and too many competing priorities that many are still on older versions.
- Moreover, it's highly unlikely - and simply not practical - for us to ever reach the point where all modules are on a single, up-to-date version of R.

### Pitfall: Installing R-2.15.3
On OS X 10.10 Yosemite (and possibly newer), the official CRAN installers for R versions between 2.10 and 2.15 no longer work.  As several of our modules use R-2.15.3, it’s necessary to use a workaround.  Our now-abandoned R Installer Plug-in gives us one.

Install RankNormalize v1 from the repository and it will install R-2.15.3 to the appropriate location with the proper patches applied (see below on Conflicts).  Other modules will do the same, but RankNormalize is a good choice because it’s small and simple.  Note that newer versions of the module do not use the plug-in so select v1 specifically.

As an alternative, you could also download the Plug-in’s R bundle and install it yourself by executing this in Terminal.app:

    cd ~/Downloads
    curl -O ftp://gpftp.broadinstitute.org/plugin_support_files/R_Installer/2.15.3/R_2.15.3_mac_full.tar.gz  # ... all that as one line
    cd /Library/Frameworks/R.framework/Versions
    sudo tar -xzvpf ~/Downloads/R_2.15.3_mac_full.tar.gz

Hopefully in the future we’ll entirely move off of R-2.15 and earlier but at this time we have no definite plans to do so.

### Pitfall: Conflicts among multiple versions of R
The R installers from CRAN assume the use of a “Current” version symlink; there are baked-in references to this in the scripts and binaries it puts in place.  This is due to the way these binaries are built for CRAN and has nothing to do with GenePattern.  We need to patch these files in order to provide some degree of concurrent R session interoperability.

The unofficial `RSwitch` utility provides support for this, but not for concurrent R sessions.  As GenePattern allows many modules to run at once, some other solution is required.

We have created patch bundles available for most of our recommended versions of R, available from `ftp://gpftp.broadinstitute.org/plugin_support_files/R_Installer/` as noted above.  After installing a new version of R, the bundle is extracted to overwrite the existing files.  Be sure to pick the bundle(s) exactly matching the version(s) of R you need.

Patching is very similar to the R-2.15.3 by-hand workaround instructions.  Here’s an example for R-3.1.3; for other versions of R just substitute the version number appropriately:

    cd ~/Downloads
    curl -O ftp://gpftp.broadinstitute.org/plugin_support_files/R_Installer/3.1.3/R_3.1.3_mac_patch.tar.gz  # ... all that as one line
    cd /Library/Frameworks/R.framework/Versions
    sudo tar -xzvpf ~/Downloads/R_3.1.3_mac_patch.tar.gz
