local curl = require("plenary.curl")

local function get_cursor_url()
    local url = vim.fn.expand("<cWORD>")
    local cleaned_url = url:match("^(.-)[%p%s]*$")
    return cleaned_url
end

local function get_html_content(url)
    return curl.get(url).body
end

local function extract_title(html)
    local title = html:match("<title.->(.-)</title>")
    return title and title:gsub("%s+", " ") or ""
end

local function replace_url_with_markdown()
    local url = get_cursor_url()
    if url:match("^https?://") then
        local html_content = get_html_content(url)
        if html_content then
            local title = extract_title(html_content)
            if title and #title > 0 then
                local markdown = string.format("[%s](%s)", title, url)
                vim.cmd("normal! ciW" .. markdown)
            else
                print("Failed to extract title from the URL")
            end
        else
            print("Failed to fetch content from the URL")
        end
    else
        print("Cursor is not at a valid URL")
    end
end

vim.keymap.set("n", "<leader>cu", replace_url_with_markdown, { desc = "URL to Markdown" })

return {}
