{ mirrorConfig, ... }:
{
  home.file.".npmrc".text = ''
    registry=${mirrorConfig.javascript.npmRegistry}
  '';

  home.file.".bunfig.toml".text = ''
    [install]
    registry = "${mirrorConfig.javascript.npmRegistry}"
  '';

  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = ${mirrorConfig.python.pipIndexUrl}
  '';

  home.file.".cargo/config.toml".text = ''
    [source.crates-io]
    replace-with = "mirror"

    [source.mirror]
    registry = "${mirrorConfig.rust.cargoIndex}"

    [registries.mirror]
    index = "${mirrorConfig.rust.cargoIndex}"
  '';
}
