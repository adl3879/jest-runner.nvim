local M = {}

M.ns = nil

local severity_levels = { Error = 1, Success = 2 }
local sign_names = {
    { "JestRunnerSignError", "JestRunnerLspDiagnosticError" },
    { "JestRunnerSignSuccess", "JestRunnerLspDiagnosticSuccess" },
}

local links = {
    JestRunnerLspDiagnosticError = "DiagnosticError",
    JestRunnerLspDiagnosticSuccess = "DiagnosticSuccess",
}

local function add_sign(linenr, severity)
    local buf = nil
    if not vim.api.nvim_buf_is_valid(buf or 0) or not vim.api.nvim_buf_is_loaded(buf or 0) then
        return
    end
    local sign_name = sign_names[severity][1]
    vim.fn.sign_place(0, M.ns, sign_name, buf or "", { lnum = linenr, priority = 2 })
end

function M.setup(opts)
    M.ns = vim.api.nvim_create_namespace("my_example_plugin")

    -- disable signs in diagnostics
    vim.diagnostic.config({
        signs = false,
    }, M.ns)

    vim.fn.sign_define(sign_names[1][1], { text = opts.sign.error or "L", texthl = sign_names[1][2] })
    vim.fn.sign_define(sign_names[2][1], { text = opts.sign.success or "W", texthl = sign_names[2][2] })

    for lhs, rhs in pairs(links) do
        vim.cmd("hi def link " .. lhs .. " " .. rhs)
    end
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
            severity = severity_levels.Success
        else
            severity = severity_levels.Error
            message = data["failureMessages"][1]
        end

        local diag = {
            lnum = line_number - 1,
            end_lnum = 0,
            col = 0,
            end_col = 20,
            message = message,
            source = data["ancestorTitles"][1],
        }
        table.insert(diagnostics, diag)
        add_sign(line_number, severity)
    end

    return diagnostics
end

function M.show_diagnostics(test_data)
    local diag = M.parse_diagnostics(test_data)

    local bufnr = nil
    local opts = nil
    vim.diagnostic.set(M.ns, bufnr or 0, diag, opts or {})
end

function M.clear()
    vim.diagnostic.reset()
end

return M
