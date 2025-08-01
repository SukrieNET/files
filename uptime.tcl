bind pub - .uptime pub:uptime
proc pub:uptime {n u h c t} {
 catch {exec uptime} upsys
 if {[regexp {up\s+(.*?),\s+\d+\s+user} $upsys -> sysup]} {
  set sysuptime $sysup
 } else {
  set sysuptime "unknown"
 }
 putnow "PRIVMSG $c :Bot Uptime : [uptimex [expr [clock seconds]-$::uptime]] \[SysUptime : $sysuptime\]"
}
proc uptimex {unixtime} {
 set secuptime $unixtime
 set secmin 60
 set sechour [expr 60 * $secmin]
 set secday [expr 24 * $sechour]
 set secmth [expr 30 * $secday]
 set secyear [expr 365 * $secday]
 set years 0
 set months 0
 set days 0
 set hours 0
 set minutes 0
 set seconds 0
 set remainsec $secuptime
 if {$remainsec >= $secyear} {
  set years [expr $remainsec / $secyear]
  set remainsec [expr $remainsec % $secyear]
 }
 if {$remainsec >= $secmth} {
  set months [expr $remainsec / $secmth]
  set remainsec [expr $remainsec % $secmth]
 }
 if {$remainsec >= $secday} {
  set days [expr $remainsec / $secday]
  set remainsec [expr $remainsec % $secday]
 }
 if {$remainsec >= $sechour} {
  set hours [expr $remainsec / $sechour]
  set remainsec [expr $remainsec % $sechour]
 }
 if {$remainsec >= $secmin} {
  set minutes [expr $remainsec / $secmin]
  set remainsec [expr $remainsec % $secmin]
 }
 set seconds $remainsec
 set upparts {}
 if {$years > 0} { lappend upparts "\037${years}\037 tahun" }
 if {$months > 0} { lappend upparts "\037${months}\037 bulan" }
 if {$days > 0} { lappend upparts "\037${days}\037 hari" }
 if {$hours > 0} { lappend upparts "\037${hours}\037 jam" }
 if {$minutes > 0} { lappend upparts "\037${minutes}\037 menit" }
 if {$seconds > 0 || [llength $upparts] == 0} { lappend upparts "\037${seconds}\037 detik" }
 set botuptime "[join $upparts " "]"
 return $botuptime
}
