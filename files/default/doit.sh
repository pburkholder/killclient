#!/bin/bash -xv

function view() {
  echo "View the process tree"
  ps -ef  | grep chef
  sleep 3
}

function start_chef_client() {
  echo "Start a chef-client in the background on port $1"
  sudo -E /opt/chef/bin/chef-client --local-mode --config /tmp/kitchen/client.rb --log_level auto --force-formatter --no-color --json-attributes /tmp/kitchen/dna.json --chef-zero-port $1 &
  sleep 3
}

function simple_case() {
  start_client 8889
  view
  echo "Kill the job: $!"
  kill -9 $!
  sleep 3
  view
}

function two_run_case() {
  start_client 8889
  view
  start_client 8890
  view
  echo "Kill the job: $!"
  kill -9 $!
  sleep 3
  view
}

#simple_case
two_run_case
