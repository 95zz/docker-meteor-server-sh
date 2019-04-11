#!/usr/bin/env bash
# app info
echo "------------------------------------- 本地工作已经开始 ----------------------------------"
app_name=$(node -p "require('./deploy-settings.json').app.name")
app_tag=$(node -p "require('./deploy-settings.json').app.tag")
app_version=$(node -p "require('./deploy-settings.json').app.version")
# deploy
deploy_host=$(node -p "require('./deploy-settings.json').deploy.host")
deploy_user=$(node -p "require('./deploy-settings.json').deploy.user")
deploy_port=$(node -p "require('./deploy-settings.json').deploy.port")
deploy_password=$(node -p "require('./deploy-settings.json').deploy.password")
deploy_path=$(node -p "require('./deploy-settings.json').deploy.path")
deploy_architecture=$(node -p "require('./deploy-settings.json').deploy.architecture")
first_deploy=$(node -p "require('./deploy-settings.json').deploy.firstDeploy")
skip_build=$(node -p "require('./deploy-settings.json').deploy.skipBuild")
proudction_root_url=$(node -p "require('./deploy-settings.json').deploy.proudction.rootUrl")
proudction_port=$(node -p "require('./deploy-settings.json').deploy.proudction.port")
proudction_docker_hosts=$(node -p "require('./deploy-settings.json').deploy.proudction.hosts")
proudction_mongodb_host=$(node -p "require('./deploy-settings.json').deploy.proudction.mongodb.host")
# 转小写
lower_app_name=$(tr '[A-Z]' '[a-z]' <<<"$app_name")
lower_app_tag=$(tr '[A-Z]' '[a-z]' <<<"$app_tag")
# local build info
app_deploy_settings_dir=$PWD
app_dir=$(dirname "$app_deploy_settings_dir")
build_dir=$(dirname "$app_dir")/.build
