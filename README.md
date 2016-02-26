CONSUL
======

Ansible role to install and configure Consul


## Example

- To install and configure consul agent

```
  roles:
    - ogonna.iwunze.consul
```


- To configure server as consul master:

```
  vars:
    consul_home:    	"/opt/consul"
    consul_extra_opts:  "-server -bootstrap-expect 1 -ui-dir {{ consul_work_dir }}/ui"

  roles:
    - wunzeco.consul
```
