-- Completion capabilities
local ok, blink = pcall(require, "blink.cmp")
if ok then
	vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
end

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		-- lets clangd ask the project's cross-compiler (ESP, ARM) for its include paths
		"--query-driver=/nix/store/*/bin/*gcc*,/nix/store/*/bin/*g++*",
	},
})

vim.lsp.config("lua_ls", {
	settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false } } },
})

vim.lsp.enable({ "clangd", "nixd", "lua_ls", "pyright", "ruff", "bashls", "taplo" })

vim.diagnostic.config({ virtual_text = { spacing = 2 }, severity_sort = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLsp", { clear = true }),
	callback = function(ev)
		local function m(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
		end
		m("gd", vim.lsp.buf.definition, "Go to definition")
		m("gD", vim.lsp.buf.declaration, "Go to declaration")
		m("<leader>ca", vim.lsp.buf.code_action, "Code action")
		m("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
	end,
})
