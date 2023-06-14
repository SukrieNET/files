set cmds ". ! ` -"
foreach cmd $cmds { bind pub - ${cmd}sipcalc sipcalc }
proc sipcalc {n u h c t} {
 set t [stripcodes bcruag $t]
 set ip [lindex $t 0]
 catch {exec sipcalc $ip} ipres
 putnow "PRIVMSG $c :Result for $t" 
 foreach line [split $ipres "\n"] {
  if {[string match -nocase "*ipv*" $line] || [string match "*CIDR*" $line] || [string match "*decimal*" $line] || [string match "*hex*" $line] || [string match "*bits*" $line] || [string match "*masked*" $line] || [string match "*type*" $line] || [string match "*refix*" $line] || [string match "-" $line] || [string match "*wildcard*" $line] || [string match "*roadcast*" $line]} {continue}
  regsub -all " " $line " " line
  regsub -all " - " $line " » " line
  putnow "PRIVMSG $c :$line"
 }
 return 0
}
