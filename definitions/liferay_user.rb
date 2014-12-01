#
# Cookbook Name:: liferay
# Definition:: liferay_user
#
# Copyright (C) 2014
#
# Author:: Orin Fink
#


define :liferay_user do
  include_recipe 'users'

  users_manage params[:name] do
    group_name params[:group]
    group_id params[:group_id]
    action :create
  end

  sudo params[:name] do
    user params[:name]
    group params[:group]
    nopasswd true
  end
end