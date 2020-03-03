#PPTP 設定
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


#######################################
#場內LAN端介面名稱
:global LanName "ETH01"

#要增加幾組，預設7組
:global AddCount "7"

#單機IP，6組都需填入單機IP，中間分隔號為 ;
:global ClientIP {192.168.0.201;192.168.0.202;192.168.0.203;192.168.0.204;192.168.0.205;192.168.0.206;192.168.0.207}

#原本固定IP的撥接名稱，如pppoe-out1
:global PPPoEName "pppoe-out1"

#原本固定IP的routing-mark，如VDSL1
:global PPPoEMark "VDSL1"

#對應撥接介面，如ETH03
:global PPPoEInt "ETH03"

#撥接帳號，如@hinet.net
:global PPPoEuser "@hinet.net"

#撥接密碼，如Password
:global PPPoEpass "Password"

#頻寬限制
:global MaxLimit "5M/15M"
#注意RouterOS版本不同，需要變更下方指令

:global allrunloop 1
:while ($allrunloop <= $AddCount) do={
/interface pppoe-client
add disabled=no interface=$PPPoEInt name=($PPPoEName . "_" . $allrunloop) password=$PPPoEpass \
    use-peer-dns=yes user=$PPPoEuser

/ip route
add distance=1 gateway=($PPPoEName . "_" . $allrunloop) routing-mark=($PPPoEMark . "_" . $allrunloop)

/ip route rule
add routing-mark=($PPPoEMark . "_" . $allrunloop) table=($PPPoEMark . "_" . $allrunloop)

/ip firewall nat
add action=masquerade chain=srcnat comment=("AOE_" . $PPPoEName . "_" . $allrunloop) disabled=no \
    out-interface=($PPPoEName . "_" . $allrunloop) src-address=[:pick $ClientIP ($allrunloop-1)]
	
add action=netmap chain=dstnat comment=("AOE_" . $PPPoEName . "_" . $allrunloop) disabled=no \
	in-interface=($PPPoEName . "_" . $allrunloop) to-addresses=[:pick $ClientIP ($allrunloop-1)]

/ip firewall mangle
add action=mark-routing chain=prerouting comment=("AOE_" . $PPPoEName . "_" . $allrunloop) disabled=no \
    in-interface=$LanName new-routing-mark=($PPPoEMark . "_" . $allrunloop) passthrough=no src-address=\
    [:pick $ClientIP ($allrunloop-1)]

#6.0以前版本適用
/queue simple add name=($PPPoEName . "_" . $allrunloop) target-address=[:pick $ClientIP ($allrunloop-1)] max-limit=$MaxLimit

#6.0以後版本適用
#/queue simple add name=($PPPoEName . "_" . $allrunloop) target=[:pick $ClientIP ($allrunloop-1)] max-limit=$MaxLimit


:set allrunloop ($allrunloop+1)
}




