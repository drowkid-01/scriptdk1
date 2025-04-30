sysctl -w net.ipv6.conf.all.disable_ipv6=1 && sysctl -p
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/70-disable-ipv6.conf
sysctl -p -f /etc/sysctl.d/70-disable-ipv6.conf
