#
# Cookbook Name:: killclient
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

package %w(tshark strace lsof tmux)

# Original hack
cookbook_file '/root/doit.sh' do
    source 'doit.sh'
    mode '0755'
end

template '/etc/tmux.conf' do
  source 'tmux.conf.erb'
end

template '/home/vagrant/.bash_aliases' do
  source 'bash_aliases'
end
