local M = {}

local default_config = {
  direction = "vertical",
}

M.config = default_config

function M.setup(config)
  if config == nil then
    config = {}
  end

  for k, v in pairs(default_config) do
    if config[k] ~= nil then
      if type(v) == "table" then
        M.config[k] = vim.tbl_extend("force", v, config[k])
      else
        M.config[k] = config[k]
      end
    else
      M.config[k] = default_config[k]
    end
  end
end

return M
