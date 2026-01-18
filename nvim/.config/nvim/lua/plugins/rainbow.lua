return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost", -- 打开文件后加载
    config = function()
      -- 这里可以配置具体的颜色，通常默认就很好看了
      -- 它会自动支持 Treesitter 解析的语言
    end,
  }
}
