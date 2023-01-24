local M = {}

function M.write_info(text)
    vim.cmd("echohl Function")
    vim.cmd("echom '" .. text .. "'")
    vim.cmd("echohl None")
end

return M
