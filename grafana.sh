sudo yum install -y wget fontconfig
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-9.4.7-1.x86_64.rpm
sudo yum install -y grafana-enterprise-9.4.7-1.x86_64.rpm
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo /bin/systemctl start grafana-server
sudo /bin/systemctl status grafana-server --no-pager
