#!/bin/sh
# Kill & remove nfs container.
# Note: Because of "restart:always" in init script, it is not required to stop/start server manually. Just init once.

docker rm -f nfs
