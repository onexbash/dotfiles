-- |   COLOR UTILITY   | --

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Reads $XDG_CONFIG_HOME/themes/color_palette.json
--
-- USAGE:
--   local c = require("utils.colors")
--   c.hex("white")          --> "#cdd6f4"
--   c.hex("white", 0.1)     --> "#cdd6f41a"
--   c.oklch("white", 0.1)   --> "oklch(87.87% 0.0426 272.28 / 0.1)"
--   c.rgb("white", 0.1)     --> "rgba(205, 214, 244, 0.1)"
--   c.hsl("white", 0.1)     --> "hsla(226.2, 63.9%, 88.0%, 0.1)"
--   c.color("white", 0.1)   --> same as the function for the configured color_format-
--
-- SETUP:
--   require("utils.colors").setup({
--     theme = "catppuccin-mocha",
--     color_format = "hex",                          -- hex | oklch | rgb | hsl
--     highlights = { CursorLineNr = { fg = "purple", bold = true } },
--   })
--
-- USAGE:
--   local c = require("utils.colors")
--
--   require("module").setup({
--     some_field = c.hex("white")
--     some_field_oklch = c.oklch("white")
--     some_field_with_opacity = c.hex("white", 0.1)
--   })
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local M = {}

local config = {
	theme = "catppuccin-mocha",
	color_format = "hex",
	highlights = {}, -- { Group = { fg = "<name|#hex|NONE>", bg = ..., sp = ..., bold = true } } or function(c)
}

-- Every theme must define these (hex + oklch); rgb and hsl are optional.
local NAMES = {
	"beige",
	"beige_light",
	"pink",
	"purple",
	"light_purple",
	"red",
	"red_light",
	"orange",
	"yellow",
	"green",
	"teal",
	"cyan",
	"light_blue",
	"blue",
	"white",
	"black",
	"gray",
	"light_gray_1",
	"light_gray_2",
	"light_gray_3",
	"light_gray_4",
	"light_gray_5",
	"dark_gray_1",
	"dark_gray_2",
	"dark_gray_3",
	"dark_gray_4",
	"dark_gray_5",
}
local FORMATS = { hex = true, rgb = true, hsl = true, oklch = true }

local colors = {} -- name -> { hex, oklch, rgb?, hsl? } for the active theme

local function fail(msg)
	error("[utils.colors] " .. msg, 0)
end

local function lookup(name, field)
	local c = colors[name] or fail(("unknown color '%s'"):format(tostring(name)))
	return c[field] or fail(("'%s' has no %s value in the palette"):format(name, field))
end

local function check_alpha(a)
	if a ~= nil and (type(a) ~= "number" or a < 0 or a > 1) then
		fail(("alpha must be a number between 0 and 1, got %s"):format(tostring(a)))
	end
	return a
end

-- ── Public color functions ──────────────────────────────────────────────────

function M.hex(name, alpha)
	local hex = lookup(name, "hex"):lower()
	if not check_alpha(alpha) then
		return hex
	end
	return hex .. ("%02x"):format(math.floor(alpha * 255 + 0.5))
end

function M.oklch(name, alpha)
	local v = lookup(name, "oklch")
	local s = ("%.2f%% %.4f %.2f"):format(v.l * 100, v.c, v.h)
	if not check_alpha(alpha) then
		return ("oklch(%s)"):format(s)
	end
	return ("oklch(%s / %.3g)"):format(s, alpha)
end

function M.rgb(name, alpha)
	local v = lookup(name, "rgb")
	if not check_alpha(alpha) then
		return ("rgb(%d, %d, %d)"):format(v.r, v.g, v.b)
	end
	return ("rgba(%d, %d, %d, %.3g)"):format(v.r, v.g, v.b, alpha)
end

function M.hsl(name, alpha)
	local v = lookup(name, "hsl")
	local s = ("%.1f, %.1f%%, %.1f%%"):format(v.h, v.s * 100, v.l * 100)
	if not check_alpha(alpha) then
		return ("hsl(%s)"):format(s)
	end
	return ("hsla(%s, %.3g)"):format(s, alpha)
end

--- Color in the configured color_format.
function M.color(name, alpha)
	return M[config.color_format](name, alpha)
end

-- ── Loading ─────────────────────────────────────────────────────────────────

local function load()
	if not FORMATS[config.color_format] then
		fail(("unknown color_format '%s' (hex, rgb, hsl, oklch)"):format(tostring(config.color_format)))
	end

	local path = (vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")) .. "/themes/color_palette.json"
	local file = io.open(path, "r") or fail("palette file not found: " .. path)
	local ok, data = pcall(vim.json.decode, file:read("*a"))
	file:close()
	if not ok or type(data) ~= "table" then
		fail("invalid JSON in " .. path)
	end

	local theme = data[config.theme]
	if type(theme) ~= "table" or type(theme.colors) ~= "table" then
		fail(("theme '%s' not found in %s"):format(config.theme, path))
	end

	local missing = {}
	for _, name in ipairs(NAMES) do
		local c = theme.colors[name]
		if type(c) ~= "table" or type(c.hex) ~= "string" or type(c.oklch) ~= "table" then
			missing[#missing + 1] = name
		end
	end
	if #missing > 0 then
		fail(("theme '%s' is missing hex/oklch for: %s"):format(config.theme, table.concat(missing, ", ")))
	end

	colors = theme.colors
	if config.color_format ~= "hex" then
		for _, name in ipairs(NAMES) do
			M.color(name)
		end -- fail early if rgb/hsl values are missing
	end
end

-- ── Highlight overrides ─────────────────────────────────────────────────────

-- Palette names become hex; "#hex" and "NONE" pass through.
local function resolve(v)
	if type(v) ~= "string" or v == "NONE" or v:sub(1, 1) == "#" then
		return v
	end
	return M.hex(v)
end

--- Note: nvim_set_hl replaces the whole group, so give the full definition.
function M.apply_highlights()
	local groups = config.highlights
	if type(groups) == "function" then
		groups = groups(M)
	end
	for group, spec in pairs(groups or {}) do
		local hl = vim.deepcopy(spec)
		hl.fg, hl.bg, hl.sp = resolve(hl.fg), resolve(hl.bg), resolve(hl.sp)
		vim.api.nvim_set_hl(0, group, hl)
	end
end

function M.setup(opts)
	for k, v in pairs(opts or {}) do
		if config[k] == nil then
			fail(("unknown option '%s'"):format(tostring(k)))
		end
		config[k] = v
	end
	load()
	M.apply_highlights()
	-- :colorscheme resets highlights, so re-apply the overrides afterwards
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("utils.colors", { clear = true }),
		callback = function()
			M.apply_highlights()
		end,
	})
	return M
end

load() -- defaults, so any file can require this module even without setup()
return M
