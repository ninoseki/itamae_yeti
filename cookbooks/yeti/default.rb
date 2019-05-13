# frozen_string_literal: true

user "yeti"

execute "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -"
execute 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list'
execute "curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -"
execute "sudo apt-get update"

"build-essential git python-dev mongodb redis-server libxml2-dev libxslt1-dev zlib1g-dev python-virtualenv python-pip nginx nodejs yarn".split.each do |name|
  package name
end

git "/opt/yeti" do
  repository "https://github.com/yeti-platform/yeti.git"
end

execute "pip install --upgrade pip"
execute "pip install uwsgi"

execute "install python dependencies" do
  cwd "/opt/yeti"
  command "pip install -r requirements.txt"
end

execute "install yarn dependencies" do
  cwd "/opt/yeti"
  command "yarn install"
end

Dir.glob(File.expand_path("./files/etc/systemd/system/*.service", __dir__)).each do |path|
  basename = File.basename(path)
  remote_file "/etc/systemd/system/#{basename}"
end

execute "systemctl daemon-reload"

%w(yeti_oneshot.service yeti_feeds.service yeti_exports.service yeti_analytics.service yeti_beat.service yeti_uwsgi.service).each do |name|
  service name do
    action :enable
  end
end

execute "chown -R yeti:yeti /opt/yeti"
execute "chmod +x /opt/yeti/yeti.py"

directory "/var/log/yeti" do
  owner "yeti"
  group "yeti"
end

file "/etc/nginx/sites-enabled/default" do
  action :delete
end

remote_file "/etc/nginx/sites-available/yeti"

link "/etc/nginx/sites-enabled/yeti" do
  to "/etc/nginx/sites-available/yeti"
end

service "nginx" do
  action :restart
end

service "yeti_oneshot.service" do
  action :restart
end

sleep 5

%w(yeti_feeds.service yeti_exports.service yeti_analytics.service yeti_beat.service yeti_uwsgi.service).each do |name|
  service name do
    action :restart
  end
end
