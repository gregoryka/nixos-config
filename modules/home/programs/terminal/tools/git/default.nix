{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkForce
    getExe'
    ;
  inherit (lib.gregnix) mkOpt enabled;
  inherit (config.gregnix) user;

  cfg = config.gregnix.programs.terminal.tools.git;

  aliases = import ./aliases.nix;
  ignores = import ./ignores.nix;
  shell-aliases = import ./shell-aliases.nix { inherit config lib pkgs; };
in
{
  options.gregnix.programs.terminal.tools.git = {
    enable = mkEnableOption "Git";
    includes = mkOpt (types.listOf types.attrs) [ ] "Git includeIf paths and conditions.";
    signByDefault = mkOpt types.bool true "Whether to sign commits by default.";
    signingKey =
      mkOpt (types.nullOr types.str) null
        "The key ID to sign commits with.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
    wslAgentBridge = lib.mkEnableOption "the wsl agent bridge";
    wslGitCredentialManagerPath =
      mkOpt types.str "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
        "The windows git credential manager path.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bfg-repo-cleaner
      git-absorb
      git-crypt
      git-filter-repo
      git-lfs
      gitflow
      gitleaks
      gitlint
      tig
    ];

    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;

        options = {
          dark = true;
          # FIXME: module should accept a mergeable list be composable
          # features = mkForce "decorations side-by-side navigate catppuccin-macchiato";
          line-numbers = true;
          navigate = true;
          side-by-side = true;
        };
      };

      difftastic = {
        enable = !config.programs.kitty.enable && !config.programs.delta.enable;

        git = {
          enable = true;
          diffToolMode = !config.programs.kitty.enable && !config.programs.delta.enable;
        };

        options = {
          background = "dark";
          display = "inline";
        };
      };

      git = {
        enable = true;
        package = pkgs.gitFull;

        inherit (cfg) includes;
        inherit (ignores) ignores;

        maintenance.enable = true;

        settings = {
          alias = aliases.aliases;

          branch.sort = "-committerdate";

          credential = {
            helper =
              lib.optionalString cfg.wslAgentBridge cfg.wslGitCredentialManagerPath
              + lib.optionalString (!cfg.wslAgentBridge && pkgs.stdenv.hostPlatform.isLinux) (
                getExe' config.programs.git.package "git-credential-libsecret"
              )
              + lib.optionalString (!cfg.wslAgentBridge && pkgs.stdenv.hostPlatform.isDarwin) (
                getExe' config.programs.git.package "git-credential-osxkeychain"
              );

            useHttpPath = true;
          };

          fetch = {
            prune = true;
          };

          init = {
            defaultBranch = "main";
          };

          lfs = enabled;

          pull = {
            rebase = true;
          };

          push = {
            autoSetupRemote = true;
            default = "current";
          };

          rerere = {
            enabled = true;
          };

          rebase = {
            autoStash = true;
          };

          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
        };

        hooks = {
          pre-commit = lib.getExe (
            pkgs.writeShellScriptBin "pre-commit" ''
              #  CONFLICT_PATTERNS = [
              #     b'<<<<<<< ',
              #     b'======= ',
              #     b'=======\r\n',
              #     b'=======\n',
              #     b'>>>>>>> ',
              # ]
              # Regex breakdown:
              # ^(<<<<<<< |>>>>>>> )  -> Matches start/end markers (which always have a trailing space)
              # |                     -> OR
              # ^=======( |$)         -> Matches middle marker followed by a space OR end-of-line (handles \n and \r\n)
              if git grep -qE "^(<<<<<<< |>>>>>>> |=======( |$))" --cached; then
                echo "Error: You have leftover merge conflict markers."
                exit 1
              fi
            ''
          );
        };

        signing = {
          key = cfg.signingKey;
          format = "openpgp";
          inherit (cfg) signByDefault;
        };
      };

      # Merge helper
      mergiraf = enabled;
    };

    home = {
      inherit (shell-aliases) shellAliases;
    };

    # TODO sops
  };
}
