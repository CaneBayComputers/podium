#!/bin/bash

set -e

shopt -s expand_aliases

cd ~/repos/cbc-development-setup

source .bash_aliases

# Flush all rules in all chains
iptables -F    # Flush all the rules in the filter table
iptables -X    # Delete all user-defined chains in the filter table
iptables -Z    # Zero all packet and byte counters in all chains

# If you are using the nat or mangle tables, you should also flush and delete their rules and chains
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z

# Set default policies to ACCEPT (this step is crucial to avoid locking yourself out)
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Print confirmation message
echo "All iptables rules have been flushed, and default policies set to ACCEPT."
