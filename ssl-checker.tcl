set cmds ". ! ` -"
foreach cmd $cmds { bind pub - ${cmd}ssl pub:ssl }
proc pub:ssl {n u h c t} {
 set t [stripcodes bcruag $t]
 set sslhost [lindex $t 0]
 set sslport [lindex $t 1]
 if {$sslport == ""} { set sslport 443 }
 if {[catch { set sslchk [exec echo | timeout 3 openssl s_client -showcerts -servername localhost -connect $sslhost:$sslport 2>/dev/null | openssl x509 -inform pem -noout -text]} error]} {
  putnow "privmsg $c :$sslhost port $sslport 04»» Error! ($error)"
  putlog $sslchk
  return 0
 }
 regexp -nocase {subject:.*?o = (.*?),} $sslchk t sslsubject1
 regexp -nocase {subject:.*?cn = (.*?)\n} $sslchk t sslsubject2
 if {![info exists sslsubject2]} { set sslsubject2 "" }
 if {[info exists sslsubject1]} {
  set sslsubject "$sslsubject2 ($sslsubject1)"
 } else { set sslsubject $sslsubject2 }
 putnow "privmsg $c :Subject 04»» $sslsubject"
 regexp -nocase {X509v3 Subject Alternative Name:(.*?)X509} $sslchk t sslsans
 if {[info exists sslsans]} {
  regsub -all "\n" $sslsans "" sslsans
  regsub -all "  " $sslsans "" sslsans
  putnow "privmsg $c :SANs 04»» $sslsans"
 }
 regexp -nocase {issuer:.*?o = (.*?),} $sslchk t sslissuer1
 regexp -nocase {issuer:.*?CN = (.*?)\n} $sslchk t sslissuer2
 if {![info exists sslissuer2]} { set sslissuer2 "" }
 putnow "privmsg $c :Issuer 04»» $sslissuer2 ($sslissuer1)"
 regsub -all "  " $sslchk " " sslvld
 regexp {Not Before: (.*?) (.*?) (.*?) (.*?) GMT} $sslvld t mm1 dd1 cc1 yy1
 regexp {Not After : (.*?) (.*?) (.*?) (.*?) GMT} $sslvld t mm2 dd2 cc2 yy2
 putnow "privmsg $c :Validity 04»» $dd1-$mm1-$yy1 until $dd2-$mm2-$yy2"
 return 0
}
