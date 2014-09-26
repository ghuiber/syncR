#' A tweak on \code{slidify::publish_github()}. 
#' 
#' Assuming that you're already working on code that's being backed up on GitHub, and that your final output is .html knitted from a .Rmd file, you might as well publish it as a \href{https://pages.github.com}{GitHub page}. This function does it with one simple call.
#' @param repo your public GitHub repo, e.g. "syncR"
#' @param username your GitHub user name, e.g. "ghuiber"
#' @export
publishGithub <- function (repo, username = getOption("github.user")) 
{
   if(grep(repo,getwd())!=1) {
      stop(paste('Error: setwd() to local copy of',repo,'repo',sep=' '))
   }   
   if (!file.exists(".git")) {
      message("Initializing Git Repo")
      system("git init")
      system("git commit --allow-empty -m 'Initial Commit'")
      message("Checking out gh-pages branch...")
      system("git checkout -b gh-pages")
      message("Adding .nojekyll to repo")
      file.create(".nojekyll")
   }
   if (!file.exists(".nojekyll")) {
      message("Adding .nojekyll to your repo...")
      file.create(".nojekyll")
   }
   message("Publishing on GitHub: ", username, "/", repo)
   system("git add .")
   system("git commit -a -m \"publishing html5\"")
   system(sprintf("git push git@github.com:%s/%s gh-pages", 
                  username, repo))
   link = sprintf("http://%s.github.com/%s", username, repo)
   message("You can now view your slide deck at ", link)
   browseURL(link)
}