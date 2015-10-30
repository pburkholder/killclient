#
# Cookbook Name:: killclient
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

cookbook_file '/root/doit.sh' do
    source 'doit.sh'
    mode '0755'
end


ruby_block 'sleepy' do
  block do
    sleep 30
  end
end
