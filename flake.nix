{
  inputs = {
    nixbsd.url = "github:obsidiansystems/nixbsd/openbsd-phase6";
  };
  outputs =
    { self, nixbsd }: {
      packages.x86_64-linux = {
        demo-toplevel = self.nixosConfigurations.demo.config.system.build.toplevel;
        installer-vm = self.nixosConfigurations.installer.config.system.build.vm;
        installer-image = self.nixosConfigurations.installer.config.system.build.systemImage;
      };
      nixosConfigurations.installer = nixbsd.nixosConfigurations.openbsd-base.extendModules {
        modules = [
          ({pkgs, ...}: {
            nixpkgs.buildPlatform = "x86_64-linux";
            nix.settings.trusted-users = [ "demo" ];
            environment.systemPackages = [ pkgs.openssh ];
          })
        ];
      };
      nixosConfigurations.demo = nixbsd.nixosConfigurations.openbsd-base.extendModules {
        modules = [
          (
            { config, lib, ... }:
            {
              nixpkgs.buildPlatform = "x86_64-linux";

              fileSystems."/" = {
                device = "/dev/sd0a";
                fsType = "ffs";
              };
              fileSystems."/boot/efi" = {
                device = "/dev/sd0i";
                fsType = "msdos";
              };

              services.nginx = {
                enable = true;
                virtualHosts.localhost = {
                  default = true;
                  root = ./.;
                };
              };

            }
          )
        ];
      };
    };
}
