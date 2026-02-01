local opt = vim.opt

-- Line number
opt.number = true
opt.relativenumber = true

-- Tab/Indent
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- UI
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.signcolumn = "yes"

-- File
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Clipboard
opt.clipboard = "unnamedplus"

-- Split
opt.splitright = true
opt.splitbelow = true

-- Etc
opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 500

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keymap
local keymap = vim.keymap.set

-- General
keymap("n", "<leader>w", ":w<CR>", { desc = "Save" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Quit all without saving" })

-- Remove search highlights
keymap("n", "<Esc>", ":noh<CR>", { silent = true })

-- Move windows
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Adjust windows
keymap("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move buffers
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Explorer
keymap("n", "<leader>e", vim.cmd.Ex, { desc = "File explorer" })

-- Indent in visual mode
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")

-- Move lines in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Scrolling
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- Paste without yanking
keymap("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- Copy to clipboard
keymap("n", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap("v", "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap("n", "<leader>Y", '"+Y', { desc = "Copy line to system clipboard" })

-- Replace
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor" })

-- AutoCmd
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Change indent with file types
local tabstop_group = augroup("TabstopByFileType", { clear = true })
autocmd("FileType", {
    group = tabstop_group,
    pattern = { "lua", "javascript", "typescript", "json", "html", "css", "yaml" },
    callback = function()
        opt.shiftwidth = 2
        opt.tabstop = 2
        opt.softtabstop = 2
    end,
})

-- Remove trailing whitespace when saving
autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- Move to recent pos when opening
autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.cmd('normal! g`"')
        end
    end,
})

-- netrw
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

-- Show Cmd
opt.showcmd = true
opt.showmode = true

-- Status
opt.laststatus = 2
opt.showmode = false
vim.o.statusline = "%f %m %r%= %{mode()} %l/%L:%c %p%%"

-- lazy.nvim Setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Colorscheme (Material Darker)
require("lazy").setup({
    {
        "marko-cerovac/material.nvim",
        config = function ()
            vim.g.material_style = "darker"
            vim.cmd("colorscheme material")            
        end,
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 500,
        },
        config = function(_, opts)
            local wk = require("which-key")
            wk.setup(opts)
            wk.add({
                { "<leader>w", desc = "Save" },
                { "<leader>q", desc = "Quit" },
                { "<leader>x", desc = "Save & Quit" },
                { "<leader>Q", desc = "Quit all without saving" },
                { "<leader>e", desc = "File explorer" },
                { "<leader>s", desc = "Replace word under cursor" },
                { "<leader>b", group = "Buffer" },
                { "<leader>bd", desc = "Delete buffer" },
                { "<leader>y", group = "Yank to clipboard" },
                { "<leader>p", desc = "Paste without yanking" },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua",
                    "python",
                    "c",
                    "cpp",
                    "c_sharp",
                    "fsharp",
                    "bash",
                    "json",
                    "yaml",
                    "toml",
                    "markdown",
                    "markdown_inline",
                    "vim",
                    "vimdoc",
                    "regex",
                    "javascript",
                    "typescript",
                },

                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },

                indent = {
                    enable = true,
                },

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        node_incremental = "<CR>",
                        scope_incremental = "<S-CR>",
                        node_decremental = "<BS>",
                    },
                },
            })
        end,
    },
})