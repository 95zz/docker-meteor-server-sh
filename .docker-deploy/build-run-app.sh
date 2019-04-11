#!/usr/bin/env bash
echo "构建app docker镜像.."
# 安装 pipework 及统一脚本命令执行和重启管理
# 参考 https://www.jianshu.com/p/d553183d1ef7
source get-local-ip.sh
# 开始构建镜像
docker build --rm -t $1/$2:$3 .
echo "$1/$2:$3 镜像构建成功"
docker_hosts=$4
arr=(${docker_hosts//,/ })
for i in ${!arr[@]}; do
  val=${arr[$i]}
  name=${val%:*}
  ip=${val#*:}
  appName=$1$i
  docker stop $appName && docker rm $appName
  docker run -it -d --name $appName -e ROOT_URL=http://$name -e PORT=80 -e MONGO_URL=mongodb://$5:27017/$1 --network=mynetwork  --ip $ip $1/$2:$3 && docker exec -tt $appName /bin/sh -c "cd /meteor-app/bundle && pm2 start main.js" && echo "$appName 连接 docker0接口 $ip 启动成功"
done
