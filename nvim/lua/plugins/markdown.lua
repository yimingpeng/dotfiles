-- Disable markdownlint (diagnostics and format-on-save fixes) for markdown.
-- The Obsidian vault trips hundreds of thousands of style warnings.
return {
  {
    "mfussenegger/nvim-lint",
    opts = { linters_by_ft = { markdown = {} } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "prettier", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdown-toc" },
      },
    },
  },
}
