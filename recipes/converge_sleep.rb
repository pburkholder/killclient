#
# Cookbook Name:: killclient
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

sleep=5
count=5

Chef::Log.error("Deferring sleep to converge phase")

ruby_block 'sleepy' do
  block do
    0.upto(count) do |step|
      Chef::Log.error("Converge-phase sleeping #{sleep}s at step #{step}")
      sleep sleep
    end
  end
end
