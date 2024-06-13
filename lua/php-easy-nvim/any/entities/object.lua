local Config = require("php-easy-nvim.any.config")

local M = {}

function M.docBlock()
	vim.fn.setreg("p", "/**\n * \n */\n")
	vim.cmd([[
        normal "pPj
        startinsert!
    ]])
end

local function initObject(type)
	local json = require("php-easy-nvim.any.entities.json")
	-- prepare name and path
	local file = vim.fn.expand("%:t:r")
	local path = vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":~:.")

	-- find psr4 in composer.json
	local psr4 = {}
	local is_psr4 = false
	local composerPath = vim.fn.getcwd() .. "/composer.json", "r"
	local f = io.open(composerPath, "rb")
	local composerContentString = f:read("*all")
	f:close()

	local composerContent = json.decode(composerContentString)

	local psr4 = assert(composerContent.autoloadfoobar["psr-4"])
	vim.print(psr4)

	-- for line in io.lines(composerPath) do
	-- 	if line == "    }" then
	-- 		is_psr4 = false
	-- 	end
	--
	-- 	if is_psr4 then
	-- 		local parts = vim.split(vim.trim(line):gsub('[" ,]+', ""), ":")
	-- 		psr4[parts[1]:gsub("\\\\", "\\")] = parts[2]
	-- 	end
	--
	-- 	if line == '    "psr-4": {' then
	-- 		is_psr4 = true
	-- 	end
	-- end

	-- fix by psr4
	if vim.tbl_count(psr4) > 0 then
		for value, key in pairs(psr4) do
			path = string.gsub(path, key, value)
		end
	end

	-- fix slashes
	path = path:gsub("/", "\\")

	if vim.fn.search("^namespace ", "w") == 0 then
		-- empty file
		vim.cmd([[
            normal! i<?php
            normal! o
            normal! odeclare(strict_types=1);
            normal! o
            normal! onamespace ]] .. path .. [[;
            normal! o
            normal! o]] .. type .. [[ ]] .. file)
		vim.cmd([[
            normal! o{
            normal! o}
        ]])
		vim.fn.search(type .. " " .. file, "e")
	else
		-- fix exists data
		vim.cmd("normal! Cnamespace " .. path .. ";")
		vim.fn.search(Config.regex.object, "we")
		vim.cmd("normal! lcw" .. file)
	end
end

function M.initInterface()
	initObject("interface")
end

function M.initClass()
	initObject("class")
end

function M.initAbstractClass()
	initObject("abstract class")
end

function M.initTrait()
	initObject("trait")
end

function M.initEnum()
	initObject("enum")
end

return M
