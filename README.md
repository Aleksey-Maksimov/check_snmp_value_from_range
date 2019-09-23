## About

**check_snmp_value_from_range** - Icinga Plugin Check Command to get value status from range of values (from SNMP data)

PreReq: **snpmget** tool

Tested on:

* **Debian GNU/Linux 8.10 (Jessie)** with **Icinga r2.8.0-1**
* **Debian GNU/Linux 9.11 (Stretch)** with **Icinga r2.10.5-1**

 
## Usage

Options:

```
$ /usr/lib/nagios/plugins/check_snmp_value_from_range.sh [OPTIONS]

Option Long option    Meaning
------ ------------   -------
-H    --hostname      Host name, IP Address
-P    --protocol      SNMP protocol version. Possible values: 1|2c|3
-C    --community     SNMPv1/2c community string for SNMP communication (for example,public)
-L    --seclevel      SNMPv3 securityLevel. Possible values: noAuthNoPriv|authNoPriv|authPriv
-a    --authproto     SNMPv3 auth proto. Possible values: MD5|SHA
-x    --privproto     SNMPv3 priv proto. Possible values: DES|AES
-U    --secname       SNMPv3 username
-A    --authpassword  SNMPv3 authentication password
-X    --privpasswd    SNMPv3 privacy password
-i    --oid-curr      OID for monitoring
-m    --oid-min       OID for low limit of value from oid-curr
-M    --oid-max       OID for high limit of value from oid-curr
-E    --exit-code     Script exit code (if value from oid-curr not in range of values oid-min - oid-max). 
                      Possible values: 1|2
-u    --units         Units of value from oid-curr
-l    --perfdata-label Label for perfomance data output (perfdata enabled if label not empty)
-q    --help          Show this message
-v    --version       Print version information and exit

```

Example for APC Smart-UPS/Symmetra:

```
$ ./check_snmp_value_from_range.sh -H ups001.holding.com -P 2c \
-C "public" -i "1.3.6.1.4.1.318.1.1.1.3.2.1.0" \
-m "1.3.6.1.4.1.318.1.1.1.5.2.3.0" \
-M "1.3.6.1.4.1.318.1.1.1.5.2.2.0" \
-E 1 -u "VAC" -l "upsAdvInputLineVoltage"
```
Icinga Director integration manual (in Russian): 

[Icinga плагин check_snmp_value_from_range для отслеживания вхождения значения в допустимый диапазон значений, извлекаемых по протоколу SNMP (на примере мониторинга входного напряжения ИБП)](https://blog.it-kb.ru/2019/09/21/icinga-plugin-check_snmp_value_from_range-for-monitoring-range-of-values-retrieved-via-snmp-ups-input-voltage/)
