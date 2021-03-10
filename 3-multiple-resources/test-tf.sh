#!/bin/bash
terraform output -raw public_ip_address >> ./hosts
ansible-playbook -i hosts ansible-test.yaml