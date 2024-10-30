{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) writeShellScript;
in {
  getApiKey = writeShellScript "get-radarr-api-key" ''
    echo "Getting Radarr API key"
  '';

  writeConfigXml = writeShellScript "write-radarr-config-xml" ''
    echo "Writing Radarr config XML"
  '';

  writeSqlDump = writeShellScript "write-radarr-sql-dump" ''
    echo "Writing Radarr SQL dump"
  '';
}
