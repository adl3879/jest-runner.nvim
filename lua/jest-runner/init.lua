local utils = require("jest-runner.utils")
local diagnostics = require("jest-runner.diagnostics")

local M = {
    test_data = {}
}

M.config = {
    jest_command = "jest",
    watch = true,
    signs = {
        error = "",
        success = "",
    },
    flags = {
        "--json",
        "--outputFile=jest-output.json",
    }
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
    diagnostics.setup({
        sign = M.config.signs,
    })
end

function M.create_run_command(type)
    local exists = vim.fn.filereadable(vim.fn.getcwd() .. "/package.json")
    if exists == 0 then
        vim.api.nvim_err_writeln("No package.json found")
        return
    end

    local current_file = vim.fn.expand("%:p")

    local is_test = string.find(current_file, "test")
    if is_test == nil and type == "file" then
        vim.api.nvim_err_writeln("Can only run tests from a test file")
        return
    end

    -- write running test in green
    utils.write_info("Running test...")

    -- check if it uses yarn
    vim.cmd("!jest " .. current_file)
end

function M.run_diagnostics()
    local is_test = string.find(vim.fn.expand("%:p"), "test")
    if is_test == nil then return end

    local output_file = "jest-output.json"
    local flags = " " .. table.concat(M.config.flags, " ")
    vim.fn.jobstart("jest " .. vim.fn.expand("%:p") .. flags, {
        on_exit = function()
            -- read output file
            local file = io.open(output_file, "r")
            if file ~= nil then
                local content = file:read("*all")
                local json = vim.fn.json_decode(content)
                M.test_data = json
                file:close()
            end

            -- remove output file
            vim.fn.delete(output_file)
            utils.write_info("Tests ran successfully!")

            M.diagnostics()
        end
    })
end

function M.diagnostics()
    diagnostics.show_diagnostics(M.test_data)
end

function M.clear()
    M.test_data = {}
    utils.write_info("")
    diagnostics.clear()
end

return M
