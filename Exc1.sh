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
  name: Install the apache web service
  become: yes
  tasks:
    - name: install apache
      yum:
        name: httpd
        state: present

    - name: start httpd
      service:
        name: httpd
        state: started
EOF
#!/usr/bin/bash
echo cat install_apache.yml
cd ..
ansible-playbook ~/apache_basic/install_apache.yml -i hosts
