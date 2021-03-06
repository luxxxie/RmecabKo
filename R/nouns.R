# Generated by using Rcpp::compileAttributes() -> do not edit by hand
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' Noun extractor by mecab-ko
#'
#' \code{nouns} returns nouns extracted from Korean phrases.
#' 
#' Noun extraction is used for many Korean text analysis algorithms.
#'
#' @param phrase A character vector or character vectors.
#' @return List of nouns will be returned. Element name of the list are original phrases.
#'
#' See examples in \href{https://github.com/junhewk/RmecabKo}{Github}.
#' 
#' @examples 
#' \dontrun{
#' nouns(c("Some Korean Phrases"))
#' }
#' 
#' @importFrom utils localeToCharset
#' @export
nouns <- function(phrase) {
  if (typeof(phrase) != "character") {
    stop("'phrase' must be a character vector")
  }
  
  if(is_osx() | is_linux()) {
    
    dicpath <- "/usr/local/lib/mecab/dic/mecab-ko-dic"
    
    if(dir.exists(dicpath)) {
      dicpath <- paste0("-d ", dicpath)
    } else {
      stop(paste0("Mecab-ko-dic is not found on ", dicpath, ". Please check https://bitbucket.org/eunjeon/mecab-ko-dic."))
    }

    # Rcpp function to tagging
    tagged <- nounsRcpp(phrase, dicpath)
    
  } else if(is_windows()) {
    
    if(!mecab_installed()) {
      stop("Mecab binary is not installed in C:\\mecab. Please run install_mecab().")
    }

    mecabLibs <- getOption("mecab.libpath")
    
    # loading /inst/mecab/mecab.exe (mecab-ko-msvc) with system.file and system
    mecabKo <- utils::shortPathName(file.path(mecabLibs, "mecab.exe"))
    mecabKoRc <- utils::shortPathName(file.path(mecabLibs, "mecabrc"))
    # mecabKoDic root in not working
    mecabKoDic <- utils::shortPathName(file.path(mecabLibs, "mecab-ko-dic"))
    
    # saving phrase to UTF-8 txt file
    phraseFile <- utils::shortPathName(tempfile())

    con <- file(phraseFile, "a", encoding = "UTF-8")
    tryCatch({
      cat(iconv(phrase, from = utils::localeToCharset()[1], to = "UTF-8"), file=con, sep="\n")
    },
    finally = {
      close(con)
    })

    outputFile <- utils::shortPathName(tempfile())
    
    mecabOption <- c("-r", mecabKoRc, "-d", mecabKoDic, "-o", outputFile, phraseFile)
    
    # run mecab.exe
    system2(mecabKo, mecabOption)

    con <- file(outputFile, "r")
    posResult <- readLines(con, encoding="UTF-8")
    close(con)
    
    i <- 1
    tagged <- list()
    length(tagged) <- i
    
    for (line in seq(1, length(posResult), 1)) {
      
      if (posResult[line] == "EOS") {
        i <- i + 1
        if (line != length(posResult)) length(tagged) <- i
      } else {
        taggedElements <- strsplit(posResult[line], "\t")
        if(substring(taggedElements[[1]][2], 1, 1) == "N") {
          tagged[[i]] <- c(tagged[[i]], taggedElements[[1]][1])
        }
      }
    }
    
    suppressWarnings(file.remove(phraseFile))
    suppressWarnings(file.remove(outputFile))
  } 
  names(tagged) <- phrase
  
  return(tagged)
}

#' Words extractor by mecab-ko
#'
#' \code{words} returns full morphemes extracted from Korean phrases.
#' 
#' It is based on Mecab-Ko POS classification.
#'
#' @param phrase Character vector.
#' @return List of full morphemes will be returned.
#'
#' See examples in \href{https://github.com/junhewk/RmecabKo}{Github}.
#' 
#' @examples 
#' \dontrun{
#' words(c("Some Korean Phrases"))
#' }
#' @importFrom utils localeToCharset
#' @export
words <- function(phrase) {
  if (typeof(phrase) != "character") {
    stop("'phrase' must be a character vector")
  }
  
  if(is_osx() | is_linux()) {
    
    dicpath <- "/usr/local/lib/mecab/dic/mecab-ko-dic"
    
    if(dir.exists(dicpath)) {
      dicpath <- paste0("-d ", dicpath)
    } else {
      stop(paste0("Mecab-ko-dic is not found on ", dicpath, ". Please check https://bitbucket.org/eunjeon/mecab-ko-dic."))
    }
    
    # Rcpp function to tagging
    tagged <- wordsRcpp(phrase, dicpath)
    
  } else if(is_windows()) {
    
    if(!mecab_installed()) {
      stop("Mecab binary is not installed in C:\\mecab. Please run install_mecab().")
    }
    
    mecabLibs <- getOption("mecab.libpath")
    
    # loading /inst/mecab/mecab.exe (mecab-ko-msvc) with system.file and system
    mecabKo <- utils::shortPathName(file.path(mecabLibs, "mecab.exe"))
    mecabKoRc <- utils::shortPathName(file.path(mecabLibs, "mecabrc"))
    # mecabKoDic root in not working
    mecabKoDic <- utils::shortPathName(file.path(mecabLibs, "mecab-ko-dic"))
    
    # saving phrase to UTF-8 txt file
    phraseFile <- utils::shortPathName(tempfile())
    
    con <- file(phraseFile, "a", encoding = "UTF-8")
    tryCatch({
      cat(iconv(phrase, from = utils::localeToCharset()[1], to = "UTF-8"), file=con, sep="\n")
    },
    finally = {
      close(con)
    })
    
    outputFile <- utils::shortPathName(tempfile())
    
    mecabOption <- c("-r", mecabKoRc, "-d", mecabKoDic, "-o", outputFile, phraseFile)
    
    # run mecab.exe
    system2(mecabKo, mecabOption)
    
    con <- file(outputFile, "r")
    posResult <- readLines(con, encoding="UTF-8")
    close(con)
    
    i <- 1
    tagged <- list()
    length(tagged) <- i
    tagItem <- c("N", "V", "M", "I")
    
    for (line in seq(1, length(posResult), 1)) {
      if (posResult[line] == "EOS") {
        i <- i + 1
        if (line != length(posResult)) length(tagged) <-i
      } else {
        taggedElements <- strsplit(posResult[line], "\t")
        if (substring(taggedElements[[1]][2], 1, 1) %in% tagItem) {
          tagged[[i]] <- c(tagged[[i]], taggedElements[[1]][1])
        } else if (substring(taggedElements[[1]][2], 1, 2) == "SL") {
          tagged[[i]] <- c(tagged[[i]], taggedElements[[1]][1])
        }
      }
    }
    
    suppressWarnings(file.remove(phraseFile))
    suppressWarnings(file.remove(outputFile))
  } 

  return(tagged)
}