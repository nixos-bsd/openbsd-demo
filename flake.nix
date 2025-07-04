{
  inputs = {
    nixbsd.url = "github:obsidiansystems/nixbsd/9c0584fff8ae61946a46ab182148cf652559d364";
  };
  outputs =
    { self, nixbsd }:
    let realCross = 
      self.nixosConfigurations.demo.extendModules {
        modules = [
          {
            # fakeNative lets the OpenBSD system think it built the configuration itself.
            # This doesn't work when we're doing the real cross build, so disable it.
            nixpkgs.fakeNative = false;
          }
        ];
      };
      installer = nixbsd.packages.x86_64-linux.openbsd-base;
    in
    {
      packages.x86_64-linux = {
        demo-toplevel = realCross.config.system.build.toplevel;
        installer-vm = installer.config.system.build.vm;
        installer-image = installer.config.system.build.systemImage;
      };
      nixosConfigurations.demo = nixbsd.nixosConfigurations.openbsd-base.extendModules {
        modules = [
          (
            { config, lib, ... }:
            {
              nixpkgs.buildPlatform = "x86_64-linux";

              nixpkgs.fakeNative = lib.mkDefault true;

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
