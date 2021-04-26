#!/usr/bin/bash
if [ -e /var/log/httpd/access_log ]
then
  echo "--------------------- REPORT OF HTTPD LOGS -------------------------------------"

  echo " "
  echo " "
  c=$(awk '{ print }' /var/log/httpd/access_log | grep $(date +%e/%b/%G) | awk '{ print $1 }' /var/log/httpd/access_log | sort | wc -l)
  echo "Total client visited today ----> $c"
  echo " "
  nc=$(awk '{ print }' /var/log/httpd/access_log | grep $(date +%e/%b/%G) | awk '{ print $1 }' /var/log/httpd/access_log | sort | uniq | wc -l)
  echo "Number of unique client today -----> $nc"
  echo " "
  sp=$(awk '{ print }' /var/log/httpd/access_log | grep $(date +%e/%b/%G) | awk '$9==200{ print $7 }' /var/log/httpd/access_log | sort | uniq -c | awk 'END { print $2 }' )
  n=$(awk '{ print }' /var/log/httpd/access_log | grep $(date +%e/%b/%G) | awk '$9==200{ print $7 }' /var/log/httpd/access_log | wc -l)
  echo "Most visited page today with success code 200 -----> $sp "
  echo "Number of times page visited -----> $n"
  echo " "
  nsp=$(awk '{ print }' /var/log/httpd/access_log | grep $(date +%e/%b/%G) | awk '$9!=200{ print $7 }' /var/log/httpd/access_log  | sort | uniq -c | awk 'END { print $2 }')
  nn=$(awk '{ print }' /var/log/httpd/access_log | grep $(date +%e/%b/%G) | awk '$9==200{ print $7 }' /var/log/httpd/access_log | wc -l)
  echo "Most visited page today with success code other than 200 -----> $nsp "
  echo "Number of times page visited -----> $nn"
  echo " "
  echo " "
  echo "-------------------- CHECKING FOR DOS ATTACK --------------------------------"

  echo " "
  echo " "
  n1=$(sudo awk '{ print $1}' /var/log/httpd/access_log | sort | uniq -c | awk 'END{ print $1 }')

  ip1=$(sudo awk '{ print $1}' /var/log/httpd/access_log | sort | uniq -c | awk 'END{ print $2 }')

  sleep 20

  n2=$(sudo awk '{ print $1}' /var/log/httpd/access_log | sort | uniq -c | awk 'END{ print $1 }')

  ip2=$(sudo awk '{ print $1}' /var/log/httpd/access_log | sort | uniq -c | awk 'END{ print $2 }')

  echo "Max request from:  $ip2 -----> $n2"

  if [ $ip1 == $ip2 ]
  then
    diff=$(expr n2 - n1)
    if [ $diff >= 50 ]
    then
      echo "There are chances of dos attack from $ip1"
      echo "Do you want to block $ip1 [1(Yes) | 0(No)]"
      read des
      [ $des == 1 ]
      echo $?
      if [ $des == '1' ]
      then
        sudo firewall-cmd --permanent --add-rich-rule="rule family='ipv4' source address='$ip1' reject"
        sudo firewall-cmd --reload
	echo "$ip1 blocked!!!!!"
	echo "to unblock the ip: sudo firewall-cmd --permanent --remove-rich-rule=\"rule family='ipv4' source address='$ip1' reject \""
	echo "followed by:  firewall-cmd --reload"
      fi
    fi
  fi

else
  echo "/var/log/httpd/access_log  doesn't EXIST !!!!"
fi
