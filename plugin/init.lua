local runner = require("jest-runner")

vim.api.nvim_create_user_command("JestRunFile", function ()
   runner.create_run_command("file")
end, {})

vim.api.nvim_create_user_command("JestRunTest", function ()
   runner.create_run_command("all")
end, {})

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = "*.test.ts",
    callback = function()
        runner.run_diagnostics()
    end
})

-- create autocmd for when i leave a test file
vim.api.nvim_create_autocmd({"BufLeave"}, {
    pattern = "*.test.ts",
    callback = function()
        runner.clear()
    end
})

-- run diagnostics when i save a test file
vim.api.nvim_create_autocmd({"BufWritePost"}, {
    pattern = "*.test.ts",
    callback = function()
        runner.run_diagnostics()
    end
})
