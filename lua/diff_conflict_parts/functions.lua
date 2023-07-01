local conflict_markers = require("diff_conflict_parts.constants").conflict_markers
local config = require("diff_conflict_parts.config").config

local M = {}

local find_conflict_by_cursor_row = function(lines, cursor_row)
  local conflict = {
    head = {
      start = nil,
    },
    parent = {
      start = nil,
      ending = nil,
    },
    their = {
      ending = nil,
    },
  }

  -- find closest conflict head marker which refers to the current line
  for i = cursor_row, 1, -1 do
    local line = lines[i]

    -- If we find a their marker before head marker, it means that we are not inside the conflict
    if string.find(line, conflict_markers.their.ending) and i ~= cursor_row then
      break
    end

    if string.find(line, conflict_markers.head.start) then
      conflict.head.start = i
      break
    end
  end

  if conflict.head.start then
    for i = conflict.head.start, #lines do
      local line = lines[i]

      if string.find(line, conflict_markers.parent.start) then
        conflict.parent.start = i
      end

      if string.find(line, conflict_markers.parent.ending) then
        conflict.parent.ending = i
      end

      if string.find(line, conflict_markers.their.ending) then
        conflict.their.ending = i
        break
      end
    end

    return conflict
  end

  return nil
end

local get_lines_range_by_part = function(conflict, part)
  if part == "head" then
    -- condition to check whether we are in 2 or 3 way conflict style mode
    return conflict.parent.start and {
      conflict.head.start,
      conflict.parent.start - 1,
    } or { conflict.head.start, conflict.parent.ending - 1 }
  elseif part == "parent" then
    -- condition to check whether we are in 2 or 3 way conflict style mode
    return conflict.parent.start and { conflict.parent.start, conflict.parent.ending - 1 } or nil
  elseif part == "their" then
    return {
      conflict.parent.ending,
      conflict.their.ending - 1,
    }
  end
end

local create_temp_file = function(lines, file_name)
  local temp_file = vim.fn.fnamemodify(vim.fn.tempname(), ":h") .. "/" .. file_name
  vim.fn.writefile(lines, temp_file)

  return temp_file
end

local open_temp_file = function(temp_file, opts)
  vim.fn.execute(opts.open_command .. temp_file, "silent")

  local current_buffer = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_option(current_buffer, "filetype", opts.filetype)
  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    callback = function()
      vim.fn.delete(temp_file)
    end,
    buffer = current_buffer,
  })
end

M.diff_parts = function(parts)
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
  local conflict_buffer = vim.api.nvim_get_current_buf()
  local conflict_buffer_filetype = vim.bo[conflict_buffer].filetype
  local buffer_lines = vim.api.nvim_buf_get_lines(conflict_buffer, 0, -1, true)

  local conflict_under_cursor = find_conflict_by_cursor_row(buffer_lines, cursor_row)

  if conflict_under_cursor == nil then
    return print "Conflict under cursor not found"
  end

  local first_part = parts[1]
  local second_part = parts[2]

  local first_part_lines_range = get_lines_range_by_part(conflict_under_cursor, first_part)
  local second_part_lines_range = get_lines_range_by_part(conflict_under_cursor, second_part)

  if first_part_lines_range == nil or second_part_lines_range == nil then
    if first_part_lines_range == nil then
      return print("There is no " .. first_part .. " part in conflict")
    end
    if second_part_lines_range == nil then
      return print("There is no " .. second_part .. " part in conflict")
    end
  end

  local first_part_lines =
    vim.api.nvim_buf_get_lines(conflict_buffer, first_part_lines_range[1], first_part_lines_range[2], true)
  local first_part_path = create_temp_file(first_part_lines, first_part)

  open_temp_file(first_part_path, { filetype = conflict_buffer_filetype, open_command = "edit" })

  local second_part_lines =
    vim.api.nvim_buf_get_lines(conflict_buffer, second_part_lines_range[1], second_part_lines_range[2], true)
  local second_part_path = create_temp_file(second_part_lines, second_part)

  open_temp_file(second_part_path, {
    filetype = conflict_buffer_filetype,
    open_command = config.direction == "vertical" and "vertical diffsplit" or "diffsplit",
  })
end

return M
