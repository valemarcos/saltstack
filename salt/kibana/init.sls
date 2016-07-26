{% from "kibana/map.jinja" import kibana with context %}
{% set os_family = grains['os_family'] %}

install_kibana_dependencies:
  pkg.installed:
    - pkgs: {{ kibana.pkgs }}
    - require_in:
        - pkgrepo: configure_kibana_package_repo
    - reload_modules: True
    - update: True

configure_kibana_package_repo:
  pkgrepo.managed:
    - humanname: elasticsearch
    - name: deb http://packages.elastic.co/kibana/4.5/debian stable main 
    - keyserver: pgp.mit.edu
    - keyid: D88E42B4

install_kibana:
  pkg.installed:
    - name: kibana
    - require:
        - pkgrepo: configure_kibana_package_repo

configure_kibana:
  file.managed:
    - name: /opt/kibana/config/kibana.yml
    - contents: |
        {{ kibana.config | yaml(False) | indent(8) }}
ensure_kibana_ssl_directory:
  file.directory:
    - name: {{ kibana.ssl_directory }}
    - makedirs: True

setup_kibana_ssl_cert:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: ssl
    - cacert_path: /etc/salt/
    - require:
        - file: ensure_kibana_ssl_directory
    {% for arg, val in salt.pillar.get('kibana:ssl:cert_params', {}).items() -%}
    - {{ arg }}: {{ val }}
    {% endfor -%}

{% if salt.grains.get('init') == 'systemd' %}
add_node_environment_variables:
  file.managed:
    - name: /etc/systemd/system/kibana.service.d/kibana_env.conf
    - makedirs: True
    - contents: |
        [Service]
        {% for env in kibana.kibana_env %}
        Environment='{{ env }}'
        {% endfor %}
reload_kibana_systemd_units:
  cmd.wait:
    - name: systemctl daemon-reload
    - watch:
        - file: add_node_environment_variables
{% elif salt.grains.get('init') == 'upstart' %}
add_node_environment_variables:
  file.blockreplace:
    - name: /etc/init.d/kibana
    - marker_start: '  # Setup any environmental stuff beforehand'
    - marker_end: '  # Run the program!'
    - content: |
        {% for env in kibana.kibana_env %}
        export {{ env }}
        {% endfor %}
{% endif %}

kibana_service:
  service.running:
    - name: kibana
    - enable: True
    - watch:
        - file: configure_kibana

