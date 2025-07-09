return {
    "nvim-neotest/neotest",
    opts = {
        adapters = {
            ["neotest-python"] = {
                args = { "-vvv" },
            },
        },
    },
}
