local M = {}

M.conflict_markers = {
  head = { start = "<<<<<<<" },
  parent = { start = "|||||||", ending = "=======" },
  their = { ending = ">>>>>>>" },
}

return M
