#
# Cookbook Name:: killclient
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

sleep=5
count=5

0.upto(count) do |step|
  Chef::Log.error("Compile-phase sleeping #{sleep}s at step #{step}")
  sleep sleep
end
