#PPTP ³]©w
:local LocalGW "192.168.0.254"
:local PPPoeUser "@hinet.net"
:local PPPoePass "pass"
:local PPPoeInt "ETH03"

/interface pppoe-client
add disabled=no interface=$PPPoeInt name=pppoe-out-pptp password=$PPPoePass \
    use-peer-dns=yes user=$PPPoeUser

/ip route
add distance=1 gateway=pppoe-out-pptp routing-mark=WANPPTP

/ip firewall mangle
add action=mark-connection chain=prerouting comment=Policy_PPTP \
    connection-state=new disabled=yes in-interface=ETH01 new-connection-mark=\
    WANPPTP_Conn passthrough=yes src-address=192.168.100.1-192.168.100.253
add action=mark-routing chain=prerouting comment=Policy_PPTP connection-mark=\
    WANPPTP_Conn disabled=yes in-interface=ETH01 new-routing-mark=pppoe-out-pptp \
    passthrough=no

/interface pptp-server server set enabled=yes

/ip pool
add name=pool1 ranges=192.168.100.1-192.168.100.253

/ppp profile
add dns-server=168.95.1.1 local-address=192.168.0.254 name=profile1 \
    remote-address=pool1

/ppp secret
add name=ASURE password=Asure078150788 profile=\
    profile1 service=pptp
