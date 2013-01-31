SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=acline@us.ibm.com
HOME=/root
0 12 * * *     cd /opt/vadar; rvm use 1.9.3; ruby vadar.rb daily_audit