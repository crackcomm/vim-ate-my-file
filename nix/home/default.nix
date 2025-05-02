{ pkgs, lib, ... }: {
  imports = [ ./awesome.nix ./brave.nix ];

  home.stateVersion = "24.05";

  home.username = "pah";
  home.homeDirectory = "/home/pah";

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL = "kitty -1";
    TERM = "xterm-kitty";
  };

  home.packages = with pkgs; [ shotgun slop xclip ];

  programs.git = {
    enable = true;
    userName = "Łukasz Kurowski";
    userEmail = "crackcomm@gmail.com";
    extraConfig = { credential.helper = ""; };
  };

  programs.fd = {
    enable = true;
    ignores = [
      ".git/"
      ".jj/"
      "bazel-bin/"
      "bazel-out/"
      "bazel-testlogs/"
      "bazel-monorepo-ocxmr/"
    ];
    hidden = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files";
  };

  home.activation.cloneDotfilesAndLinkConfigs =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      set -euo pipefail

      # Paths
      DOTFILES_DIR="$HOME/x/dot-repo"
      CONFIG_DIR="$HOME/.config"

      mkdir -p $HOME/x

      # Ensure dotfiles repo exists
      if [ ! -d "$DOTFILES_DIR/.git" ]; then
        git clone https://github.com/crackcomm/vim-ate-my-file.git $DOTFILES_DIR
      fi

      # Link ~/.config/nvim -> ~/x/dot-repo/nvim
      echo "Linking Neovim config..."
      mkdir -p "$CONFIG_DIR"
      if [ -e "$CONFIG_DIR/nvim" ] || [ -L "$CONFIG_DIR/nvim" ]; then
        echo "Removing existing $CONFIG_DIR/nvim..."
        rm -rf "$CONFIG_DIR/nvim"
      fi
      ln -s "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"
      echo "Linked nvim config."

      # Link everything under ~/x/dot-repo/configs/* -> ~/.config/*
      echo "Linking configs..."
      if [ -d "$DOTFILES_DIR/configs" ]; then
        for src in "$DOTFILES_DIR/configs/"*; do
          name="$(basename "$src")"
          target="$CONFIG_DIR/$name"

          if [ -e "$target" ] || [ -L "$target" ]; then
            echo "Removing existing $target..."
            rm -rf "$target"
          fi

          ln -s "$src" "$target"
          echo "Linked $name config."
        done
      else
        echo "No configs/ directory found in dotfiles. Skipping."
      fi

      ENV_DIR="$DOTFILES_DIR/env"
      if [ ! -d "$HOME/.tmux" ]; then
        ln -sf "$DOTFILES_DIR/.tmux" "$HOME/.tmux"
      fi
      ln -sf "$ENV_DIR/.zshrc" "$HOME/.zshrc"
      ln -sf "$ENV_DIR/.zshenv" "$HOME/.zshenv"
      ln -sf "$ENV_DIR/.jjconfig.toml" "$HOME/.jjconfig.toml"
      ln -sf "$ENV_DIR/.tmux.conf" "$HOME/.tmux.conf"

      echo "All configs linked successfully."
    '';
}
