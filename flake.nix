{
  inputs = {
    nixbsd.url = "github:nixos-bsd/nixbsd/tmp";
  };
  outputs =
    { self, nixbsd }:
    {
      packages.x86_64-openbsd.theSystem = self.nixosConfigurations.theSystem;
      nixosConfigurations.theSystem = nixbsd.nixosConfigurations.openbsd-base.extendModules {
        modules = [
          (
            { config, lib, ... }:
            {
              nixpkgs.buildPlatform = "x86_64-linux";
              nixpkgs.fakeNative = true;

              fileSystems."/" = {
                device = "/dev/sd0a";
                fsType = "ufs";
              };
              fileSystems."/boot/efi" = {
                device = "/dev/sd0i";
                fsType = "msdosfs";
              };
            }
          )
        ];
      };
    };
}