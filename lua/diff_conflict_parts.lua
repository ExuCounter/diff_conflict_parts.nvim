local diff_parts = require("diff_conflict_parts.functions").diff_parts
local setup_config = require("diff_conflict_parts.config").setup

local M = {}

local create_user_commands = function()
  vim.api.nvim_create_user_command("DiffHeadTheir", function()
    diff_parts { "head", "their" }
  end, {})
  vim.api.nvim_create_user_command("DiffHeadParent", function()
    diff_parts { "head", "parent" }
  end, {})
  vim.api.nvim_create_user_command("DiffParentTheir", function()
    diff_parts { "parent", "their" }
  end, {})
end

M.setup = function(configuration)
  setup_config(configuration)
  create_user_commands()
end

return M
