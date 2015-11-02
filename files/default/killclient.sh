#!/bin/bash -xv

kchef() {
  sudo -E /opt/chef/bin/chef-client --local-mode --config /tmp/kitchen/client.rb --log_level auto --force-formatter --no-color --json-attributes /tmp/kitchen/dna.json --chef-zero-port $1 &
}
function view() {
  echo "View the process tree"
  ps -ef  | grep chef
  sleep 3
}

function start_chef_client() {
  echo "Start a chef-client in the background on port $1"
  case $2 in
    kitchen-chef)
      kchef $1;;
    compile)
      chef-client -o 'killclient::compile_sleep' ;;
    converge)
      chef-client -o 'killclient::converge_sleep' ;;
    *)
      echo 'HUh?'
      exit 1;;
  esac
  sleep 5
}

function server-chef() {
  act=$1
  chef-client -o 'killclient::${act}_sleep' &
  one=$!
  sleep 5
  view

  chef-client -o 'killclient::${act}_sleep' &
  two=$!
  sleep 5
  view

  echo "Kill the job: $one; keep two: $two"
  kill -INT $one
  sleep 3

  view
}
function 3x_server-chef() {
  act=$1
  chef-client -o 'killclient::${act}_sleep' &
  one=$!
  sleep 5
  view

  chef-client -o 'killclient::${act}_sleep' &
  two=$!
  sleep 5
  view

  chef-client -o 'killclient::${act}_sleep' &
  three=$!
  sleep 5
  view

  echo "Kill the job: $one; keep two: $two; keep three: $three"
  kill -INT $one
  sleep 3

  view
}

function simple_case() {
  start_client 8889 kitchen-chef
  view
  echo "Kill the job: $!"
  kill -9 $!
  sleep 3
  view
}

function two_run_case() {
  start_client 8889 kitchen-chef
  view
  start_client 8890 kitchen-chef
  view
  echo "Kill the job: $!"
  kill -9 $!
  sleep 3
  view
}

#simple_case
#two_run_case
server-chef compile
