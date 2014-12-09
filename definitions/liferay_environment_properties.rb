#
# Cookbook Name:: liferay
# Definition:: liferay_environment_properties
#
# Copyright (C) 2014
#
# Author:: Orin Fink
#

define :liferay_environment_properties do

  template params[:destination_path] do
    source params[:template_path]
    mode 00755  
    owner node['liferay']['user']
    group node['liferay']['group']
  end

begin
  r = resources(:template => params[:destination_path])
  r.cookbook "liferay"
rescue Chef::Exceptions::ResourceNotFound
  Chef::Log.warn "could not find template to override!"
end

end


  