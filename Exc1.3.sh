#! /bin/#!/usr/bin/env bash
cd ~
rm -rf ~/apache-basic-playbook
mkdir apache-basic-playbook
cd ~/apache-basic-playbook
cat << EOF | tee site.yml
---
- hosts: web
  name: This is a play within a playbook
  become: yes
  vars:
    httpd_packages:
      - httpd
      - mod_wsgi
    apache_test_message: This is a test message
    apache_max_keep_alive_requests: 115

  tasks:
    - name: httpd packages are present
      package:
        name: "{{ item }}"
        state: present
      with_items: "{{ httpd_packages }}"
      notify: restart apache service

## if anything changes a handler below will be notified
## with_items is looking at the var_files varaible with the name httpd_packages each task under that variable is an item

    - name: site-enabled directory is present
      file:
        name: /etc/httpd/conf/sites-enabled
        state: directory

    - name: latest httpd.conf is present
      template:
        src: templates/httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: restart apache service
## uses templates to move httpd.conf notice, the j2 that indicates a Jinja file

    - name: latest index.html is present
      template:
        src: templates/index.html.j2
        dest: /var/www/html/index.html
## using another Jinja j2 file this will be moved to the target destination

    - name: httpd is started and enabled
      service:
        name: httpd
        state: started
        enabled: yes

## notice the handlers you can have more than one and are called by name
## if any change with a notify was made the handler will run
## if no change the handler will not run.
  handlers:
    - name: restart apache service
      service:
        name: httpd
        state: restarted
        enabled: yes
EOF
mkdir ~/apache-basic-playbook/templates
cd ~/apache-basic-playbook/templates
curl -O https://raw.githubusercontent.com/RedHatSE/JinjaTemplates/master/httpd.conf.j2
curl -O https://raw.githubusercontent.com/RedHatSE/JinjaTemplates/master/index.html.j2
cd ~/apache-basic-playbook/
echo cat ~/apache-basic-playbook/site.yml
cd ~
ansible-playbook ~/apache-basic-playbook/site.yml -i hosts
