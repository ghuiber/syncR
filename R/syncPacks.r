#' Syncs packages across your computers
#'
#' Prerequisites: you must keep your R packages listed
#' in a synced folder, such as Dropbox or SpiderOak Hive.
#' The packages themselves, that is, are in you \code{lib}
#' folder. What you keep in the synced folder is only
#' an \code{.RData} file that lists them by name. 
#' This is your package database, one per computer. To
#' keep these databases separated from whatever else 
#' you have in the synced folder, give them a subfolder
#' of their own, referenced here as \code{packsdb}.
#' 
#' @param syncfolder Character string, name of parent folder.
#' @param packsdb Character string, name of subfolder, if any.
#' @keywords utilities
#' @export
#' @examples
#' \dontrun{
#' syncPacks('SpiderOak Hive','syncR')
#' syncPacks()
#' }
syncPacks <- function(syncfolder='SpiderOak Hive', packsdb='syncR') {
    info      <- getMyBearings(syncfolder,packsdb)
    thisPuter <- info[['thisPuter']]
    thisR     <- info[['thisR']]
    root      <- info[['root']]
    mywd      <- info[['mywd']]
    namelist  <- info[['namelist']]

    # Refresh the package list for the computer you're on
    setwd(root)
    fi <- paste(thisPuter['nodename'],'.packs.RData',sep='')
    packs <- as.data.frame(installed.packages())
    save(packs,thisR,file=fi)
    
    # Check that you have the same R everywhere.
    # No use syncing packs if the base is not the same.
    checkMyR <- function() {
        out <- sapply(namelist,function(x){
            load(paste(x,'packs.Rdata',sep='.'));return(thisR)})
        if(length(unique(out))!=1) {
            print(t(t(out)))
            stop("Different R versions across your computers.")
        }
        return(out)
    }
    print(t(t(checkMyR())))
    # Install any packages present on any other 
    # computer but missing on this one. 3 steps:
    installMissing <- function(puter) {
        # Step 1: return packages on all computers
        # as a list of as many elements as computers.            
        mypacks <- sapply(namelist,function(x){
            load(paste(x,'packs.Rdata',sep='.'));
            return(as.character(packs$Package))})
        # Combine packages from all other computers in one vector.
        others <- unique(unlist(mypacks[setdiff(namelist,puter)]))
        mine   <- unlist(mypacks[[puter]])
        # Step 2: Find what you need to install:
        # the list of packages missing on this computer.
        toadd  <- setdiff(others,mine)
        print(paste(length(toadd),"packages to add.",sep=" "))    
        if(length(toadd)>0) {
            install.packages(toadd)
        } else {
            print('good to go.')
        }
    }
    # Step 3: run the installer function for this computer
    installMissing(thisPuter['nodename'])
    # Refresh the package list again
    # to reflect any new additions
    packs <- as.data.frame(installed.packages())
    save(packs,thisR,file=fi)
    # restore the working directory to whatever it was
    setwd(mywd) 
}

#' Collect basic info about your environment
#' 
#' @param syncfolder Character string, name of parent folder.
#' @param packsdb Character string, name of subfolder, if any.
#' @keywords utilities
#' @export
getMyBearings <- function(syncfolder,packsdb=NULL) {
    
    # Get this computer's info
    thisPuter <- Sys.info()
    
    # Get version of R installed on this computer
    thisR <- sessionInfo()$R.version$version.string
    
    # Find the path of the sync folder. Default spot:
    # in your home folder on a Mac, in Documents on a PC.
    #
    # If your setup is different, or you need to sync R 
    # also on Linux or FreeBSD machines, fiddle with 
    # this block of code accordingly:
    root <- paste("/Users",thisPuter['user'],syncfolder,sep="/")
    if(thisPuter['sysname']=='Windows') {
        root <- paste("c:/users",thisPuter['user'],"documents",syncfolder,sep="/")
    }
    if(!file.exists(root)) {
        stop(paste("Could not find the folder",syncfolder,"on this computer.",sep=" "))
    }
    root <- paste(root,packsdb,sep='/')
    
    # You may already have R package lists from
    # other computers in your sync folder:
    namelist <- dir(root)[grep("RData",dir(root))]
    namelist <- gsub(".packs.RData","",namelist[grep("RData",namelist)])
    namelist <- union(namelist,thisPuter['nodename'])
    
    # Collect the working directory
    mywd <- getwd()
    out <- list(thisPuter,thisR,root,mywd,namelist)
    names(out) <- c('thisPuter','thisR','root','mywd','namelist')
    return(out)
}
