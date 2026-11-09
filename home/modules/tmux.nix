{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    # let nvim see focus gain/loss so 'autoread' works
    focusEvents = true;
    # prefix + h/j/k/l seleciona pane, prefix + H/J/K/L redimensiona
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        # precisa vir depois do resurrect
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g default-command "${pkgs.fish}/bin/fish -l"
      set-option -g renumber-windows on

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      # Shift Alt vim keys to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      # copy-mode vi keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}
