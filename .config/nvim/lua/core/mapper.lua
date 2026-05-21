local M = {}

function M.mapper(bufnr)
  return function(mode, lhs, rhs, desc, opts)
    local o = { buffer = bufnr, silent = true, desc = desc }
    if opts then
      o = vim.tbl_extend("force", o, opts)
    end
    vim.keymap.set(mode, lhs, rhs, o)
  end
end

return M
