#!/bin/bash -xe

# If a chef-client is wedged, run this script to:
# - capture diagnostics from running process
# - drop a ping on the chef-server
# - kill all the chef chef-clients
# - get the run-parameters for chef from Cron (if # applicable)
# - rerun with strace and debugging on.
# - bundle it all up.
#
# In addition to sending the .tgz off to a workstation
# for analysis, you'd also want the access logs from
# ChefServer. E.g.
#   ip='1.2.3.4'
# Get the 100 lines before wedging:
#  awk "NR==1,/$ip.*wedged_process/ { if ( \$1 == \"$ip\" ) print; } " /var/log/opscode/nginx/access.log | tail -100
# Get the lines between wedging and the debug run
#   awk "/^$ip.*wedged/, /^$ip.*debug/ { if ( \$1 == \"$ip\" ) print; }" /var/log/opscode/nginx/access.log


CACHE_PATH=$(knife exec \
  -c /etc/chef/client.rb \
  -E "print Chef::Config.cache_path")
TMPDIR=$CACHE_PATH/tmp

function die() {
  echo -n $@
  echo 'Exiting ....'
  exit 1
}

function make_tempdir(){
  mkdir -p $TMPDIR    # make it if not already extant
  REPORT_DIR=${TMPDIR}/${RANDOM}
  echo "Making $REPORT_DIR for diagnostics output"
  if [ -d $REPORT_DIR ]; then
     die "Report directory, $REPORT_DIR, already exists"
   else
     mkdir $REPORT_DIR
   fi
}

# Get files held open but current chef-client
function lsof_wedged_process() {
  process=$1
  f="$REPORT_DIR/lsof_wedged_process"
  touch $f ||
    die "Unable to make output file $f"
  cmd="lsof -p $process"
  echo ======= $cmd ======= >> $f
  $cmd >> $f
}

function ps_all_chef_processes() {
  f="$REPORT_DIR/ps_all_chef_processes"
  touch $f ||
    die "Unable to make output file $f"
  cmd="ps -C chef-client -fL"
  echo ======= $cmd ======= >> $f
  $cmd >> $f || die "No processes found"
}

# write an access log entry for a non-existent
# URL to the chef-server
function ping_chef_server() {
  knife raw -c /etc/chef/client.rb /ping/$1/$REPORT_DIR || true
}

# set $chefclient to the chef-client command in cron
function get_chef_client_cron_job() {
  chefclient=$(crontab -l | grep -v '^ *#' | grep chef-client |
    awk 'BEGIN{ORS=" ";} {for(i=6;i<=NF;++i) print $i}')
  [ -z $chefclient ] && chefclient='chef-client'

}

# run chef-client from strace with debug logging
function run_chef_client() {
  f=$REPORT_DIR/strace_cmd
  touch $f || die "Unable to make output file $f"
  cmd="strace -f -s 9999 -o $f.out $chefclient -l debug"
  echo "==== $cmd ====" > $f
  eval $cmd 2>&1 1>> $f
}

# pack up everything from REPORT_DIR into .tgz
function pack_up() {
  tar -C $CACHE_PATH -czf $REPORT_DIR.tgz $REPORT_DIR
  echo "Work complete and bundled in:"
  echo "$REPORT_DIR.tgz"
}

# MAIN
make_tempdir
chef_pid=`cat $CACHE_PATH/cache/chef-client-running.pid`
ps_all_chef_processes
lsof_wedged_process $chef_pid
ping_chef_server wedged_process

#kill_client
pkill -9 -f chef-client

get_chef_client_cron_job
run_chef_client
ping_chef_server debug_process_done

pack_up
