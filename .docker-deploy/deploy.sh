#!/usr/bin/env bash
set -e
source env.sh
echo "------------------------------------- 本地编译工作中.. ----------------------------------"
mkdir -p $build_dir
cd $app_dir
echo "应用安装依赖包和编译文件"
meteor npm install
meteor build $build_dir --architecture=$deploy_architecture --server-only
echo "编译成功"
cp $build_dir/app.tar.gz $app_deploy_settings_dir
echo "复制文件成功"

echo "------------------------------------- 连接部署主机中.. ----------------------------------"
# 远程创建项目路径
if [ $first_deploy == 1 ]; then
 echo "创建项目路径 并 修改可执行权限"
 sshpass -p "$deploy_password" ssh -o "StrictHostKeyChecking no" -p $deploy_port $deploy_user@$deploy_host "cd / && mkdir -p ${deploy_path} && chmod +x ${deploy_path}"
 echo "创建项目路径并修改权限成功"
fi
# 上传文件
echo "上传文件"
sshpass -p "$deploy_password" scp -P $deploy_port -r $app_deploy_settings_dir $deploy_user@$deploy_host:$deploy_path
echo "上传成功"
echo "检测生产环境"
sshpass -p "$deploy_password" ssh -o "StrictHostKeyChecking no" -p $deploy_port $deploy_user@$deploy_host "cd ${deploy_path}/.docker-deploy && bash install-server-env.sh $first_deploy && bash build-run-app.sh $lower_app_name $lower_app_tag $app_version $proudction_docker_hosts $proudction_mongodb_host && echo '部署成功 ！！'"
# 替换部署文件 firstDeploy
sed -i '' 's/"firstDeploy": 1/"firstDeploy": 0/g' deploy-settings.json
# 删除 .docker-deploy文件下app压缩包，避免再次打包时会打入新的压缩包内
rm -rf $app_deploy_settings_dir/app.tar.gz
