{% from "jenkins/map.jinja" import jenkins with context %}

jenkins_group:
  group.present:
    - name: {{ jenkins.group }}
    - system: True

jenkins_user:
  file.directory:
    - name: {{ jenkins.home }}
    - user: {{ jenkins.user }}
    - group: {{ jenkins.group }}
    - mode: 0755
    - require:
      - user: jenkins_user
      - group: jenkins_group
  user.present:
    - name: {{ jenkins.user }}
    - groups:
      - {{ jenkins.group }}
    - system: True
    - home: {{ jenkins.home }}
    - shell: /bin/bash
    - require:
      - group: jenkins_group

jenkins:
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    - file: {{jenkins.deb_apt_source}}
    - name: deb http://pkg.jenkins.io/debian binary/
    - key_url: http://pkg.jenkins.io/debian/jenkins.io.key
    - require_in:
      - pkg: jenkins
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
  service.running:
    - enable: True
    - watch:
      - pkg: jenkins{% from "jenkins/map.jinja" import jenkins with context %}

copy_jobs:
  file.recurse:
    - name: /var/lib/jenkins/jobs
    - source: salt://jenkins/jobs
    - include_empty: True

copy_plugins:
  file.recurse:
    - name: /var/lib/jenkins/plugins
    - source: salt://jenkins/plugins
    - include_empty: True

fileserver_backend:
   - git

#gitfs_remotes:
#  - https://github.com/valemarcos/saltstack/blob/master/elasticsearch_kibana_fluentd.sh

#gitfs_mountpoint: salt://jenkins/test

