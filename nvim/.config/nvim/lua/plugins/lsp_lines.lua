return {
  {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    config = function()
      require("lsp_lines").setup()

      -- 配置诊断显示方式
      vim.diagnostic.config({
        virtual_text = false, -- 关掉行尾原本的提示，不然太乱
        virtual_lines = true, -- 开启下方的虚拟行提示
      })

      -- 可选：按 <leader>l 切换开关（有时候报错太多想清静一下）
      vim.keymap.set(
        "",
        "<leader>l",
        require("lsp_lines").toggle,
        { desc = "Toggle LSP Lines" }
      )
    end,
  },
}
