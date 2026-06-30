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
  boot.loader.grub.mirroredBoots = [
    { devices = [ "/dev/disk/by-uuid/5A2B-700F" ];
      path = "/boot-fallback"; }
  ];

}
