[servers]
server ansible_host=<gateway_public_ip>

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file=/home/xaistrying/.ssh/id_rsa
