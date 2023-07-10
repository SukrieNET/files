set cmds ". ! ` -"
foreach cmd $cmds {
 bind pub - ${cmd}ip pub:geoip
 bind pub - ${cmd}ipinfo pub:geoip
 bind pub - ${cmd}ipchk pub:geoip
}

proc pub:geoip {nick uhost hand chan text} {
 set ip [lindex [stripcodes bcruag $text] 0]
 if {$ip == ""} {
  putnow "NOTICE $nick :Aturan Pakai : .ip <ip>"
  return 0
 }
 if {[onchan $ip $chan]} {
  set nickip [lindex [split [getchanhost $ip] @] 1]
  putnow "privmsg $chan :[geoip:lookup $nickip]"
  return 0
 }
 putnow "privmsg $chan :[geoip:lookup $ip]"
 return 0
}
proc geoip:lookup {ip} {
 http::config -proxyhost "" -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36"
 if {[catch {set geoippage [http::geturl http://ip-api.com/xml/$ip -timeout 30000]} error]} {
  return "$ip : $error"
 }
 set geoipdata [http::data $geoippage]
 http::cleanup $geoippage
 regsub -all "\n" $geoipdata "" geoipdata
 regexp -nocase {<query>.*<query>(.*?)</query></query>} $geoipdata t ipres
 set result "$ipres 04»»"
 regexp -nocase {<message>(.*?)</message>} $geoipdata t msgres
 if {[info exists msgres]} { set result [geoip:whois $ipres] ; return $result }
 regexp -nocase {<isp>(.*?)<} $geoipdata t isp
 if {[info exists isp]} {append result " $isp"}
 regexp -nocase {<org>(.*?)<} $geoipdata t org
 if {[info exists org]} {append result " ($org)"}
 regexp -nocase {<city>(.*?)<} $geoipdata t city
 if {[info exists city]} {append result " 04- $city"}
 regexp -nocase {<regionName>(.*?)<} $geoipdata t region
 if {[info exists region]} {append result " 04- $region"}
 regexp -nocase {<zip>(.*?)<} $geoipdata t zip
 if {[info exists zip]} {append result " 04- $zip"}
 regexp -nocase {<country>(.*?)<} $geoipdata t country
 if {[info exists country]} {append result " 04- $country"}
 if {$country == ""} { set result [geoip:whois $ipres] ; return $result }
 return $result
}
proc geoip:whois {ip} {
 catch {exec whois $ip} ipres
 foreach line [split $ipres "\n"] {
  if {[string index $line 0]!="#" && [string index $line 0]!="%"} {
   if {[string match -nocase *netname:* $line]} {regexp -nocase {netname:(.*)} $line x netname}
   if {[string match -nocase *owner-c:* $line]} {regexp -nocase {owner-c:(.*)} $line x netname}
   if {[string match -nocase *country:* $line]} {regexp -nocase {country:(.*)} $line x country}
   if {[string match -nocase *descr:* $line]} {regexp -nocase {descr:(.*)} $line x orgname}
   if {[string match -nocase *orgname:* $line]} {regexp -nocase {orgname:(.*)} $line x orgname}
   if {[string match -nocase *owner:* $line]} {regexp -nocase {owner:(.*)} $line x orgname}
   if {[string match -nocase *inetnum:* $line]} {regexp -nocase {inetnum:(.*)} $line x range}
   if {[string match -nocase *inet6num:* $line]} {regexp -nocase {inet6num:(.*)} $line x range}
   if {[string match -nocase *netrange:* $line]} {regexp -nocase {netrange:(.*)} $line x range}
  }
 }
 if {![info exists range]} {return $ipres}
 return "$ip 04»» [string trim $range] 04- [string trim $netname] \([string trim $orgname]\) 04- [string trim $country]"
}
