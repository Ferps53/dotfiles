local M = {}

function M:setup()
  local jdtls = require 'jdtls'
  local lombok_path = vim.env.LOMBOK_JAR

  local cmd = {
    'jdtls',
    '--jvm-arg=-javaagent:' .. lombok_path,
    '-data',
    vim.fn.stdpath 'cache' .. '/jdtls/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t'),
  }

  local config = {
    cmd = cmd,
    root_dir = vim.fs.root(0, { 'mvnw', 'gradlew', '.git' }),

    settings = {
      java = {
        server = { launchMode = 'Hybrid' },
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        configuration = {
          runtimes = {
            { name = 'JavaSE-1.8', path = vim.env.JAVA_8_HOME },
            { name = 'JavaSE-11', path = vim.env.JAVA_11_HOME },
            { name = 'JavaSE-17', path = vim.env.JAVA_17_HOME },
            { name = 'JavaSE-21', path = vim.env.JAVA_21_HOME },
            { name = 'JavaSE-25', path = vim.env.JAVA_25_HOME },
          },
        },
        references = { includeDecompiledSources = true },
        implementationsCodeLens = { enabled = false },
        referenceCodeLens = { enabled = false },
        inlayHints = {
          parameterNames = { enabled = 'none' },
        },
        signatureHelp = {
          enabled = true,
          description = { enabled = true },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
      redhat = { telemetry = { enabled = false } },
    },
  }

  -- 2. DEBUG & TEST BUNDLES (Nix Way)
  -- Since Mason is gone, you must install `vscode-extensions.vscjava.vscode-java-debug`
  -- and `vscode-extensions.vscjava.vscode-java-test` via your Nix configuration.
  --
  -- Once installed, uncomment the lines below and point them to the correct Nix store paths
  -- (Setting them as environment variables in your flake/home.nix is usually the easiest way).
  
  -- local java_debug_path = vim.env.NIX_JAVA_DEBUG_PATH
  -- local java_test_path = vim.env.NIX_JAVA_TEST_PATH
  --
  -- if java_debug_path and java_test_path then
  --   local bundles = {
  --     vim.fn.glob(java_debug_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar')
  --   }
  --   vim.list_extend(
  --     bundles,
  --     vim.split(vim.fn.glob(java_test_path .. '/extension/server/*.jar'), '\n')
  --   )
  --   config['init_options'] = { bundles = bundles }
  -- end

  jdtls.start_or_attach(config)
end

return M
