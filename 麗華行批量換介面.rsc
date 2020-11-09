
#bonding1啟用
/interface set numbers=bonding1 disabled=no

#
/ip firewall mangle set numbers=[/ip firewall mangle find in-interface~"ETH05"] in-interface=bonding1
#或是
/ip firewall mangle set in-interface="bonding1" [find in-interface="ETH05"]


/ip firewall nat set numbers=[/ip firewall nat find dst-address~"122.117.133.104"] dst-address=220.135.54.177


