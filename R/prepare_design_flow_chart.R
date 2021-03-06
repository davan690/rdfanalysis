#' Prepare A Flow Chart of Your Research Design
#'
#' Generates a \code{DiagrammeR} flow chart of your research design.
#' Output can be saved to a file or directly viewed.
#'
#' @param d A character vector of the research design steps function names
#' @param file_name A file name for an output PDF file relative to the working directory.
#' @param landscape Do you want the flow chart to be generated horizontally instead of vertically.
#'   Defaults to FALSE.
#' @param color_step The fill color to indicate a design step.
#' @param color_dchoice The fill color to indicate a discrete choice.
#' @param color_cchoice The fill color to indicate a continuous choice.
#' @param color_result The fill color to indicate a result.
#' @return the rendered diagram or, if \code{file_name} is specified, the return code from
#'   \code{DiagrammeRsvg::export_graph()}
#' @examples
#' \dontrun{
#'   print("Sorry. No examples yet.")
#' }
#' @export

prepare_design_flow_chart <- function(d, file_name = NULL, landscape = FALSE,
                                      color_step = "skyblue2", color_dchoice = "skyblue3",
                                      color_cchoice = "skyblue4", color_result = "slategray") {
  label <- c()
  type <- c()
  layer <- c()
  row <- 1
  for(step in d) {
    res <- get(step)()
    label <- c(label, step)
    type <- c(type, "step")
    layer <- c(layer, row)
    row <- row + 1
    for (c in res$choice_type) {
      if(c$type == "character") {
        label <- c(label, paste0(c$name, ":\n", c$valid_values))
        type <- c(type, rep("dchoice", length(c$valid_values)))
        layer <- c(layer, rep(row, length(c$valid_values)))
        row <- row + 1
      }  else {
        label <- c(label, sprintf("%s\nvalid_min: %s\nvalid_max: %s",
                                  c$name, format(c$valid_min),
                                  format(c$valid_max)))
        type <- c(type, "cchoice")
        layer <- c(layer, row)
        row <- row + 1
      }
    }
  }
  label <- c(label, "result")
  type <- c(type, "result")
  layer <- c(layer, row)

  gr <- DiagrammeR::create_graph()
  for (i in 1:length(type))
    gr <- DiagrammeR::add_node(gr, label = label[i], type = type[i])
  for (i in 1:length(type))
    for (j in which(layer == layer[i] + 1))
      gr <- DiagrammeR::add_edge(gr, from = i, to = j)

  gr$nodes_df$shape[gr$nodes_df$type == "step"] <- "rectangle"
  gr$nodes_df$fillcolor[gr$nodes_df$type == "step"] <- color_step
  gr$nodes_df$shape[gr$nodes_df$type == "dchoice"] <- "ellipse"
  gr$nodes_df$fillcolor[gr$nodes_df$type == "dchoice"] <- color_dchoice
  gr$nodes_df$shape[gr$nodes_df$type == "cchoice"] <- "oval"
  gr$nodes_df$fillcolor[gr$nodes_df$type == "cchoice"] <- color_cchoice
  gr$nodes_df$shape[gr$nodes_df$type == "result"] <- "diamond"
  gr$nodes_df$fillcolor[gr$nodes_df$type == "result"] <- color_result

  gr$nodes_df$fixedsize <- FALSE
  gr$global_attrs$value[1] <- "dot"
  gr$global_attrs$value[gr$global_attrs$attr == 'fontcolor'] = "white"
  if (landscape)
    gr$global_attrs <- rbind(gr$global_attrs,
                             c(attr = "rankdir", value = "LR",
                               attr_type = "graph"))

  if (!is.null(file_name)) gr %>% DiagrammeR::export_graph(file_name = paste0(getwd(), "/", file_name))
  else DiagrammeR::render_graph(gr)
}
