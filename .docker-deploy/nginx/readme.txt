开启ssl 免费
https://certbot.eff.org/lets-encrypt/centosrhel7-nginx.html


yum -y install yum-utils
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
sudo yum install certbot python2-certbot-nginx
sudo certbot --nginx
sudo certbot --nginx certonly
sudo certbot -a dns-plugin -i nginx -d“* .example.com”-d example.com --server https://acme-v02.api.letsencrypt.org/directory
sudo certbot renew --dry-run
certbot renew
