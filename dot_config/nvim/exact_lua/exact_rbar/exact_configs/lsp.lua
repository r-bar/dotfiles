-- LSP server integration

---@class M ConfigPkg
local M = {}
local lsp_flags = {}
local helpers = require("rbar/helpers")

local serverity_map = {
	"DiagnosticError",
	"DiagnosticWarn",
	"DiagnosticInfo",
	"DiagnosticHint",
}
local icon_map = {
	"  ",
	"  ",
	"  ",
	"  ",
}
------------------------------------------------------------------------------
-- Semantic token legend
-- Must match the tokenTypes / tokenModifiers declared in cuda_bun_lsp's
-- initialize request (lsp_client.py SemanticTokensManager.TOKEN_TYPES /
-- TOKEN_MODIFIERS) so the client can interpret the indices correctly.
------------------------------------------------------------------------------

-- Token type name -> index in the legend list sent to the client.
-- selfParameter and clsParameter extend the standard LSP legend so that
-- the semantictokens.py client can apply distinct colors to self/cls.
local _ST_TOKEN_TYPES = {
	namespace = 0,
	type = 1,
	class = 2,
	enum = 3,
	interface = 4,
	struct = 5,
	typeParameter = 6,
	parameter = 7,
	variable = 8,
	property = 9,
	enumMember = 10,
	event = 11,
	["function"] = 12,
	method = 13,
	macro = 14,
	keyword = 15,
	modifier = 16,
	comment = 17,
	string = 18,
	number = 19,
	regexp = 20,
	operator = 21,
	decorator = 22,
	selfParameter = 23, -- Python self -- distinct from regular parameter
	clsParameter = 24, -- Python cls -- distinct from regular parameter
}

-- Token modifier name -> bit index
local _ST_TOKEN_MODIFIERS = {
	declaration = 0,
	definition = 1,
	readonly = 2,
	static = 3,
	deprecated = 4,
	abstract = 5,
	async = 6,
	modification = 7,
	documentation = 8,
	defaultLibrary = 9,
	-- Extensions matching basedpyright's legend for accurate cross-server parity
	builtin = 10, -- builtins-module symbols (subset of defaultLibrary)
	classMember = 11, -- methods/properties declared inside a class body
	parameter = 12, -- applied to parameter/selfParameter/clsParameter tokens
}

local function python_type_checker()
	local env = require("rbar/environment")
	return env.PYTHON_TYPE_CHECKER or "ty"
end

local function source_string(source, code)
	if code then
		return string.format("  [%s %s]", source, code)
	else
		return string.format("  [%s]", source)
	end
end

function M.line_diagnostics()
	local bufnr, lnum = unpack(vim.fn.getcurpos())
	local diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum - 1 })
	if vim.tbl_isempty(diagnostics) then
		return
	end

	local lines = {}
	local highlights = {}

	for _, diagnostic in ipairs(diagnostics) do
		local prefix = icon_map[diagnostic.severity] .. " "
		local source = source_string(diagnostic.source, diagnostic.code)
		local message_lines = vim.split(diagnostic.message, "\n", { plain = true, trimempty = false })

		if #message_lines == 0 then
			message_lines = { "" }
		end

		for i, message_line in ipairs(message_lines) do
			local is_last = i == #message_lines
			local line_prefix = (i == 1) and prefix or string.rep(" ", #prefix)
			local line = line_prefix .. message_line

			if is_last then
				line = line .. source
			end

			table.insert(lines, line)
			table.insert(highlights, {
				severity = diagnostic.severity,
				source_start = is_last and (#line - #source) or nil,
			})
		end
	end

	local ns = vim.api.nvim_create_namespace("line_diagnostics")
	local floating_bufnr, _ = vim.lsp.util.open_floating_preview(lines, "plaintext", {
		border = vim.g.floating_window_border_dark,
		focus_id = "line",
	})

	for i, highlight in ipairs(highlights) do
		local line = i - 1
		local line_length = #lines[i]
		vim.api.nvim_buf_set_extmark(floating_bufnr, ns, line, 0, {
			end_row = line,
			end_col = line_length,
			hl_group = serverity_map[highlight.severity],
		})
		if highlight.source_start then
			vim.api.nvim_buf_set_extmark(floating_bufnr, ns, line, highlight.source_start, {
				end_row = line,
				end_col = line_length,
				hl_group = "DiagnosticSource",
			})
		end
	end
end

-- order is important. these mason setup calls must be done before lspconfig
-- servers are configured
local function mason_ensure_installed()
	local ensure_installed = {
		"bashls",
		"docker_compose_language_service",
		"cssls",
		"dockerls",
		"html",
		"jsonls",
		"jsonnet_ls",
		"lua_ls",
		"marksman",
		"pylsp",
		"sqlls",
		"ts_ls",
		"tailwindcss",
		"vimls",
		"yamlls",
	}

	if vim.fn.executable("nix") == 1 then
		table.insert(ensure_installed, "nil_ls")
		table.insert(ensure_installed, "rnix")
	end

	if
		vim.fn.executable("ansible") == 1
		and vim.fn.executable("ansible-lint") == 1
		and vim.fn.executable("ansible-config") == 1
	then
		table.insert(ensure_installed, "ansiblels")
	end

	return ensure_installed
end

function M.go_to_definition(list)
	local item = list.items[1]
	vim.cmd.edit(item.filename)
	vim.fn.setcursorcharpos(item.lnum, item.col)
end

local function on_attach(client, bufnr)
	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local function bufopts(kwargs)
		local opts = { noremap = true, silent = true, buffer = bufnr }
		if kwargs then
			vim.tbl_extend("force", opts, kwargs)
		end
		return opts
	end
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts({ desc = "[LSP] Go to declaration" }))
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts({ desc = "[LSP] Go to definition" }))
	--vim.keymap.set('n', 'gv', ":vsplit<cr>gd", bufopts { desc = "[LSP] Go to definition in new vsplit" })
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts({ desc = "[LSP] Show hover info" }))
	vim.keymap.set(
		"n",
		"<leader>wa",
		vim.lsp.buf.add_workspace_folder,
		bufopts({ desc = "[LSP] Add workspace folder" })
	)
	vim.keymap.set(
		"n",
		"<leader>wr",
		vim.lsp.buf.remove_workspace_folder,
		bufopts({ desc = "[LSP] Remove workspace folder" })
	)
	vim.keymap.set("n", "<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts({ desc = "[LSP] List workspace folders" }))
	vim.keymap.set("n", "<leader>ff", function()
		vim.lsp.buf.format({ async = true })
	end, bufopts({ desc = "[LSP] Format file" }))

	-- disable semantic token highlighting
	client.server_capabilities.semanticTokensProvider = nil
end

function M.global_bindings()
	local default_opts = { noremap = true, silent = true }
	local function opts(extra)
		return vim.tbl_extend("force", default_opts, extra or {})
	end
	--vim.keymap.set(
	--  "n",
	--  "<leader>e",
	--  vim.diagnostic.open_float,
	--  opts({ desc = "[LSP] Show diagnostic error in floating window" })
	--)
	vim.keymap.set(
		"n",
		"<leader>e",
		M.line_diagnostics,
		opts({ desc = "[LSP] Show diagnostic error in floating window" })
	)
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, opts({ desc = "[LSP] Jump to prev diagnostic error" }))
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, opts({ desc = "[LSP] Jump to next diagnostic error" }))
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts({ desc = "[LSP] Show buffer diagnostic errors" }))
end

local function default_server_settings()
	return {
		capabilities = vim.lsp.protocol.make_client_capabilities(),
		on_attach = on_attach,
		flags = lsp_flags,
	}
end

---@class AttachHelperOpts
---@field capabilities_overrides table? optional table of server_capabilities to override
---@field before fun(client: vim.lsp.Client, buffer: integer)? optional function to run before other helpers on attach
---@field after fun(client: vim.lsp.Client, buffer: integer)? optional function to run after other helpers on attach

---@param opts AttachHelperOpts
local function attach_helper(opts)
	local opts = opts or {}
	local function callback(client, buffer)
		if opts.before ~= nil then
			opts.before(client, buffer)
		end
		if opts.capabilities_overrides ~= nil then
			client.server_capabilities =
				vim.tbl_extend("force", client.server_capabilities, opts.capabilities_overrides)
		end
		if opts.after ~= nil then
			opts.after(client, buffer)
		end
	end
	return callback
end

local function with_defaults(custom)
	if custom == nil then
		return default_server_settings()
	end
	return vim.tbl_extend("force", default_server_settings(), custom)
end

local function server_settings()
	local settings = {}

	-- Prefer the nearest ancestor with python config over the git root, so
	-- projects nested in a monorepo (e.g. www) become the workspace root and
	-- imports resolve relative to them.
	local python_root_markers = { { "mypy.ini", "setup.cfg", "pyproject.toml" }, ".git" }

	settings["gleam"] = with_defaults()

	settings["lua_ls"] = with_defaults({
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
			},
		},
	})

	settings["tailwindcss"] = with_defaults({
		filetypes = {
			"aspnetcorerazor",
			"astro",
			"astro-markdown",
			"blade",
			"clojure",
			"django-html",
			"htmldjango",
			"edge",
			"eelixir",
			"elixir",
			"ejs",
			"erb",
			"eruby",
			"gohtml",
			"haml",
			"handlebars",
			"hbs",
			"html",
			"html-eex",
			"heex",
			"jade",
			"leaf",
			"liquid",
			"markdown",
			"mdx",
			"mustache",
			"njk",
			"nunjucks",
			"php",
			"razor",
			"slim",
			"twig",
			"css",
			"less",
			"postcss",
			"sass",
			"scss",
			"stylus",
			"sugarss",
			"javascript",
			"javascriptreact",
			"reason",
			"rescript",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
			"templ",
			"jinja.html",
			"html.jinja",
		},
	})

	if false and vim.fn.executable("opam") == 1 then
		settings["ocamllsp"] = with_defaults()
	end

	settings["pylsp"] = with_defaults({
		-- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
		--on_attach = function(client, bufnr)
		--  -- https://neovim.discourse.group/t/preserve-internal-formatting-when-using-gq-motion/3159/2
		--  vim.opt.formatexpr = ""
		--end,
		on_attach = attach_helper({
			capabilities_overrides = {
				-- pylsp-workspace-symbols server capabilities overrides. The monkey
				-- patch within the plug currently is not effective.
				workspaceSymbolProvider = true,
				inlayHintProvider = {
					resolveProvider = false,
					workDoneProgress = true,
				},
				callHierarchyProvider = true,
				typeHierarchyProvider = true,
				documentLinkProvider = {
					resolveProvider = false,
				},
				colorProvider = true,
				codeLensProvider = {
					resolveProvider = true,
				},
				documentOnTypeFormattingProvider = {
					firstTriggerCharacter = "\n",
					moreTriggerCharacter = { ":", "{", "#", ")", "]", "}", '"' },
				},
				-- not dealing with commands for now
				-- see: https://github.com/Hanatarou/pylsp-workspace-symbols/blob/ea8defcbcc80913ad8f455749653bacecadd2da3/pylsp_workspace_symbols/plugin.py#L102-L111
				-- executeCommandProvider = ...,
				semanticTokensProvider = {
					legend = {
						tokenTypes = vim.tbl_keys(_ST_TOKEN_TYPES),
						tokenModifiers = vim.tbl_keys(_ST_TOKEN_MODIFIERS),
					},
					full = { delta = true },
					range = true,
				},
			},
		}),
		force_setup = true,
		root_markers = python_root_markers,
		settings = {
			pylsp = {
				configurationSources = {
					"pycodestyle",
					"pydocstyle",
					"rope",
					"mccabe",
					--'black',
					"flake8",
					"pylint",
					"isort",
					"pylsp_rope",
				},
				plugins = {
					black = { enabled = false },
					rope = { enabled = true },
					pylsp_mypy = { enabled = python_type_checker() == "mypy" },
					-- lints generally covered by black and ruff while being less configurable
					pyflakes = { enabled = false },
					flake8 = { enabled = false },
					pycodestyle = { enabled = false },
					-- moved to its own lsp server
					--ruff = {
					--  enabled = true,       -- Enable the plugin
					--  formatEnabled = true, -- Enable formatting using ruffs formatter
					--  format = { "I" },     -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
					--  unsafeFixes = false,  -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action

					--  -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
					--  lineLength = 88,                                 -- Line length to pass to ruff checking and formatting
					--  perFileIgnores = { ["__init__.py"] = "CPY001" }, -- Rules that should be ignored for specific files
					--  preview = false,                                 -- Whether to enable the preview style linting and formatting.
					--  targetVersion = "py310",                         -- The minimum python version to target (applies for both lint and format)
					--}

					-- pylsp-workspace-symbols based plugins
					jedi_workspace_symbols = {
						enabled = true,
						max_symbols = 500,
						-- ignore_folders = {},
					},
					inlay_hints = {
						enabled = true,
						show_assign_types = true,
						show_return_types = true,
						show_raises = true,
						show_parameter_hints = true,
						max_hints_per_file = 200,
					},
					code_lens = {
						enabled = true,
						show_references = true,
						show_implementations = true,
						cross_file_implementations = false,
						show_run = true,
						show_tests = true,
						max_definitions = 150,
					},
					semantic_tokens = {
						enabled = false,
					},
					call_hierarchy = {
						enabled = true,
					},
					type_hierarchy = {
						enabled = true,
					},
					document_links = {
						enabled = true,
					},
					document_colors = {
						enabled = true,
					},
					on_type_formatting = {
						enabled = true,
						indent_size = 4,
						dedent_keywords = true,
						colon_dedent = true,
						colon_space = true,
						bracket_indent = true,
						auto_format_strings = true,
						hash_space = true,
						auto_docstring = true,
						closer_align = true,
						debug = false,
					},
				},
			},
		},
	})

	if vim.fn.executable("ty") and python_type_checker() == "ty" then
		settings["ty"] = with_defaults({
			root_markers = python_root_markers,
			-- These capabilities conflict with pylsp
			on_attach = attach_helper({
				capabilities_overrides = {
					completionProvider = false,
					definitionProvider = false,
					implementationProvider = false,
					referencesProvider = false,
					renameProvider = false,
				},
			}),
		})
	end

	if vim.fn.executable("pylsp") == 1 then
		settings.pylsp.cmd = { "pylsp" }
	end

	if vim.fn.executable("ruff") then
		settings["ruff"] = with_defaults({
			root_markers = python_root_markers,
		})
	end

	settings["roc_ls"] = with_defaults({
		cmd = { "roc", "experimental-lsp" },
		filetypes = { "roc" },
		root_dir = helpers.root_pattern_or_cwd("roc.toml", ".git"),
		docs = {
			description = [[
The Roc language server

Comes by default with the roc programming language, currently under the `experimental-lsp` subcommand.

https://github.com/roc-lang/roc/blob/main/src/lsp/README.md
]],
		},
	})

	settings["rust_analyzer"] = with_defaults({
		settings = {
			["rust-analyzer"] = {
				cargo = { loadOutDirsFromCheck = true },
				procMacro = { enable = true },
				updates = { channel = "nightly" },
				checkOnSave = true,
				diagnostics = { experimental = { enable = true } },
			},
		},
	})

	-- https://github.com/vlang/vls
	settings["vls"] = with_defaults({
		cmd = { "v", "ls" },
		filetypes = { "vlang" },
		root_dir = helpers.root_pattern(".git"),
		docs = {
			description = [[
https://github.com/vlang/vls

The V language server can be installed via `v ls --install`.

The official V language server, written in V itself.
]],
		},
	})

	settings["rescriptls"] = with_defaults()

	settings["ols"] = with_defaults()

	settings["mojo"] = with_defaults()

	settings["zls"] = with_defaults()

	if vim.fn.executable("clangd") == 1 then
		settings["clangd"] = with_defaults()
	end

	return settings
end

function M.packages(use)
	use("neovim/nvim-lspconfig")
	use({ "williamboman/mason.nvim", version = "^2.0.0", opts = { PATH = "append" } })
	use({
		"williamboman/mason-lspconfig.nvim",
		version = "^2.0.0",
		opts = { ensure_installed = mason_ensure_installed() },
	})
	-- gives a nice live lsp status message in the bottom right corner
	use({ "j-hui/fidget.nvim", opts = {} })

	use({
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	})
	use({
		"nvimtools/none-ls.nvim",
		config = function(_, opt)
			local null_ls = require("null-ls")

			-- Asks the mypy daemon for the type of the expression under the cursor,
			-- like a reveal_type() without editing the buffer. The daemon must be
			-- running with exported types (`dmypy run --export-types -- <path>`),
			-- and it inspects the file on disk, so unsaved changes are invisible.
			local dmypy_inspect = {
				name = "dmypy_inspect",
				method = null_ls.methods.HOVER,
				filetypes = { "python" },
				generator = {
					async = true,
					fn = function(params, done)
						-- dmypy wants 1-based columns; params.col is 0-based
						local position = string.format("%d:%d", params.row, params.col + 1)

						local function render(result)
							if result.code ~= 0 then
								local err = vim.trim((result.stderr ~= "" and result.stderr or result.stdout) or "")
								done({ "dmypy inspect failed: " .. err })
								return
							end
							local lines = { "```python", vim.trim(result.stdout), "```" }
							if vim.api.nvim_get_option_value("modified", { buf = params.bufnr }) then
								table.insert(lines, "*(buffer modified — dmypy sees the file on disk)*")
							end
							done(lines)
						end

						local function inspect(path, on_done)
							vim.system(
								{ "dmypy", "inspect", "--show", "type", path .. ":" .. position },
								{ text = true },
								vim.schedule_wrap(on_done)
							)
						end

						-- the path must match how the daemon saw the file when it was
						-- checked, so retry with the cwd-relative form if the absolute
						-- one is unknown to it
						inspect(params.bufname, function(result)
							local relative = vim.fn.fnamemodify(params.bufname, ":.")
							local output = (result.stdout or "") .. (result.stderr or "")
							if output:find("Unknown module") and relative ~= params.bufname then
								inspect(relative, render)
							else
								render(result)
							end
						end)
					end,
				},
			}

			local sources = {
				null_ls.builtins.completion.spell,
				-- moved from none-ls builtins to none-ls-extras
				require("none-ls.formatting.jq"),
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.hover.dictionary,
			}
			if python_type_checker() == "mypy" then
				table.insert(sources, dmypy_inspect)
			end

			null_ls.setup(vim.tbl_extend("error", opt, { sources = sources }))
		end,
		dependencies = { "nvimtools/none-ls-extras.nvim" },
	})
end

function M.config()
	local LSP_LOG_LEVEL = require("rbar/environment").LSP_LOG_LEVEL
	-- lsp debug logging
	-- clear the lsp log before every session
	vim.fn.system("rm $HOME/.local/state/nvim/lsp.log")
	vim.lsp.log.set_level(LSP_LOG_LEVEL or "warn")

	vim.api.nvim_create_user_command("Format", function()
		vim.lsp.buf.format({ async = false })
	end, {})
	vim.api.nvim_create_user_command("LspDiagnostics", function()
		vim.diagnostic.setqflist()
	end, {})
	vim.api.nvim_create_user_command("LspAttached", function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients == 0 then
			vim.notify("No LSP servers attached to current buffer", vim.log.levels.INFO)
			return
		end

		local names = {}
		for _, client in ipairs(clients) do
			table.insert(names, client.name)
		end
		table.sort(names)

		vim.notify("Attached LSPs: " .. table.concat(names, ", "), vim.log.levels.INFO)
	end, { desc = "List LSP servers attached to current buffer" })
	--vim.api.nvim_create_user_command(
	--  "LspRestart",
	--  function()
	--    vim.lsp.buf.clear_references()
	--    vim.lsp.stop_client(vim.lsp.get_clients())
	--    vim.cmd [[edit]]
	--  end,
	--  {}
	--)

	M.global_bindings()

	for name, settings in pairs(server_settings()) do
		vim.lsp.config(name, settings)
		vim.lsp.enable(name)
	end
end

return M
