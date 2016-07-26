{% from "fluentd/map.jinja" import fluentd, fluentd_service with context %}

install_fluentd_dependencies:
  pkg.installed:
    - pkgs:
        - ruby 
        - ruby-dev
        - build-essential

install_fluentd_gem:
  gem.installed:
    - name: fluentd

configure_fluentd:
  file.managed:
    - name: /etc/fluent/fluent.conf
    - source: salt://fluentd/templates/fluent.conf
    - makedirs: True
    - template: jinja
    - context:
        log_level: {{ fluentd.global_log_level }}

make_fluent_config_directory:
  file.directory:
    - name: /etc/fluent/fluent.d/
    - makedirs: True

fluentd_control_script:
  file.managed:
    - name: /usr/local/bin/fluentd.sh
    - source: salt://fluentd/files/fluentd.sh
    - mode: 0755

configure_fluentd_service:
  file.managed:
    - name: /etc/systemd/system/fluentd.service 
    - source: salt://fluentd/files/fluentd.service

start_fluentd_service:
  service.running:
    - name: fluentd
    - enable: True
    - require:
        - file: configure_fluentd_service
    - watch:
        - file: configure_fluentd
