#!/bin/bash -xe

CACHE_PATH=$(knife exec \
  -c /etc/chef/client.rb \
  -E "print Chef::Config.cache_path")
TMPDIR=$CACHE_PATH/tmp
CACHEDIR=/var/chef/cache


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

function lsof_wedged_process() {
  process=$1
  f="$REPORT_DIR/lsof_wedged_process"
  # What can we dig out of the currently-wedged chef process?
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

function ping_chef_server() {
  knife raw /ping/from/$REPORT_DIR/$1 || true
}

function get_chef_client_cron_job() {
  chefclient=$(crontab -l | grep -v '^ *#' | grep chef-client |
    awk 'BEGIN{ORS=" ";} {for(i=6;i<=NF;++i) print $i}')
}

function run_chef_client() {
  f=$REPORT_DIR/strace_cmd
  touch $f || die "Unable to make output file $f"
  cmd="strace -f -s 9999 -o $f.out $chefclient -l debug"
  echo "==== $cmd ====" > $f
  eval $cmd 2>&1 1>> $f
}

function pack_up() {
  tar -C $CACHE_PATH -czf $REPORT_DIR.tgz $REPORT_DIR
  echo "Work complete and bundled in:"
  echo "$REPORT_DIR.tgz"
}

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
