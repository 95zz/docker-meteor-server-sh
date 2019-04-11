#meteor docker pm2 多项目多节点自定义网桥组部署方式

```
部署前，请认真看完四点
1.将.docker-deploy复制到项目根路径
2.设置服务器信息{简单部署，只需替换服务器ip地址和密码}
3.cd path/.docker-deploy && sh deploy.sh
4.提示：如果服务器中部署环境自定安装，则在配置文件deploy-settings.json中将
firstDeploy改为0
------------------------------------------- mongodb 操作手册 -------------------------------
# authorization: enabled #这里是开启验证功能，暂时先关闭，等创建完root用户再开起来进行验证
直接使用mongo命令进行连接，默认端口是27017
db.createUser({user:"root",pwd:"rootpassword",roles:[{role:"root",db:"admin"}]})
修改配置文件
authorization: enabled
重启mongd服务
验证
mongo -u root -p rootpassword --authenticationDatabase admin

------------------------------------------- docker mongodb操作手册 ----------------------------
docker mongodb 运行手册
docker run -it -d --restart=always --name mongodb --net mynetwork --ip 192.168.1.104 mongodb:latest
采用dhcp方式分配ip(暂没有用到)
sudo pipework docker0 mynetwork web dhcp
将web容器连接到docker0网桥接口中
pipework docker0 hjieapp0 192.168.1.103/24@192.168.1.1

##### 删除无用安装包(基本无风险)
yum autoremove
##### 删除名称或标签为none的镜像<br>
docker rmi -f  `docker images | grep '<none>' | awk '{print $3}'`
##### 删除异常停止的docker容器<br>
docker rm `docker ps -a | grep Exited | awk '{print $1}'`
##### 查看所有dockker中容器 IP地址<br>
docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
#### 卸载MongoDB
sudo yum erase $(rpm -qa | grep mongodb-org)
sudo rm -r /var/log/mongodb /var/lib/mongo

------------------------------------------- docker 操作手册 ---------------------------------
# cluster mode 模式启动4个main.js的应用实例 
docker exec -ti hjieapp0 /bin/sh -c "pm2 start /meteor-app/bundle/main.js -i 4" # 4个应用程序会自动进行负载均衡
docker run -it -d --name hjieapp0 -e ROOT_URL=http://jxtpro.com -e PORT=80 -e MONGO_URL=mongodb://192.168.1.104:27017/hjieapp --network=mynetwork --ip 192.168.1.103  hjieapp/release:1.0.0
docker exec -ti hjieapp0 /bin/sh -c "cd /meteor-app/bundle && pm2 start main.js"
显示所有应用程序的日志
docker exec -ti hjieapp0 /bin/sh -c "pm2 logs"
docker exec -ti hjieapp0 /bin/sh -c "pm2 stop 0"
docker exec -ti hjieapp0 /bin/sh -c "pm2 stop all"
docker exec -ti hjieapp0 /bin/sh -c "pm2 delete all"
docker exec -ti hjieapp0 /bin/sh -c "pm2 delete 0"
列表 PM2 启动的所有的应用程序
docker exec -ti hjieapp0 /bin/sh -c "pm2 list"
显示每个应用程序的CPU和内存占用情况
docker exec -ti hjieapp0 /bin/sh -c "pm2 monit"
pm2 scale main 10 # 把名字叫main的应用扩展到10个实例
docker exec -ti hjieapp0 /bin/sh -c "pm2 scale main 10"
```
