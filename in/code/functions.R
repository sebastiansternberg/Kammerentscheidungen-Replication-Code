clean.names <- function(x){
  x <- str_replace_all(x, "\\s", " ")
  x <- str_replace_all(x, "Di Fabio", "DiFabio")
  x <- str_replace_all(x, "Vossk", "Voßk")
  x <- str_replace_all(x, "Hasseme( |,|$)", "Hassemer ")
  x <- str_replace_all(x, "- ", "-")
  x <- str_replace_all(x, "Mellinghofff", "Mellinghoff")
  x <- str_replace_all(x, "Kuehling", "Kühling")
  x <- str_replace_all(x, "Bross", "Broß")
  x <- str_replace_all(x, "Grasshof", "Graßhof")
  x <- str_replace_all(x, "Gerhard( |,|$)", "Gerhardt ")
  x <- str_replace_all(x, "Hoemig", "Hömig")
  x <- str_replace_all(x, "Lübbe-Woff", "Lübbe-Wolff")
  x <- str_replace_all(x, "Kessal-Wulff", "Kessal-Wulf")
  x <- str_replace_all(x, "Steine ", "Steiner")
  x <- str_replace_all(x, "Hohmann-Dennhard ", "Hohmann-Dennhardt ")
  x <- str_replace_all(x, "Judge.?:", "")
  
  return(x)
}

# split richter strings
richter.split <- function(x){
  x <- str_trim(str_replace_all(x, "\\.|,|;", " "))
  x <- str_split(x, " +")
  return(x)
}

jahr.to.date <- function(x){
  x <- str_replace(x, "(^[0-9]{4}$)", "01/01/\\1")
  x <- str_replace(x, "ab ", "")
  x <- str_replace(x, " ", "")
  x <- as.Date(x, "%d/%m/%Y")
}



# little helper functions
is.red <- function(x) as.numeric(x%in%redr)
zero.as.NA <- function(x) if (length(x) == 0) return(NA) else return(x)
zero.as.int <- function(x) if (length(x) == 0) return(0) else return(x)
zero.as.blank <- function(x) if (length(x) == 0) return("") else return(x)

# get richter from x kammer in that order
get.gv <- function(x) return(unlist(richter.split(set$richter[set$kammer==x]))[rf[[as.numeric(row.names(set[set$kammer==x,]))]]])

## str_c if list
list.collapse <- function(x) unlist(lapply(x, function(y) str_c(y, collapse = " ")))
