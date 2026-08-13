-- nil (the Nix LS) is installed declaratively via home-manager (see nix/home.nix),
-- since Mason can only build it from source with cargo, which we don't install.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = { mason = false },
      },
    },
  },
}
