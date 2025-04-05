return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                pylsp = {
                    settings = {
                        pylsp = {
                            plugins = {
                                pycodestyle = {
                                    ignore = { "E501" },
                                },
                            },
                        },
                    },
                },
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "off",
                            },
                        },
                    },
                },
            },
        },
    },
}
