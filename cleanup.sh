#!/bin/bash
set -x

sudo ip netns delete netns_dustin
sudo ip netns delete netns_leah
sudo ip link delete dev bridge_home
sudo rm -r /etc/netns/netns_dustin
sudo rm -r /etc/netns/netns_leah
