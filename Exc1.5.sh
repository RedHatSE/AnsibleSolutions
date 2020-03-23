#!/bin/
cd ~/apache-basic-playbook
rm -rf roles
mkdir roles
cd roles
ansible-galaxy init apache-simple
cd ~/apache-basic-playbook/roles/apache-simple/
rm -rf files tests
cd ~/apache-basic-playbook
mv site.yml site.yml.bkup
cat << EOF | tee site.yml
---
- hosts: web
  name: This is my role-based playbook
  become: yes

  roles:
    - apache-simple

EOF
cat << EOF | tee roles/apache-simple/defaults/main.yml
---
# default file for apache simple
apache_test_message: This is a test message
apache_max_keep_alive_requests: 115
EOF
cat << EOF | tee roles/apache-simple/vars/main.yml
---
# vars file for apache-simple
httpd_packages:
  - httpd
  - mod_wsgi
EOF
cat << EOF | tee roles/apache-simple/handlers/main.yml
---
- name: restart apache service
  service:
    name: httpd
    state: restarted
    enabled: yes
EOF
cat << EOF | tee roles/apache-simple/tasks/main.yml
---
# tasks file for apache-simple
- name: install httpd packages
  package:
    name: "{{ item }}"
    state: present
  with_items: "{{ httpd_packages }}"
  notify: restart apache service

- name: create site-enabled directory
  file:
    name: /etc/httpd/conf/sites-enabled
    state: directory

- name: copy httpd.conf
  template:
    src: templates/httpd.conf.j2
    dest: /etc/httpd/conf/httpd.conf
  notify: restart apache service

- name: copy index.html
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html

- name: start httpd
  service:
    name: httpd
    state: started
    enabled: yes
EOF
mkdir -p ~/apache-basic-playbook/roles/apache-simple/templates/
cd ~/apache-basic-playbook/roles/apache-simple/templates/
curl -O https://raw.githubusercontent.com/RedHatSE/JinjaTemplates/master/httpd.conf.j2
curl -O https://raw.githubusercontent.com/RedHatSE/JinjaTemplates/master/index.html.j2
rm -rf ~/apache-basic-playbook/templates/
cd ~/apache-basic-playbook
ansible-playbook -i ../hosts site.yml
