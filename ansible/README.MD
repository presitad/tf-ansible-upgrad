# Steps to install docker using ansible

1. copy invertory and playbook.yaml in bastion at /etc/ansible location
2. In terraform apply output we will get IP address of jenkina and app instance copy ip address to inventory.
3. copy .pem file from local to bastion host
    ` scp -i ~/task1-key.pem   ~/task1-key.pem ubuntu@50.19.135.207:~/task1-key.pem`
4. command to run playbook. `ansible-playbook playbook.yaml -i inventory --private-key ~/task1-key.pem `
5. ssh to app and jenkins instance and check docker is working .