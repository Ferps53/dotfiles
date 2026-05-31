local function load(specifications, module)
  local ok, specification = pcall(require, module)
  if not ok then
    vim.notify("Packages failed to load: ".. module .. "\n".. specification, vim.log.levels.ERROR)
    return
  end

  table.insert(specifications, specification)
  vim.notify("packages loaded: ".. module, vim.log.levels.INFO)
end

local specifications = {}

-- Shared dependencies

  local source = debug.getinfo(1, "S").source:sub(2)
local dir = vim.fs.dirname(source)
for name, type in vim.fs.dir(dir) do


  if (type == "file") then

    local package = name:gsub("%.lua$", "")

    if package ~= "init" then
      load(specifications, "packages." .. package)
    end
  end

end

local all_plugins = {}

for _, spec in ipairs(specifications) do
  for _, plugin in ipairs(spec.plugins or {}) do
    table.insert(all_plugins, plugin)
  end
end
vim.pack.add(all_plugins)

for _, spec in ipairs(specifications) do
  if spec.setup then
    local ok, err = pcall(spec.setup)
    if not ok then
      vim.notify("packages setup failed \n" .. err, vim.log.levels.ERROR)
    end
  end
end
