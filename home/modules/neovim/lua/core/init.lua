local function load(module)
	local ok, specification = pcall(require, module)
	if not ok then
		vim.notify("Packages failed to load: " .. module .. "\n" .. specification, vim.log.levels.ERROR)
		return
	end

	vim.notify("packages loaded: " .. module, vim.log.levels.INFO)
end

-- Shared dependencies

local source = debug.getinfo(1, "S").source:sub(2)
local dir = vim.fs.dirname(source)
for name, type in vim.fs.dir(dir) do
	if type == "file" then
		local package = name:gsub("%.lua$", "")

		if package ~= "init" then
			load("core." .. package)
		end
	end
end
