local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim",                                import = "lazyvim.plugins" },
    -- 👇👇👇 在这里加入你需要开启的语言环境 👇👇👇

    -- 1. Python (自动装 pyright, ruff, black, debugpy)
    { import = "lazyvim.plugins.extras.lang.python" },

    -- 2. React/Frontend (自动装 tsserver/vtsls, prettier, eslint)
    { import = "lazyvim.plugins.extras.lang.typescript" },
    -- 如果你写 TailwindCSS，建议也加上这行：
    -- { import = "lazyvim.plugins.extras.lang.tailwind" },

    -- 3. Docker (自动装 dockerls, hadolint)
    { import = "lazyvim.plugins.extras.lang.docker" },

    -- 4. Kustomization/K8s (自动装 yaml-language-server, 识别 K8s Schema)
    { import = "lazyvim.plugins.extras.lang.yaml" },
    -- 建议加上 JSON 支持，很多配置也是 JSON
    { import = "lazyvim.plugins.extras.lang.json" },

    { import = "lazyvim.plugins.extras.coding.yanky" },

    { import = "lazyvim.plugins.extras.lang.markdown" },

    -- 👆👆👆 结束 👆👆👆

    -- 导入你自己的 lua/plugins 目录（保持这行在最后）
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  },                -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
