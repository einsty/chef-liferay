#
# Cookbook Name:: liferay
# Recipe:: bundle
#


case node['platform_family']
when "debian"
  include_recipe "apt"
end

include_recipe "unzip"
include_recipe "imagemagick"
include_recipe "java"

include_recipe "liferay::tomcat_bundle"