#
# Cookbook Name:: killclient
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'killclient::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to be
    end

    it 'creates tmux.conf' do
      expect(chef_run).to render_file('/etc/tmux.conf')
        .with_content('stackoverflow')
    end
  end
end
