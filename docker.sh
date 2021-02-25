###
 # @Author: your name
 # @Date: 2021-02-16 18:28:56
 # @LastEditTime: 2021-02-16 20:36:59
 # @LastEditors: Please set LastEditors
 # @Description: In User Settings Edit
 # @FilePath: \k8s\shell\docker.sh
### 
#!/bin/bash
system_docker_install(){
    echo y|yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo  https://download.docker.com/linux/centos/docker-ce.repo 
    yum makecache fast
    echo y|yum -y install docker 
    systemctl start docker && systemctl enable docker
    echo "source <(docker completion bash)" >> ~/.bashrc && source  ~/.bashrc
    #docker version

}

main(){
    system_docker_install;

}

main