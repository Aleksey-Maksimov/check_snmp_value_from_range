#!/bin/sh
#
# Icinga Plugin Script (Check Command).
# Aleksey Maksimov <aleksey.maksimov@it-kb.ru>
# Tested on:
# - Debian GNU/Linux 8.10 (Jessie) with Icinga r2.8.0-1
# - Debian GNU/Linux 9.11 (Stretch) with Icinga r2.10.5-1
# Put here: /usr/lib/nagios/plugins/check_snmp_value_from_range.sh 
# Usage example:
# ./check_snmp_value_from_range.sh -H ups001.holding.com -P 1 -C public -i 1.3.6.1.4.1.318.1.1.1.3.2.1.0 -m 1.3.6.1.4.1.318.1.1.1.5.2.3.0 -M 1.3.6.1.4.1.318.1.1.1.5.2.2.0 -E 2 -u VAC
#
PLUGIN_NAME="Icinga Plugin Check Command to get value status from range of values (from SNMP data)"
PLUGIN_VERSION="2018.01.31"
PRINTINFO=`printf "\n%s, version %s\n \n" "$PLUGIN_NAME" "$PLUGIN_VERSION"`
#
# Exit codes
#
codeOK=0
codeWARNING=1
codeCRITICAL=2
codeUNKNOWN=3
#
#
Usage() {
  echo "$PRINTINFO"
  echo "Usage: $0 [OPTIONS]

Option   GNU long option        Meaning
------   ---------------	-------
 -H      --hostname		Host name, IP Address
 -P      --protocol		SNMP protocol version. Possible values: 1|2c|3
 -C      --community		SNMPv1/2c community string for SNMP communication (for example,"public")
 -L      --seclevel		SNMPv3 securityLevel. Possible values: noAuthNoPriv|authNoPriv|authPriv
 -a      --authproto		SNMPv3 auth proto. Possible values: MD5|SHA
 -x      --privproto		SNMPv3 priv proto. Possible values: DES|AES
 -U      --secname		SNMPv3 username
 -A      --authpassword		SNMPv3 authentication password
 -X      --privpasswd		SNMPv3 privacy password
 -i	 --oid-curr		OID for monitoring
 -m	 --oid-min		OID for low limit of value from "oid-curr"
 -M	 --oid-max		OID for high limit of value from "oid-curr"
 -E	 --exit-code		Script exit code (if value from "oid-curr" not in range of values "oid-min" - "oid-max"). Possible values: 1|2
 -u 	 --units		Units of value from "oid-curr"
 -l	 --perfdata-label	Label for perfomance data output (perfdata enabled if "perfdata-label" not empty)
 -q      --help			Show this message
 -v      --version		Print version information and exit

"
}
#
# Parse arguments
#
if [ -z $1 ]; then
    Usage; exit $codeUNKNOWN;
fi
#
OPTS=`getopt -o H:P:C:L:a:x:U:A:X:i:m:M:E:u:l:qv -l hostname:,protocol:,community:,seclevel:,authproto:,privproto:,secname:,authpassword:,privpasswd:,oid-curr:,oid-min:,oid-max:,exit-code:,units:,perfdata-label:,help,version -- "$@"`
eval set -- "$OPTS"
while true; do
   case $1 in
     -H|--hostname) HOSTNAME=$2 ; shift 2 ;;
     -P|--protocol)
        case "$2" in
        "1"|"2c"|"3") PROTOCOL=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use '1' or '2c' or '3'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -C|--community)     COMMUNITY=$2 ; shift 2 ;;
     -L|--seclevel)
        case "$2" in
        "noAuthNoPriv"|"authNoPriv"|"authPriv") v3SECLEVEL=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use 'noAuthNoPriv' or 'authNoPriv' or 'authPriv'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -a|--authproto)
        case "$2" in
        "MD5"|"SHA") v3AUTHPROTO=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use 'MD5' or 'SHA'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -x|--privproto)
        case "$2" in
        "DES"|"AES") v3PRIVPROTO=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use 'DES' or 'AES'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -U|--secname)      v3SECNAME=$2 ; shift 2 ;;
     -A|--authpassword) v3AUTHPWD=$2 ; shift 2 ;;
     -X|--privpasswd)   v3PRIVPWD=$2 ; shift 2 ;;
     -i|--oid-curr)	OIDCURRENT=$2 ; shift 2 ;;
     -m|--oid-min) 	OIDMINLIM=$2 ; shift 2 ;;
     -M|--oid-max)      OIDMAXLIM=$2 ; shift 2 ;;
     -E|--exit-code)
        case "$2" in
        "1"|"2") EXITCODE=$2 ; shift 2 ;;
        *) printf "Unknown value for option %s. Use '1' or '2'\n" "$1" ; exit $codeUNKNOWN ;;
        esac ;;
     -u|--units)     	vUNITS=$2 ; shift 2 ;;
     -l|--perfdata-label) vPERFLABEL=$2 ; shift 2 ;;
     -q|--help)         Usage ; exit $codeOK ;;
     -v|--version)      echo "$PRINTINFO" ; exit $codeOK ;;
     --) shift ; break ;;
     *)  Usage ; exit $codeUNKNOWN ;;
   esac 
done
#
# Set SNMP connection paramaters 
#
vCS=$( echo " -O qvn -v $PROTOCOL" )
if [ "$PROTOCOL" = "1" ] || [ "$PROTOCOL" = "2c" ]
then
   vCS=$vCS$( echo " -c $COMMUNITY" );
elif [ "$PROTOCOL" = "3" ]
then
   vCS=$vCS$( echo " -l $v3SECLEVEL" );
   vCS=$vCS$( echo " -a $v3AUTHPROTO" );
   vCS=$vCS$( echo " -x $v3PRIVPROTO" );
   vCS=$vCS$( echo " -A $v3AUTHPWD" );
   vCS=$vCS$( echo " -X $v3PRIVPWD" );
   vCS=$vCS$( echo " -u $v3SECNAME" );
fi
#
# Get SNMP values
#
vOIDCURRENT=$( snmpget $vCS $HOSTNAME $OIDCURRENT | sed "s/\"//g" )
if [ -z "$vOIDCURRENT" ]; then
   echo "No data from curr.OID $OIDCURRENT !"
   exit $codeUNKNOWN
fi
vOIDMINLIM=$( snmpget $vCS $HOSTNAME $OIDMINLIM | sed "s/\"//g" )
if [ -z "$vOIDMINLIM" ]; then
   echo "No data from min.OID $OIDMINLIM !"
   exit $codeUNKNOWN
fi
vOIDMAXLIM=$( snmpget $vCS $HOSTNAME $OIDMAXLIM | sed "s/\"//g" )
if [ -z "$vOIDMAXLIM" ]; then
   echo "No data from max.OID $OIDMAXLIM !"
   exit $codeUNKNOWN
fi
#
# Format output
#
PRINTRANGE=`printf "(allowed range: $vOIDMINLIM - $vOIDMAXLIM $vUNITS)"`
PRINTPERF=""
if [ ! -z "$vPERFLABEL" ]; then
   PRINTPERF=`printf "| '$vPERFLABEL'=$vOIDCURRENT;;;$vOIDMINLIM;$vOIDMAXLIM"`
fi
PRINTDATA=`printf "$vOIDCURRENT $vUNITS $PRINTRANGE $PRINTPERF"`
#
# Icinga Check Plugin output
#
if [ "$vOIDCURRENT" -gt "$vOIDMAXLIM" ] || [ "$vOIDCURRENT" -lt "$vOIDMINLIM" ]; then

    if [ "$EXITCODE" -eq 2 ]; then
       echo "CRITICAL - $PRINTDATA"
       exit $codeCRITICAL
    elif [ "$EXITCODE" -eq 1 ]; then
       echo "WARNING - $PRINTDATA"
       exit $codeWARNING
    fi

elif [ "$vOIDCURRENT" -le "$vOIDMAXLIM" ] && [ "$vOIDCURRENT" -ge "$vOIDMINLIM" ]; then

    echo "OK - $PRINTDATA"
    exit $codeOK

fi
exit $codeUNKNOWN
