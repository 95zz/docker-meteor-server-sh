#!/usr/bin/env bash
# 不是第一次构建则返回
if [ $1 == 0 ]; then
  exit
fi

# --------------------------------------------1 安装git-----------------------------------
if ! [ -x "$(command -v git)" ]; then
  yum install git-core
fi

# --------------------------------------------2 安装nodejs-----------------------------------
#安装nodejs
if ! [ -x "$(command -v node)" ]; then
  curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
  sudo yum -y install nodejs
  echo "node 生产环境安装成功！！！"
else
  echo "node 生产环境正常！！！"
fi

# 暂时不用
# --------------------------------------------3 安装mongodb-----------------------------------
# if ! [ -x "$(command -v mongod)" ]; then
# cat << EOF > /etc/yum.repos.d/mongodb-org-4.0.repo
# [mongodb-org-4.0]
# name=MongoDB Repository
# baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/
# gpgcheck=1
# enabled=1
# gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
# EOF
# sudo yum install -y mongodb-org
# # mkdir -p /data/mongodb/data /data/mongodb/logs
# # chown mongod.mongod /data/mongodb/data /data/mongodb/logs -R #默认是使用mongod执行的，所以需要修改一下目录权限
# systemctl start mongod.service
# systemctl enable mongod.service
# echo "mongodb 生产环境安装成功！！！"
# else
# echo "mongodb 生产环境正常！！！"
# fi

# --------------------------------------------3 安装pipework-----------------------------------
if ! [ -x "$(command -v pipework)" ]; then
  git clone https://github.com/95zz/pipework.git
  sudo cp pipework/pipework /usr/local/bin/
  rm -rf pipework
fi

# --------------------------------------------4 安装docker-----------------------------------
if ! [ -x "$(command -v docker)" ]; then
  # sudo yum remove docker docker-common docker-selinux docker-engine
  # rm -rf /var/lib/docker /var/run/docker
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum-config-manager --enable docker-ce-edge
  curl -fsSL https://get.docker.com/ | sh
  sudo yum makecache fast
  yum install deltarpm
  sudo yum install docker-ce
  sudo yum install docker-engine
  sudo systemctl start docker
  sudo systemctl enable docker
  echo "docker生产环境安装成功!!!"
else
  echo "docker生产环境正常!!!"
fi
# --------------------------------------------5 宿主环境配置 -----------------------------------
source get-local-ip.sh
docker system prune --volumes -f
# 安装配置固定ip
docker network create --subnet=$localip/16 mynetwork && echo "网桥创建成功"
#做MongoDB节点 服务器 若能ping通 ,则说明 已经存在MongoDB 无需创建
# --------------------------------------------6 运行 docker mongodb -----------------------------------
ping -c1 -W1 ${$2} &>/dev/null
if [ "$?" == "0" ]; then
    echo "$2 is UP, docker 中 MongoDB 正常运行"
else
    docker build --rm -f "mongodb/Dockerfile" -t alpine:mongodb mongodb
    docker run --restart=always -it -d --name mongodb -p 27017:27017/tcp --network=mynetwork --ip $2 alpine:mongodb && echo "mongodb启动成功"
fi
# --------------------------------------------7 配置 docker Nginx 生产环境 -----------------------------------
docker build --rm -f "nginx/Dockerfile" -t alpine:nginx nginx
docker run --restart=always -it -d --name nginx alpine:nginx && echo "nginx启动成功"
