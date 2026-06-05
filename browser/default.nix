{ pkgs, ... }:

let

  policies = {
    URLBlockList = [ "*" ];
    URLAllowList = [ "https://10.245.0.2:8000" ];
    AppAutoUpdate = false;
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    BackgroundAppUpdate = false;
    BlockAboutAddons = true;
    BlockAboutConfig = true;
    BlockAboutProfiles = true;
    BlockAboutSupport = true;
    DisableAccounts = true;
    DisableBuiltInPDFViewer = true;
    DisableDeveloperTools = true;
    DisableEncryptedClientHello = false;
    DisableFeedbackCommands = true;
    DisableFirefoxAccounts = true;
    DisableFirefoxScreenshots = true;
    DisableFirefoxStudies = true;
    DisableForgetButton = true;
    DisableFormHistory = true;
    DisableMasterPasswordCreation = true;
    DisablePasswordReveal = true;
    DisablePocket = true;
    DisableProfileImport = true;
    DisableProfileRefresh = true;
    DisableSecurityBypass = true;
    DisableSetDesktopBackground = true;
    DisableSystemAddonUpdate = true;
    DisableTelemetry = true;
    DisplayBookmarksToolbar = "never";
    DontCheckDefaultBrowser = true;
    EnableTrackingProtection = {
      Value = true;
      Locked = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
    };
    EncryptedMediaExtensions = {
      Enabled = false;
      Locked = true;
    };
    FirefoxHome = {
      Search = false;
      TopSites = false;
      SponsoredTopSites = false;
      Highlights = false;
      Pocket = false;
      SponsoredPocket = false;
      Snippets = false;
      Locked = true;
    };
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };
    HttpsOnlyMode = "force_enabled";
    InstallAddonsPermission = false;
    MicrosoftEntraSSO = false;
    NewTabPage = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";
    PasswordManagerEnabled = false;
    PDFjs.Enabled = false;
    PictureInPicture = {
      Enabled = false;
      Locked = true;
    };
    PostQuantumKeyAgreementEnabled = true;
    PrintingEnabled = false;
    PrivateBrowsingModeAvailability = 2;
    PromptForDownloadLocation = true;
    SanitizeOnShutdown = true;
    SearchSuggestEnabled = false;
    ShowHomeButton = false;
    SkipTermsOfUse = true;
    StartDownloadsInTempDirectory = true;
    TranslateEnabled = false;
    WindowsSSO = false;
  };

  userJs = pkgs.writeTextFile {
    name = "polevault-browser-userjs";
    text = ''
      user_pref("browser.urlbar.suggest.bookmark", false);
      user_pref("browser.urlbar.suggest.engines", false);
      user_pref("browser.urlbar.suggest.history", true);
      user_pref("browser.urlbar.suggest.openpage", false);
      user_pref("browser.urlbar.suggest.topsites", false);

      user_pref("privacy.fingerprintingProtection", true);
      user_pref("privacy.fingerprintingProtection.pbmode", true);
      user_pref("privacy.resistFingerprinting", true);
      user_pref("privacy.resistFingerprinting.pbmode", true);

      user_pref("permissions.default.camera", 2);
      user_pref("permissions.default.desktop-notification", 2);
      user_pref("permissions.desktop-notification.notNow.enabled", false);
      user_pref("permissions.desktop-notification.postPrompt.enabled", false);
      user_pref("permissions.default.geo", 2);
      user_pref("permissions.default.image", 1);
      user_pref("permissions.default.microphone", 2);
      user_pref("permissions.default.screen-wake-lock", 2);
      user_pref("permissions.default.xr", 2);
      user_pref("permissions.default.shortcuts", 2);

      user_pref("browser.tabs.inTitlebar", 0);
      user_pref("font.default.x-western", "sans-serif");
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      user_pref("media.peerconnection.enabled", false);
      user_pref("media.peerConnection.ice.proxy_only", true);
      user_pref("media.navigator.enabled", false);

      user_pref("keyword.enabled", false);
      user_pref("javascript.enabled", true);
      user_pref("browser.urlbar.scotchBonnet.enableOverride", false);
    '';
    destination = "/user.js";
  };

  userChrome = pkgs.writeTextFile {
    name = "polevault-browser-userchrome";
    text = ''
      /* Hide unnecessary toolbar items */
      #urlbar-input::placeholder { color: transparent !important; }
      #firefox-view-button,
      #alltabs-button,
      #unified-extensions-button,
      #star-button-box,
      #picture-in-picture-button,
      #identity-box,
      #tracking-protection-icon-container,
      #reader-mode-button,
      #urlbar .urlbar-go-button,
      #reload-button,
      #stop-button,
      #downloads-button,
      #sidebar-header,
      #sidebar-button { display: none !important; }

      #urlbar-input { padding-left: 20px !important; }

      /* Hide tab strip and related UI */
      #TabsToolbar {
        visibility: collapse !important;
        min-height: 0 !important;
        height: 0 !important;
        overflow: hidden !important;
      }

      #titlebar {
        -moz-appearance: none !important;
      }

      #nav-bar {
        margin-top: 0 !important;
      }

      .tabbrowser-tab {
        min-height: 0 !important;
        height: 0 !important;
        visibility: collapse !important;
      }
    '';
    destination = "/chrome/userChrome.css";
  };

  userContent = pkgs.writeTextFile {
    name = "polevault-browser-usercontent";
    text = "";
    destination = "/chrome/userContent.css";
  };

  profile = pkgs.symlinkJoin {
    name = "polevault-browser-profile";
    paths = [
      userJs
      userChrome
      userContent
    ];
  };

  script = pkgs.writeTextFile {
    name = "polevault-browser-script";
    text = ''
      #!${pkgs.runtimeShell}

      set -euo pipefail

      baseProfile="${profile}"
      timestamp="$(${pkgs.coreutils}/bin/date +%s)"
      tmpProfile="/tmp/polevault-browser-''${timestamp}"

      ${pkgs.coreutils}/bin/mkdir -p "$tmpProfile"
      ${pkgs.coreutils}/bin/cp -r --no-preserve=mode,ownership,timestamps "$baseProfile"/* "$tmpProfile"/

      exec ${pkgs.wrapFirefox pkgs.firefox-unwrapped { extraPolicies = policies; }}/bin/firefox \
        --no-remote \
        --profile "$tmpProfile" \
        "$@"
    '';
    destination = "/bin/polevault-browser";
    executable = true;
  };

  jail = pkgs.writeTextFile {
    name = "polevault-browser-jail";
    text = ''
      #!${pkgs.runtimeShell}

      set -euo pipefail

      users=$(mktemp -d)

      echo "polevault:x:1000:1000:polevault:/home/polevault:${pkgs.coreutils}/bin/false" > "$users/passwd"
      echo "polevault:x:1000:" > "$users/group"

      cleanup() { 
        rm -rf "$users" 
      }
      trap cleanup INT TERM EXIT

      mkdir -p $XDG_RUNTIME_DIR/polevault-browser-downloads

      ${pkgs.bubblewrap}/bin/bwrap \
        --ro-bind /nix/store /nix/store \
        --ro-bind "$XDG_RUNTIME_DIR/wayland-1" "$XDG_RUNTIME_DIR/wayland-1" \
        --ro-bind "$users/passwd" /etc/passwd \
        --ro-bind "$users/group" /etc/group \
        --tmpfs /tmp \
        --tmpfs /home \
        --proc /proc \
        --dev /dev  \
        --unshare-all \
        --share-net \
        --die-with-parent \
        --new-session \
        --bind $XDG_RUNTIME_DIR/polevault-browser-downloads $HOME/Downloads \
        ${script}/bin/polevault-browser --kiosk https://10.245.0.2:8000
    '';
    destination = "/bin/polevault-browser";
    executable = true;
  };

in
jail
