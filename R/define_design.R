#' Define Your Research Design and Create Code Directory with Step Templates
#'
#' This generates a directory at \code{rel_dir}
#' (defaulting to "./code"). In this directory it will create
#' a set of files with templates for all code steps or a joint file
#' containing all step templates.
#'
#'
#' @param steps A character vector containing the names for the step functions.
#'   All members need to be valid R names.
#' @param rel_dir A relative path to a directory in which you want to create
#'   the step templates.
#' @param one_file If \code{TRUE}, then all templates will be stored in a file
#'   with the name \code{one_file_name}. If {FALSE} (the default), each step template
#'   will be stored in a separate file with the step name acting as file name.
#' @param one_file_name The name of the code file conating the step templates if
#'   all step templates are stored in one file. Defaults to "design_steps.R".
#' @return The \code{steps} parameter.
#' @details See the vignette of the package for further details.
#' @examples
#' \dontrun{
#'   print("Sorry. No examples yet.")
#' }
#' @export

define_design <- function(steps, rel_dir = "./code",
                          one_file = FALSE, one_file_name = "design_steps.R") {
  if (!identical(make.names(steps), steps))
    stop("steps contains invalid R names")

  pkg_app_dir <- system.file("template", package = "rdfanalysis")
  con <- file(file.path(pkg_app_dir, "step_template.R"), "r")
  step_template <- readLines(con)
  close(con)
  code_dir <- file.path(getwd(), rel_dir)
  if(!dir.exists(code_dir)) dir.create(code_dir, recursive = TRUE)
  dont_write <- FALSE
  for (s in steps) {
    st <- step_template
    st[1] <- gsub("step_name", s, st[1])
    ret_pos <- grep("# RETURN BLOCK HERE", st)
    if (s == steps[1]) {
      st[ret_pos] <-     "  return(list("
      st[ret_pos + 1] <- "    data = \"[variable containing your output data structure here]\","
      st[ret_pos + 2] <- "    protocol = list(choice)"
      st[ret_pos + 3] <- "  ))"
      st[ret_pos + 4] <- "}"
    } else {
      st[ret_pos] <-     "  protocol <- input$protocol"
      st[ret_pos + 1] <- "  protocol[[length(protocol) + 1]] <- choice"
      st[ret_pos + 2] <- "  return(list("
      st[ret_pos + 3] <- "    data = \"[variable containing your output data structure here]\","
      st[ret_pos + 4] <- "    protocol = protocol"
      st[ret_pos + 5] <- "  ))"
      st[ret_pos + 6] <- "}"
    }
    if (!one_file) {
      file_name <- file.path(code_dir, paste0(s, ".R"))
      if (file.exists(file_name))
        message(sprintf("File %s already exsits! Won't overwrite existing file.", file_name))
      else {
        file.create(file_name)
        con <- file(file_name, "w")
        writeLines(st, con)
        close(con)
      }
    } else {
      if (s == steps[1]) {
        file_name <- file.path(code_dir, one_file_name)
        if (file.exists(file_name)) {
          message(sprintf("File %s already exsits! Won't overwrite to existing file.", file_name))
          dont_write <- TRUE
        }
        else {
          file.create(file_name)
          con <- file(file_name, "w")
        }
      }
      if (! dont_write) {
        writeLines(st, con)
        if (s != steps[length(steps)]) writeLines(c("", ""), con)
        else close(con)
      }
    }
  }
  steps
}

