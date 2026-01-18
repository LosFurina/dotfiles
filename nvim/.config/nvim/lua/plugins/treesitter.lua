return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- 在 LazyVim 中，我们要修改配置，只需要写 opts
    -- LazyVim 会自动帮你调用 setup(opts)
    opts = {
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "query",
        "python", "javascript", "typescript", "go", "bash", "markdown"
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
