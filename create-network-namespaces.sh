#!/bin/bash
set -x

sudo ip link add dev bridge_home type bridge
sudo ip address add 10.0.0.1/24 dev bridge_home

sudo iptables --append FORWARD --in-interface bridge_home --out-interface bridge_home --jump ACCEPT
sudo iptables --append FORWARD --in-interface bridge_home --out-interface enp4s0 --jump ACCEPT
sudo iptables --append FORWARD --in-interface enp4s0 --out-interface bridge_home --jump ACCEPT
sudo iptables --append POSTROUTING --table nat --out-interface enp4s0 --jump MASQUERADE

sudo ip netns add netns_dustin
sudo mkdir -p /etc/netns/netns_dustin
echo "nameserver 8.8.8.8" | sudo tee -a /etc/netns/netns_dustin/resolv.conf
sudo ip netns exec netns_dustin ip link set dev lo up
sudo ip link add dev veth_dustin type veth peer name veth_ns_dustin
sudo ip link set dev veth_dustin master bridge_home
sudo ip link set dev veth_dustin up
sudo ip link set dev veth_ns_dustin netns netns_dustin
sudo ip netns exec netns_dustin ip link set dev veth_ns_dustin up
sudo ip netns exec netns_dustin ip address add 10.0.0.11/24 dev veth_ns_dustin

sudo ip netns add netns_leah
sudo mkdir -p /etc/netns/netns_leah
echo "nameserver 8.8.8.8" | sudo tee -a /etc/netns/netns_leah/resolv.conf
sudo ip netns exec netns_leah ip link set dev lo up
sudo ip link add dev veth_leah type veth peer name veth_ns_leah
sudo ip link set dev veth_leah master bridge_home
sudo ip link set dev veth_leah up
sudo ip link set dev veth_ns_leah netns netns_leah
sudo ip netns exec netns_leah ip link set dev veth_ns_leah up
sudo ip netns exec netns_leah ip address add 10.0.0.21/24 dev veth_ns_leah

sudo ip link set bridge_home up
sudo ip netns exec netns_dustin ip route add default via 10.0.0.1
sudo ip netns exec netns_leah ip route add default via 10.0.0.1
