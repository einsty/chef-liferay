#
# Cookbook Name:: liferay
# Recipe:: bundle
#


liferay_environment_properties do 

  destination_path "#{node['liferay']['install_directory']}/liferay/tomcat/webapps/ROOT/WEB-INF/classes/portal-ext-environment.properties" 
  template_path "portal-ext-environment.properties.erb"
  
end