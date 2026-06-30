{
  # systemd-boot is enabled by default in NixOS: for mirrored boot we need Grub
  
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];

  # This is the regular setup for grub on UEFI which manages /boot automatically
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  # This will mirror all UEFI files, kernels, grub menus and things needed to boot to the other drive
  fileSystems."/boot-fallback" =
    { device = "/dev/disk/by-uuid/5B4B-6C99";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
}
