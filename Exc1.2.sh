#!/usr/bin/bash
cd ~
echo -e "mkdir ~/apache_basic\ncd ~/apache_basic"
rm -rf ~/apache_basic
mkdir ~/apache_basic
cd ~/apache_basic
touch install_apache.yml
cat << EOF | tee install_apache.yml
---
- hosts: web
# Remove Apache
  name: Remove the apache web service
  become: yes
  tasks:

# we will change the name to remove apache
    - name: Remove apache
      yum:
        name: httpd
#Changing state to Absent to remove the product
        state: absent

#Since we Removed the service we do not care about the state we will comment out everything below
#    - name: start httpd
#      service:
#        name: httpd
#        state: started
EOF
echo cat install_apache.yml
cd ..
ansible-playbook ~/apache_basic/install_apache.yml -i hosts
