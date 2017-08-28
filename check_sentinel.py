#!/usr/bin/env python
#
# Nagios plugin to monitor Redis sentinel
#
# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# <mantas@mantas.lt> wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Mantas Smelevicius
# ----------------------------------------------------------------------------
#
# Checks general connectivity to a Redis sentinel server and will go critical
# for any of the following conditions:
#   * Inability to connect to the sentinel server
#   * Sentinel reports it isn't monitoring any masters
#   * Sentinel has entered TILT mode
#
# Arguments:
# -s HOSTNAME to connect to (defaults to 127.0.0.1)
# -p PORT to connect to (defaults to 26379)
# -t TIMEOUT to connect to (defaults 0.1)
#
# REQUIREMENTS
# - Python2.6+ or Python3
# - redis-py
#
# Changes
# v0.1 - Initial commit
# v0.2 - Rewrite code for Python2.6+ and Python3

import socket
import sys
from optparse import OptionParser

import redis

# Constants
EXIT_NAGIOS_OK = 0
EXIT_NAGIOS_WARN = 1
EXIT_NAGIOS_CRITICAL = 2

# Command line options
opt_parser = OptionParser()
opt_parser.add_option("-s", dest="server", default="127.0.0.1", help="Sentinel address to connect to. (Default: 127.0.0.1)")
opt_parser.add_option("-p", dest="port", default=26379, help="Redis Sentinel port to connect to. (Default: 26379)")
opt_parser.add_option("-t", dest="timeout", default=0.1, help="How many seconds to wait for host to respond. (Default: 0.1)")
args = opt_parser.parse_args()[0]

# ================
# = Nagios check =
# ================

# Connection
try:
    redis_connection = redis.Redis(host=args.server, port=int(args.port), socket_timeout=args.timeout)
    redis_info = redis_connection.info()
except (socket.error, redis.exceptions.ConnectionError, redis.exceptions.ResponseError, redis.exceptions.TimeoutError) as e:
    print('CRITICAL: Problem establishing connection to Sentinel server %s: %s ' % (str(args.server), str(repr(e))))
    sys.exit(EXIT_NAGIOS_CRITICAL)

if redis_info.get("sentinel_masters") is None or redis_info.get("sentinel_masters") == 0:
    print('Critical: There is no masters configured in Sentinel %s:%s' % (str(args.server), str(args.port)))
    sys.exit(EXIT_NAGIOS_CRITICAL)

if redis_info.get("sentinel_tilt") != 0:
    print('Critical: Sentinel has entered TILT mode')
    sys.exit(EXIT_NAGIOS_CRITICAL)

print('OK: Monitoring %d master(s)' % int(redis_info.get("sentinel_masters")))
sys.exit(EXIT_NAGIOS_OK)
