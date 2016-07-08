#!/usr/bin/python

import os
import json
import urllib
import subprocess
import sys

url_base = "http://admin.ci.centos.org:8080"
api_key = os.environ['API_KEY']
count = os.environ['MACHINE_COUNT'] if os.environ.get('MACHINE_COUNT') != None else "1"
ver = "7"
arch = "x86_64"
req_url = "%s/Node/get?key=%s&ver=%s&arch=%s&count=%s" %  (url_base, api_key, ver, arch, count)

jsondata = urllib.urlopen(req_url).read()
data = json.loads(jsondata)

# Setup some variables. Can be passed as env variables via the job config. Otherwise defaults apply
repo_url = os.environ['REPO_URL']  if os.environ.get('REPO_URL') != None else 'https://github.com/projectatomic/vagrant-service-manager.git'
branch = os.environ['BRANCH']  if os.environ.get('BRANCH') != None else 'master'

def execute_on_host( host, cmd, error_message ):
    # build command to execute install and test commands via ssh
    ssh_cmd  = "ssh -t -t "
    ssh_cmd += "-o UserKnownHostsFile=/dev/null "
    ssh_cmd += "-o StrictHostKeyChecking=no "
    ssh_cmd += "root@%s " % (host)

    cmd = '%s "%s"' % (ssh_cmd, cmd)
    print "Executing: %s" % (cmd)
    exit_code = subprocess.call(cmd, shell=True)
    if exit_code != 0 : sys.exit(error_message)
    return

def prepare_pull_request_build(host):
    pr_branch = os.environ['ghprbSourceBranch']
    pr_author_repo = os.environ['ghprbAuthorRepoGitUrl']

    branch_cmd  = 'cd vagrant-service-manager && '
    branch_cmd += "git checkout -b %s" % (pr_branch)
    execute_on_host(host, branch_cmd, "Unable to create branch for pull request build")

    pull_cmd  = 'cd vagrant-service-manager && '
    pull_cmd += "git pull --no-edit %s %s " % (pr_author_repo, pr_branch)
    execute_on_host(host, pull_cmd, "Unable to pull pull request")
    return

for host in data['hosts']:

    # run the Ansible playbook
    ansible_cmd  = 'yum -y install git epel-release ansible1.9 && '
    ansible_cmd += 'yum -y install ansible1.9 && '
    ansible_cmd += 'git clone %s && ' % repo_url
    ansible_cmd += 'cd vagrant-service-manager && '
    ansible_cmd += 'git checkout %s && ' % branch
    ansible_cmd += 'cd .ci/ansible && '
    ansible_cmd += 'ANSIBLE_NOCOLOR=1 ansible-playbook site.yml'
    execute_on_host(host, ansible_cmd, "Ansible playbook failed")

    # if we deal with a pull request build we need to prepare the source
    if os.environ.get('ghprbPullId') != None:
        prepare_pull_request_build(host)

    # setup the environment
    setup_cmd  = 'cd vagrant-service-manager && '
    setup_cmd += 'gem install bundler && '
    setup_cmd += 'bundle install --no-color'
    execute_on_host(host, setup_cmd, "Unable to setup Ruby environment")

    # run build and features
    build_cmd  = 'cd vagrant-service-manager && '
    build_cmd += 'bundle exec rake build && '
    build_cmd += 'bundle exec rake features CUCUMBER_OPTS=\'-p ci\' PROVIDER=libvirt BOX=adb,cdk'
    execute_on_host(host, build_cmd, "Tests failures")

    done_nodes_url = "%s/Node/done?key=%s&sside=%s" % (url_base, api_key, data['ssid'])
    print urllib.urlopen(done_nodes_url)
