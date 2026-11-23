require("lazy").setup({
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},

	{ "lewis6991/gitsigns.nvim", opts = {} },

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>s", group = "search" },
				{ "<leader>r", group = "rust / run" },
				{ "<leader>d", group = "debug" },
				{ "<leader>t", group = "terminal / toggle" },
				{ "<leader>m", group = "make" },
				{ "<leader>n", group = "tests (neotest)" },
				{ "<leader>x", group = "diagnostics" },
				{ "<leader>c", group = "code / crates" },
			},
		},
	},

	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = { open_mapping = [[<C-\>]], direction = "float", float_opts = { border = "curved" } },
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons", -- optional, but recommended
		},
		lazy = false, -- neo-tree will lazily load itself
	},

	{
		"Crysthamus/nvim-file-operations",
		-- branch = "compat" -- if you are on Neovim <= 0.10
		dependencies = {
			"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
		},
		config = function()
			require("nvim-file-operations").setup()
		end,
	},

	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
		config = function()
			require("window-picker").setup({
				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					-- filter using buffer options
					bo = {
						-- if the file type is one of following, the window will be ignored
						filetype = { "neo-tree", "neo-tree-popup", "notify" },
						-- if the buffer type is one of following, the window will be ignored
						buftype = { "terminal", "quickfix" },
					},
				},
			})
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
			{
				"S",
				mode = { "n", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash treesitter",
			},
		},
	},

	{
		"stevearc/aerial.nvim",
		opts = {},
		keys = { { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Outline" } },
	},

	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"c",
				"cpp",
				"rust",
				"lua",
				"vim",
				"vimdoc",
				"cmake",
				"make",
				"toml",
				"ron",
				"json",
				"yaml",
				"markdown",
				"bash",
				"nix",
				"python",
				"regex",
				"diff",
				"gitcommit",
			})
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					if pcall(vim.treesitter.start, args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},

	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			["neo-tree"] = { event = "BufWipeout" },
			-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			-- animation = true,
			-- insert_at_start = true,
			-- …etc.
		},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
	},

	{ "neovim/nvim-lspconfig" },

	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = { preset = "enter" }, -- Enter accepts; "default" uses Ctrl+y
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			-- if it complains about its prebuilt library on NixOS, add:
			-- fuzzy = { implementation = "lua" },
		},
	},

	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		opts = {
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				python = { "ruff_format" },
				nix = { "nixfmt" },
				lua = { "stylua" },
				rust = { "rustfmt" },
			},
			format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>sf", "<cmd>Telescope find_files<CR>", desc = "Find files" },
			{ "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
			{ "<leader>sb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
			{ "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
		},
	},
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (project)" },
			{ "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics (buffer)" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols" },
			{ "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP references" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
		},
	},
	{
		"Civitasv/cmake-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "c", "cpp", "cmake" },
		opts = {
			cmake_build_directory = "build",
			cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
		},
		keys = {
			{ "<leader>mg", "<cmd>CMakeGenerate<CR>", desc = "CMake generate" },
			{ "<leader>mb", "<cmd>CMakeBuild<CR>", desc = "CMake build" },
			{ "<leader>mr", "<cmd>CMakeRun<CR>", desc = "CMake run" },
			{ "<leader>mt", "<cmd>CMakeSelectBuildType<CR>", desc = "CMake build type" },
		},
	},
	{ "mrcjkb/rustaceanvim", lazy = false }, -- pin its major version as its README says
	{ "saecki/crates.nvim", event = "BufRead Cargo.toml", opts = {} },
})
