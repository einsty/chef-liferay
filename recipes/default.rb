#
# Cookbook Name:: liferay
# Recipe:: default
#
# Copyright 2013, Thirdwave, LLC
# Authors:
# 		Adam Krone <adam.krone@thirdwavellc.com>
#		Henry Kastler <henry.kastler@thirdwavellc.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


user node['liferay']['user'] do
  comment "Liferay User"
  home "/home/#{node['liferay']['user']}"
  shell "/bin/bash"
  supports :manage_home=>true
end

remote_file "#{node['liferay']['download_directory']}/#{node['liferay']['download_filename']}" do
  owner "#{node['liferay']['user']}"
  group "#{node['liferay']['group']}"
  source node['liferay']['download_url']
  action :create_if_missing
  notifies :run, "bash[Extract Liferay]", :immediately
end


bash "Extract Liferay" do
  cwd node['liferay']['download_directory']
  user node['liferay']['user']
  group node['liferay']['group']
  code <<-EOH
    unzip #{node['liferay']['download_filename']}
    EOH
  action :nothing
  notifies :run, "bash[Move Liferay]", :immediately
end

bash "Move Liferay" do
  cwd node['liferay']['download_directory']
  user "root"
  code <<-EOH
    mv #{node['liferay']['download_version']} #{node['liferay']['install_directory']}
    EOH
  action :nothing
end

link "#{node['liferay']['install_directory']}/liferay" do
  owner "#{node['liferay']['user']}"
  group "#{node['liferay']['group']}"
  to "#{node['liferay']['install_directory']}/#{node['liferay']['download_version']}"
end

link "#{node['liferay']['install_directory']}/liferay/tomcat" do
  owner "#{node['liferay']['user']}"
  group "#{node['liferay']['group']}"
  to "#{node['liferay']['install_directory']}/liferay/#{node['liferay']['tomcat_version']}"
end

file "#{node['liferay']['install_directory']}/liferay/tomcat/bin/*.bat" do
  action :delete
end

template "#{node['liferay']['install_directory']}/liferay/tomcat/bin/setenv.sh" do
  source "setenv.sh.erb"
  mode 01755
end

directory "#{node['liferay']['install_directory']}/liferay/tomcat/webapps/welcome-theme" do
  recursive true
  action :delete
end

# Configure the Liferay Service and Log Rotations
template "/etc/init.d/liferay" do
  source "init.d.liferay.erb"
  mode 00755
  variables({
    :liferay_home => "#{node['liferay']['install_directory']}/liferay"
    :user => node['liferay']['user']
    :group => node['liferay']['group']
  })
end

link "/etc/rc1.d/K99liferay" do
	to "/etc/init.d/liferay"
end

link "/etc/rc2.d/S99liferay" do
	to "/etc/init.d/S99liferay"
end

template "/etc/logrotate.d/liferay" do
  source "logrotate.d.liferay.erb"
  mode 00755
  variables({
    :liferay_log_home => "#{node['liferay']['install_directory']}/liferay/tomcat/logs"
  })
end

directory "#{node['liferay']['install_directory']}/liferay/deploy" do
  owner "#{node['liferay']['user']}"
  group "#{node['liferay']['group']}"
  mode 01755
  action :create
  recursive true
end

template "#{node['liferay']['install_directory']}/liferay/tomcat/conf/server.xml" do
	source "server.xml.erb"
	mode 00755	
	owner "#{node['liferay']['user']}"
	group "#{node['liferay']['group']}"
	variables({
		:port => node[:liferay][:tomcat][:server_xml][:port]		
	})
end

directory "#{node['liferay']['install_directory']}/liferay/tomcat/conf/Catalina/localhost/" do
	action :create
end

template "#{node['liferay']['install_directory']}/liferay/tomcat/conf/Catalina/localhost/ROOT.xml" do
	source "ROOT.xml.erb"
	mode 00755	
	owner "#{node['liferay']['user']}"
	group "#{node['liferay']['group']}"
	variables({
		:dsn => node[:liferay][:tomcat][:root_xml][:dsn],
		:username => node[:liferay][:tomcat][:root_xml][:username],
		:password => node[:liferay][:tomcat][:root_xml][:password],
		:driver => node[:liferay][:tomcat][:root_xml][:driver],
		:jdbc_url => node[:liferay][:tomcat][:root_xml][:jdbc_url]
	})
end

if "#{node['liferay']['ee']['license_url']}" =~ /^#{URI::regexp}$/
	include_recipe "liferay::patches"	
	include_recipe "liferay::enterprise"
end

bash "copy over ecj" do
	code node['liferay']['copy_ecj']
	action :run
end

bash "load ext" do
	user node['liferay']['user']
	code node['liferay']['load_ext_command']
	action :run
end

bash "Start Liferay" do
	user node['liferay']['user']
	code node['liferay']['start_command']
	action :run
end
