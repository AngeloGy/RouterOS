
:local ddnsserver "dynamicdns.park-your-domain.com"
:local ddnspass "bd71f0e27adb47dea47101f8a1d9d49d"
:local ddnshostname "www"
:local ddnsdomain "angcode.xyz"
:local ddnscomment "TestDDNS"
#一定要先宣告，不然後面程式無法使用
:global ddnslastipADSL1
:global ddnsipADSL1 [ /ip address get [/ip address find interface=[/interface get [/interface find comment=$ddnscomment] name]] address ]
#舊的IP有存在就用舊的，不存在就建"0.0.0.0/0"
:if ([:typeof [:global ddnslastipADSL1]] = nil ) do={ :global ddnslastipADSL1 0.0.0.0/0 } else={ :set ddnslastipADSL1 $ddnslastipADSL1 }
:if ([:typeof [:global ddnsipADSL1]] = nil ) do={
  :log info ("DDNS: No ip address present on " . $ddnscomment . ", please check.")
} else={
  :if ($ddnsipADSL1 != $ddnslastipADSL1) do={
    :log info "DDNS: Update DDNS! (CHT:開始更新 $ddnscomment)"
    :local ipFormat [:pick $ddnsipADSL1 0 [:find $ddnsipADSL1 "/"]];
    :local ddnsUpdateString "/update?host=$ddnshostname&domain=$ddnsdomain&password=$ddnspass&ip=$ipFormat"   
    :log info ([/tool fetch address=$ddnsserver mode=http src-path=$ddnsUpdateString dst-path=("/DDNS-".$ddnshostname)] . "CHT:更新IP：" . $ddnsipADSL1)
    :log info ($ddnshostname . "." . $ddnsdomain "  更新回傳值-->" . [/file get "DDNS-$ddnshostname" contents])
    :global ddnslastipADSL1 $ddnsipADSL1
  } else={ 
  }
}

#紀錄:以上網址部份的問號，如在pitty Console下會被截斷，原因不明，因此要使用Script的方式

