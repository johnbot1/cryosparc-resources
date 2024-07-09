ldap_output=$(ldapsearch -LLL -ZZ -x -b "ou=imss,o=caltech,c=us" "(uid=$USER)")
echo $ldap_output
