#
# Cookbook Name:: liferay
# Recipe:: user
#
# Copyright (C) 2014
#
#
#

liferay_user node['liferay']['user'] do
  group node['liferay']['group']
  group_id node['liferay']['group_id']
  action :create
end