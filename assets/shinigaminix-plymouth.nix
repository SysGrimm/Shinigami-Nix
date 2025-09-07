{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "shinigaminix-plymouth-theme";
  
  src = ./plymouth;
  
  buildPhase = ''
    # Create theme directory
    mkdir -p $out/share/plymouth/themes/shinigaminix
    
    # Copy theme files
    cp shinigaminix.plymouth $out/share/plymouth/themes/shinigaminix/
    cp shinigaminix.script $out/share/plymouth/themes/shinigaminix/
    
    # Copy logo (you'll need to add logo.png to the plymouth directory)
    if [ -f logo.png ]; then
      cp logo.png $out/share/plymouth/themes/shinigaminix/
    fi
    
    # Create simple progress bar graphics if they don't exist
    ${pkgs.imagemagick}/bin/convert -size 400x20 xc:"#333333" $out/share/plymouth/themes/shinigaminix/progress_box.png
    ${pkgs.imagemagick}/bin/convert -size 400x20 xc:"#D4B896" $out/share/plymouth/themes/shinigaminix/progress_bar.png
    ${pkgs.imagemagick}/bin/convert -size 300x150 xc:"rgba(0,0,0,0.8)" $out/share/plymouth/themes/shinigaminix/box.png
  '';
  
  installPhase = ''
    # Installation is handled in buildPhase
  '';
  
  buildInputs = [ pkgs.imagemagick ];
}
