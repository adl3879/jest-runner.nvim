local M = {}

M.ns = nil

function M.setup()
    M.ns = vim.api.nvim_create_namespace("my_example_plugin")

    -- get the default diagnostic signs
    M.default_signs = vim.fn.sign_getdefined()

    vim.fn.sign_define("DiagnosticSignInfo", { text = "🟢", texthl = "DiagnosticSignInfo" })
    vim.fn.sign_define("DiagnosticSignError", { text = "🔴", texthl = "DiagnosticSignError" })
end

function M.parse_diagnostics(test_data)
    local diagnostics = {}
    local results = test_data["testResults"][1]["assertionResults"]

    for _, data in ipairs(results) do
        -- search file content by a string and return line numbers
        local line_number = vim.fn.search(data["title"], "nw")
        local severity = nil
        local message = nil
        if data["status"] == "passed" then
            severity = vim.diagnostic.severity.INFO
        else
            severity = vim.diagnostic.severity.ERROR
            message = data["failureMessages"][1]
        end

        local diag = {
            lnum = line_number - 1,
            end_lnum = 0,
            col = 0,
            end_col = 20,
            message = message,
            source = data["ancestorTitles"][1],
            severity = severity,
        }

        table.insert(diagnostics, diag)
    end

    return diagnostics
end

function M.show_diagnostics(test_data)
    -- logic for generating diagnostics
    local diag = M.parse_diagnostics(test_data)

    local bufnr = nil
    local opts = nil
    vim.diagnostic.set(M.ns, bufnr or 0, diag, opts or {})
end

function M.clear()
    -- set signs to default
    vim.fn.sign_define("DiagnosticSignInfo", M.default_signs[1])
    vim.fn.sign_define("DiagnosticSignError", M.default_signs[2])

    vim.diagnostic.reset()
end

return M
