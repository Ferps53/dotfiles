local M = {}

M.plugins = {
"https://codeberg.org/mfussenegger/nvim-jdtls"
}

function M:setup()
  M:validateJdtls()
end
  

function M:validateJdtls()
  local ok, jdtls = pcall(require, 'jdtls')
  if not ok then
    vim.notify('nvim-jdtls not installed', vim.log.levels.ERROR)
    return nil
  end

  if vim.fn.executable('jdtls') ~= 1 then
    vim.notify('jdtls binary not found in PATH', vim.log.levels.ERROR)
    return nil
  end
  return jdtls
end

function M:start()
  local jdtls = M:validateJdtls()

  if jdtls == nil then
    return
  end

  local root_dir = vim.fs.root(0, { '.git' })
    or vim.fs.root(0, { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', 'build.gradle.kts' })
  if not root_dir then
    vim.notify('jdtls: no project root found, skipping start', vim.log.levels.WARN)
    return
  end

  local cmd = { 'jdtls' }

  local function find_lombok()
    local env = vim.env.LOMBOK_JAR
    if env and env ~= '' and vim.fn.filereadable(env) == 1 then return env end
    -- newest jar in .m2
    local m2_jars = vim.fn.glob(vim.env.HOME .. '/.m2/repository/org/projectlombok/lombok/*/lombok-[0-9]*.jar', false, true)
    if #m2_jars > 0 then
      table.sort(m2_jars)
      return m2_jars[#m2_jars]
    end
  end

  local lombok_path = find_lombok()
  if lombok_path then
    table.insert(cmd, '--jvm-arg=-javaagent:' .. lombok_path)
  else
    vim.notify("Lombok not found (set LOMBOK_JAR or install via mvn/nix)", vim.log.levels.WARN)
  end

  vim.list_extend(cmd, {
    '-data',
    vim.fn.stdpath('cache') .. '/jdtls/' .. vim.fn.fnamemodify(root_dir, ':t'),
  })

  local runtimes = {}
  for _, rt in ipairs({
    { name = 'JavaSE-1.8', env = 'JAVA_8_HOME' },
    { name = 'JavaSE-11',  env = 'JAVA_11_HOME' },
    { name = 'JavaSE-17',  env = 'JAVA_17_HOME' },
    { name = 'JavaSE-21',  env = 'JAVA_21_HOME' },
    { name = 'JavaSE-25',  env = 'JAVA_25_HOME' },
  }) do
    local path = vim.env[rt.env]
    if path and path ~= '' and vim.fn.isdirectory(path) == 1 then
      table.insert(runtimes, { name = rt.name, path = path })
    end
  end

  local config = {
    cmd = cmd,
    root_dir = root_dir,
    settings = {
      java = {
        server = { launchMode = 'Hybrid' },
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        configuration = { runtimes = runtimes },
        references = { includeDecompiledSources = true },
        implementationsCodeLens = { enabled = true },
        referenceCodeLens = { enabled = true },
        inlayHints = { parameterNames = { enabled = 'none' } },
        signatureHelp = { enabled = true, description = { enabled = true } },
        sources = {
          organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
        },
      },
      redhat = { telemetry = { enabled = false } },
    },
  }

  jdtls.start_or_attach(config)
end

return M
