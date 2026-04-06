let
  vendorRime = ../../vendor/rime;
in
{
  home.file."Library/Rime" = {
    source = vendorRime;
    recursive = true;
  };
}
