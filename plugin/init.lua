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
        runner.run_test_when_file_is_opened()
    end
})

