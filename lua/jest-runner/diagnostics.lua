local M = {}

M.ns = nil

function M.setup()
    M.ns = vim.api.nvim_create_namespace("my_example_plugin")
end

function M.parse_diagnostics(test_data)
    local diagnostics = {}
    return diagnostics
end

function M.show_diagnostics(test_data)
    -- logic for generating diagnostics
    local diag = {
        {
           lnum = 3,
           end_lnum = 0,
           col = 0,
           end_col = 10,
           message = "",
           source = "my example plugin",
           severity = vim.diagnostic.severity.OK,
        }
    }

    local bufnr = nil
    local opts = nil
    vim.diagnostic.set(M.ns, bufnr or 0, diag, opts or {})
end

return M
