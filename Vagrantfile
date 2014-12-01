# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.omnibus.chef_version = :latest

  config.berkshelf.enabled = true

  config.berkshelf.berksfile_path = "./Berksfile"

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
  end

  # Liferay Box
  config.vm.define :liferay do |liferay|

    liferay.vm.box = "chef/ubuntu-14.04"

    liferay.vm.provider "virtualbox" do |vb|
      vb.name = "Liferay"

      vb.customize ["modifyvm", :id, "--memory", 2048]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    liferay.vm.network :private_network, ip: "172.16.30.10"

    liferay.vm.provision :chef_solo do |chef|
    
      chef.custom_config_path = "Vagrantfile.chef"
      chef.data_bags_path = "data_bags"
      
      chef.add_recipe "chef-solo-search"
      chef.add_recipe "liferay::users"
      chef.add_recipe "liferay::bundle"
      chef.add_recipe "mysql-connector::java"

      chef.json = {
        :java => {
          :install_flavor => "oracle",
          :jdk_version => "7",
          :oracle => {
            :accept_oracle_download_terms => true
          }
        }
      }
    
    end
  end

  # PostgreSQL Box
  config.vm.define :postgres do |postgres|

    postgres.vm.box = "opscode-trusty64-provisionerless"

    postgres.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-14.04_provisionerless.box"

    postgres.vm.provider "virtualbox" do |vb|

      vb.name = "Liferay PostgreSQL"

      vb.customize ["modifyvm", :id, "--memory", 1024]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    postgres.vm.network :private_network, ip: "172.16.40.10"

    postgres.vm.provision :chef_solo do |chef|

      chef.custom_config_path = "Vagrantfile.chef"    
    
      chef.add_recipe "liferay::postgresql"

      chef.json = {
        :postgresql => {
          :config => {
            :listen_addresses => "*"
          },
          :pg_hba => [
            {
              :addr => "0.0.0.0/0",
              :db => "all",
              :method => "md5",
              :type => "host",
              :user => "all"
            },
            {
              :addr => "::1/0",
              :db => "all",
              :method => "md5",
              :type => "host",
              :user => "all"
            }
          ],
          :password => {
            :postgres => "autobahn"
          }
        }
      }
    end
  end

  # MySQL Box
  config.vm.define :mysql do |mysql|

    mysql.vm.box = "opscode-trusty64-provisionerless"

    mysql.vm.box_url = "https://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-14.04_provisionerless.box"

    mysql.vm.provider "virtualbox" do |vb|
      vb.name = "Liferay MySQL"

      vb.customize  ["modifyvm", :id, "--memory", 1024]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    mysql.vm.network :private_network, ip: "172.16.40.20"

    mysql.vm.provision :chef_solo do |chef|
    
      chef.custom_config_path = "Vagrantfile.chef"    
    
      chef.add_recipe "apt"
      chef.add_recipe "database::mysql"
      chef.add_recipe "mysql::server"
      chef.add_recipe "liferay::mysql"

      chef.json = {
        :mysql => {
          :allow_remote_root => true,
          :bind_address => "172.16.40.20",
          :server_debian_password => "autobahn",
          :server_repl_password => "autobahn",
          :server_root_password => "autobahn"
        }
      }
    end
  end

end
