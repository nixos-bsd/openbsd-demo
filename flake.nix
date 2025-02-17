{
  inputs = {
    nixbsd.url = "github:nixos-bsd/nixbsd/tmp";
  };
  outputs =
    { self, nixbsd }:
    {
      packages.x86_64-openbsd.theSystem = self.nixosConfigurations.theSystem;
      nixosConfigurations.theSystem = nixbsd.lib.nixbsdSystem {
        system = "x86_64-openbsd";
        modules = [
          (
            { config, lib, ... }:
            {
              nixpkgs.hostPlatform = "x86_64-openbsd";
              nixpkgs.buildPlatform = "x86_64-linux";
              nixpkgs.fakeNative = true;

              users.users.root.initialHashedPassword = "$2b$09$CexHNp84.dJLZv5oBcSBuO7zLdbAIBxyxiukAPwY3yKiH162s.GGW";

              services.sshd.enable = true;
              boot.loader.stand-openbsd.enable = true;
              xdg.mime.enable = false;
              documentation.enable = false;
              documentation.man.man-db.enable = false;
              programs.bash.completion.enable = false;
              system.switch.enable = false;

              fileSystems."/" = {
                device = "/dev/sd0a";
                fsType = "ufs";
              };
              fileSystems."/boot" = {
                device = "/dev/sd0i";
                fsType = "msdosfs";
              };
            }
          )
        ];
      };
    };
}