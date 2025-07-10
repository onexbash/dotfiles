-- CUSTOM INSTALLATION --

-- MASON INSTALLATION --
return {
  "mason-org/mason.nvim",
  dependencies = {
    "folke/noice.nvim"
  },
  config = function()
    -- require modules
    local mason = require("mason")
    local mason_registry = require("mason-registry")
    local tools = require("utils.tools")
    local functions = require("utils.functions")

    functions.add_mason_to_path()

    -- Initialize Mason before installing packages
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      },
      pip = {
        upgrade_pip = true,
      },
    })
    local tools = require("utils.tools")
    local lang_servers = tools.lang_servers

    -- Async installation of language servers
    local pending_installations = {}
    local failed_installations = {}
    local total_servers = 0
    local completed_servers = 0

    -- Function to check if all installations are complete
    local function check_completion()
      if completed_servers == total_servers then
        if #failed_installations > 0 then
          vim.notify(
            string.format("Failed to install the following language servers:\n%s", table.concat(failed_installations, "\n")),
            vim.log.levels.WARN,
            { title = "Mason Installation Summary" }
          )
        else
          vim.notify(
            "All language servers installed successfully!",
            vim.log.levels.INFO,
            { title = "Mason Installation Complete" }
          )
        end
      end
    end

    -- Install servers asynchronously
  for lsp_name, mason_package in pairs(lang_servers) do
    if not mason_registry.is_installed(mason_package) then
      total_servers = total_servers + 1
      table.insert(pending_installations, mason_package)

      local handle = mason_registry.get_package(mason_package)
      handle:install():once(
        "closed",
        vim.schedule_wrap(function()
          completed_servers = completed_servers + 1
          -- Check if installation was successful
          if mason_registry.is_installed(mason_package) then
            vim.notify(
              string.format("Successfully installed %s (for %s)", mason_package, lsp_name),
              vim.log.levels.INFO,
              { title = "Mason Installation Progress" }
            )
          else
            table.insert(failed_installations, mason_package)
            vim.notify(
              string.format("Failed to install %s (for %s)", mason_package, lsp_name),
              vim.log.levels.ERROR,
              { title = "Mason Installation Error" }
            )
          end
          check_completion()
        end)
      )
    end
  end

    -- If no servers need installation, show message
    if total_servers == 0 then
      vim.notify(
        "All language servers are already installed.",
        vim.log.levels.INFO,
        { title = "Mason Installation Status" }
      )
    end

  end
}

