{ self }:
{ pkgs, config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption optionalString types;
  cfg = config.services.turtle;
  
  # Used for global emoji configuration.
  json = pkgs.formats.json {};
  globalEmojis = json.generate "globalEmojis.json" cfg.globalEmojis;
in
{
  options.services.turtle = {
    enable = mkEnableOption (lib.mdDoc "turtle");
    botToken = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        The token to use when connecting to Discord.
      '';
    };

    botClientSecret = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        The client secret to use when authorizing to Discord.
      '';
    };

    botOauthUrl = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        The OAuth2 URL provided to the user upon profile registration.
      '';
    };

    databaseUrl = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        A URL specifying what PostgreSQL instance to connect to.
      '';
    };

    registerCommands = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to register Discord slash commands.
      '';
    };

    registerMetadata = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to register Discord metadata. This appears within connected roles.
      '';
    };

    randomSeedPrefix = mkOption {
      type = types.str;
      description = lib.mdDoc ''
        A random seed used with anonymous name generation.
      '';
    };

    webServerPort = mkOption {
      type = types.port;
      default = 8080;
      description = lib.mdDoc ''
        The web server to listen on for OAuth2.
      '';
    };

    globalEmojis = mkOption {
      type = types.listOf types.str;
      default = [];
      description = lib.mdDoc ''
        An array of global emoji to additionally recognize.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.turtle = {
      description = "The Turtle Discord bot.";
      environment = {
        DISCORD_TOKEN = cfg.botToken;
        DISCORD_CLIENT_SECRET = cfg.botClientSecret;
        DISCORD_OAUTH2_BASE_URI = cfg.botOauthUrl;
        DATABASE_URL = cfg.databaseUrl;
        REGISTER_DISCORD_COMMANDS = lib.boolToString cfg.registerCommands;
        REGISTER_DISCORD_METADATA = lib.boolToString cfg.registerMetadata;
        RANDOM_SEED_PREFIX = cfg.randomSeedPrefix;
        WEB_SERVER_PORT = toString cfg.webServerPort;
        GLOBAL_EMOJIS_PATH = "${globalEmojis}";
      };
      wantedBy = [ "multi-user.target" ];
      # This is still turtle! We retain the original bot's executable name.
      serviceConfig.ExecStart = "${self.packages.${pkgs.system}.turtle}/bin/bread";
    };
  };
}
