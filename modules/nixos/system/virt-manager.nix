{
  pkgs,
  ...
}: {
  # Virtualising with libvirt and QEMU
  virtualisation.libvirtd = {
      enable = true;
      qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;

          vhostUserPackages = with pkgs; [ virtiofsd ];
      };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs."virt-manager".enable = true;

}