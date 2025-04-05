{
  config,
  disks ? [
    "/dev/nvme0n1"
    "/dev/sda"
  ],
  namespace,
  ...
}:
let
  defaultBtrfsOpts = [
    "defaults"
    "compress=zstd"
    "noatime"
    "nodiratime"
  ];
  defaultSSDBtrfsOpts = defaultBtrfsOpts ++ [ "ssd" ];
in
{
  disko.devices = {
    disk = {
      nvme0 = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            efi = {
              priority = 1;
              name = "efi";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                # TODO: split into seperate /efi?
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [
                  "-LEFI"
                ];
              };
            };
            nixos = {
              size = "100%";
              name = "nixos";

              content = {
                type = "btrfs";
                extraArgs = [ "-LNixos" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = defaultSSDBtrfsOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = defaultSSDBtrfsOpts;
                  };
                };
              };
            };
          };
        };
      };
      sda = {
        device = builtins.elemAt disks 1;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              name = "btrproductive";

              content = {
                type = "btrfs";
                # Override existing partition
                extraArgs = [ "-f" ];

                subvolumes = {
                  "@games" = {
                    mountpoint = "/mnt/games";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@steam" = {
                    mountpoint = "/mnt/steam";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@userdata/@documents" = {
                    mountpoint = "/home/${config.${namespace}.user.name}/Documents";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@userdata/@downloads" = {
                    mountpoint = "/home/${config.${namespace}.user.name}/Downloads";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@userdata/@music" = {
                    mountpoint = "/home/${config.${namespace}.user.name}/Music";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@userdata/@pictures" = {
                    mountpoint = "/home/${config.${namespace}.user.name}/Pictures";
                    mountOptions = defaultBtrfsOpts;
                  };
                  "@userdata/@videos" = {
                    mountpoint = "/home/${config.${namespace}.user.name}/Videos";
                    mountOptions = defaultBtrfsOpts;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
