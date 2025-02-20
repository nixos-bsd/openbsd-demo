{
  inputs = {
    nixbsd.url = "github:nixos-bsd/nixbsd/openbsd-phase6";
  };
  outputs =
    { self, nixbsd }:
    {
      packages.x86_64-linux.demo =
        (self.nixosConfigurations.demo.extendModules {
          modules = [
            {
              # fakeNative lets the OpenBSD system think it built the configuration itself.
              # This doesn't work when we're doing the real cross build, so disable it.
              nixpkgs.fakeNative = false;
            }
          ];
        }).config.system.build.toplevel;
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
