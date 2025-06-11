local function break_line_at_80()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    local cur_line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]
    local break_pos = 80

    -- If the line is shorter than the break position, do nothing
    if #cur_line <= break_pos then
        return
    end

    -- Find the position of the last whitespace before the break position
    local break_at = cur_line:sub(1, break_pos):reverse():find("%s")
    if break_at then
        break_at = break_pos - break_at + 1
    else
        break_at = break_pos
    end

    -- Split the line
    local new_cur_line = cur_line:sub(1, break_at):gsub("%s+$", "")
    local new_next_line = "  " .. cur_line:sub(break_at + 1):gsub("^%s+", "")

    -- Update the buffer
    vim.api.nvim_buf_set_lines(bufnr, line_num - 1, line_num, false, { new_cur_line, new_next_line })
    vim.api.nvim_win_set_cursor(0, { line_num + 1, 0 })
end

vim.keymap.set("n", "<leader>mb", break_line_at_80, { desc = "Break line at 80ish" })

return {}
