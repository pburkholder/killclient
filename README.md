# killclient



The purpose of this cookbook is to demonstrate the chef-client process failure modes reported by customer B.  To wit:

As described by A. at one point
> 2) The issue is more or less with chef-client not cleaning up its children when getting exited out of during the run. Ctrl Z leaves the process and it should be able to be resumed but it doesn't. That is the primary issue we are seeing with the chef-client run. It is also the most easily reproducible.


And as described by me (from sitting with A. last week):
> 2) While investigating issue #1, J. and A. have found that chef-client behaves undesirably when multiple chef-clients are running, and the initial chef-client is killed or suspended. If this is the issue blocking chef-client redeployment at B., then we can work with other engineers to clarify and correct (as needed) the client behavior.

## Phase Zero

Initially I thought this would be trivially reproducible by:
- starting from `kitchen converge`
- logging in with `kitchen login`
- the running the chef-client with a 'sleep' either in the compile phase or the converge phase
- issue Ctrl-Z, and then resuming (or, presumably, failing to resume)

But that didn't kick up any issues, so then I tried:
- starting chef-client on port 8889 local-mode as a background process
- starting chef-client on port 8890 local-mode as a background process
- killing the initial chef-client
- watch the unreaped processes accumulate - ONLY, that didn't happen either.

See files/default/doit.sh for script that does the above.

## Phase One

To better approach the original environment where this seemed to appear,
- checkout the tag 'phase-one'
- upload this cookbook to your chef-server
- `kitchen create`
- bootstrap the kitchen node to your chef-server:
```
knife bootstrap 127.0.0.1 -p 2222 \
   -N killclient --bootstrap-version 12.4.1 \
   -x vagrant --sudo -r 'recipe[killclient]'
```
  - The default recipe installs the `killclient` script and some useful tools
- `kitchen login` and `sudo bash` to login and be root
- Use /root/killclient to try different futzing scenarios.

### killclient:
