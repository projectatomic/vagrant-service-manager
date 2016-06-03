#!/usr/bin/python

import os
import json
import urllib
import subprocess
import sys

repo_url = os.environ['REPO_URL']
branch = os.environ['BRANCH']

url_base = "http://admin.ci.centos.org:8080"
api_key = os.environ['API_KEY']
count = os.environ['MACHINE_COUNT']
ver = "7"
arch = "x86_64"
req_url = "%s/Node/get?key=%s&ver=%s&arch=%s&count=%s" %  (url_base, api_key, ver, arch, count)

jsondata = urllib.urlopen(req_url).read()

data = json.loads(jsondata)

for host in data['hosts']:
    # build command to execute install and test commands via ssh
    ssh_cmd  = "ssh -t -t "
    ssh_cmd += "-o UserKnownHostsFile=/dev/null "
    ssh_cmd += "-o StrictHostKeyChecking=no "
    ssh_cmd += "root@%s " % (host)

    ansible_cmd  = 'yum -y install git epel-release ansible1.9 && '
    ansible_cmd += 'yum -y install ansible1.9 && '
    ansible_cmd += 'git clone %s &&' % repo_url
    ansible_cmd += 'cd vagrant-service-manager &&'
    ansible_cmd += 'git checkout %s &&' % branch
    ansible_cmd += 'cd .ci/ansible &&'
    ansible_cmd += 'ANSIBLE_NOCOLOR=1 ansible-playbook site.yml'

    cmd = '%s "%s"' % (ssh_cmd, ansible_cmd)

    exit_code = subprocess.call(cmd, shell=True)
    if exit_code != 0 : sys.exit("Ansible playbook failed")

    # actual tests
    build_cmd  = 'cd vagrant-service-manager &&'
    build_cmd += 'gem install bundler -v 1.10.0 &&'
    build_cmd += 'bundle install --no-color &&'
    build_cmd += 'bundle exec rake build &&'
    build_cmd += 'bundle exec rake get_adb[\'libvirt\'] &&'
    build_cmd += 'bundle exec rake features CUCUMBER_OPTS=\'-p ci\' PROVIDER=libvirt'

    cmd = '%s "%s"' % (ssh_cmd, build_cmd)

    exit_code = subprocess.call(cmd, shell=True)
    if exit_code != 0 : sys.exit("Tests failed")

    done_nodes_url = "%s/Node/done?key=%s&sside=%s" % (url_base, api_key, data['ssid'])

    print urllib.urlopen(done_nodes_url)
