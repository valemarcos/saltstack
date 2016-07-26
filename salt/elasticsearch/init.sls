{% from "elasticsearch/map.jinja" import elasticsearch with context %}

install_pkg_dependencies:
  pkg.installed:
    - pkgs: {{ elasticsearch.pkgs }}
    - refresh: True
    - require_in:
        - pkgrepo: configure_elasticsearch_package_repo

configure_elasticsearch_package_repo:
  pkgrepo.managed:
    - humanname: elasticsearch
    - name: deb https://packages.elastic.co/elasticsearch/2.x/debian stable main
    - keyserver: pgp.mit.edu
    - keyid: D88E42B4

install_elasticsearch:
  pkg.installed:
    - name: elasticsearch
    - refresh: True
    - require:
        - pkgrepo: configure_elasticsearch_package_repo
        - pkg: install_pkg_dependencies

# Up the count for file descriptors for Lucene https://www.elastic.co/guide/en/elasticsearch/guide/current/_file_descriptors_and_mmap.html
increase_file_descriptor_limit:
  cmd.run:
    - name: sysctl -w fs.file-max={{ elasticsearch.fd_limit }}
  file.append:
    - name: /etc/sysctl.conf
    - text: fs.file_max={{ elasticsearch.fd_limit }}
    - watch_in:
        - service: elasticsearch

increase_max_map_count:
  cmd.run:
    - name: sysctl -w vm.max_map_count={{ elasticsearch.max_map_count }}
  file.append:
    - name: /etc/sysctl.conf
    - text: vm.max_map_count={{ elasticsearch.max_map_count }}
    - watch_in:
        - service: elasticsearch

configure_elasticsearch:
  file.managed:
    - name: /etc/elasticsearch/elasticsearch.yml
    - contents: |
        {{ elasticsearch.configuration_settings | yaml(False) | indent(8)}}
    - makedirs: True
    - watch_in:
        - service: elasticsearch_service

elasticsearch_service:
  service.running:
    - name: elasticsearch
    - enable: True

