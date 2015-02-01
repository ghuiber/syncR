#' Write monthly calendar for given date
#' @param ds date string of format 'YYYY-MM-DD'
#' @param offs offset in days: negative or positive integer number of days before or after \code{ds}
putInCalendar <- function(ds,offs=0) {
   date <- as.Date(ds) + offs
   y    <- as.integer(substr(date,1,4))
   m    <- as.integer(substr(date,6,7))
   d    <- as.integer(substr(date,9,10))
   days <- weekdays(date+c(0:6))
   fdom <- as.Date(paste(y,m,1,sep='-'))
   ldom <- as.Date(paste(y,m+1,1,sep='-'))-1
   lday <- as.integer(substr(ldom,9,10))
   mnth <- c(1:lday)
   fdow <- weekdays(fdom)
   sun  <- which(days=='Sunday')
   cols <- days
   if(sun!=1) {
      cols <- c(days[sun:7],days[1:(sun-1)])
   }
   start <- which(cols==fdow)
   if(start>1) {
      mnth <- c(rep(NA,start-1),mnth)
   }
   mnth <- c(mnth,rep(NA,35-length(mnth)))
   out <- matrix(mnth,nrow=5,byrow=TRUE)
   rownames(out) <- paste('Week',c(1:5),sep=' ')
   colnames(out) <- cols
   return(out)
}