{
  services.libreswan.enable = true;
  services.libreswan.connections.tunnel = ''

    # client
    left=%defaultroute
    leftid=@andrea.riva
    leftmodecfgclient=yes
    leftsubnet=0.0.0.0/0

    # server
    right=remote.easynet.group
    rightid=@server
    rightsubnet=0.0.0.0/0  # possibilmente da cambiare

    # authentication
    keyexchange=ikev1
    type=tunnel
    ike=aes256-sha1;dh14,aes256-sha256;dh14
    phase2alg=aes256-sha1;dh14
    authby=secret
    pfs=yes
    salifetime=12h
    ikelifetime=24h
    auto=start
    narrowing=yes
    dpddelay=30
    dpdtimeout=120

    # NAT traversal
    #enable-tcp=yes
    #tcp-remoteport=4500  # verifica sia questa
  '';
}
