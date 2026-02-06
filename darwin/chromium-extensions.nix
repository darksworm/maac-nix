# Chromium Extensions Configuration for macOS
# Note: ungoogled-chromium doesn't support automatic extension installation
# This module only sets browser preferences, not extension installation
{ config, pkgs, ... }:

let
  # Create a JSON policy file for Chromium preferences only
  # Extension installation must be done manually for ungoogled-chromium
  chromiumPolicy = pkgs.writeText "chromium-policies.json" (builtins.toJSON {
    # Browser preferences only - no extension policies
    DeveloperToolsAvailability = 1;
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "DuckDuckGo";
    DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    PasswordManagerEnabled = false;
    HttpsOnlyMode = "force_enabled";
    RestoreOnStartup = 1;
  });

  # Script to set up Chromium extensions
  setupChromiumExtensions = pkgs.writeScriptBin "setup-chromium-extensions" ''
    #!${pkgs.bash}/bin/bash
    
    # Determine the actual user (in case of sudo)
    if [ -n "$SUDO_USER" ]; then
      TARGET_USER="$SUDO_USER"
    else
      TARGET_USER="$USER"
    fi
    
    # Create managed policies directory for Chromium
    POLICY_DIR="/Library/Managed Preferences/$TARGET_USER"
    CHROMIUM_POLICY="$POLICY_DIR/org.chromium.Chromium.plist"
    
    echo "Setting up Chromium extensions for user: $TARGET_USER"
    
    # Create directory if it doesn't exist (needs sudo)
    if [ "$EUID" -ne 0 ]; then
      echo "This script needs to be run with sudo to create system preferences"
      exit 1
    fi
    
    mkdir -p "$POLICY_DIR"
    
    # Convert JSON to plist and install
    ${pkgs.python3}/bin/python3 -c "
import json
import plistlib
import os

with open('${chromiumPolicy}', 'r') as f:
    policy = json.load(f)

# Convert to plist format
plist_path = '$CHROMIUM_POLICY'

# Write plist
with open(plist_path, 'wb') as f:
    plistlib.dump(policy, f)

print(f'Policy file written to {plist_path}')
"
    
    # Set proper ownership
    chown "$TARGET_USER:staff" "$CHROMIUM_POLICY"
    
    echo "Chromium extensions configured. Restart Chromium for changes to take effect."
  '';
in
{
  # Add the setup script to system packages (for manual use if needed)
  environment.systemPackages = [ setupChromiumExtensions ];
  
  # Note: No launchd daemon - ungoogled-chromium requires manual extension installation
  # The setup script can be run manually with: sudo setup-chromium-extensions
  # But it's better to install extensions manually through the browser
}