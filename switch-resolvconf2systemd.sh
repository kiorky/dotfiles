#!/usr/bin/env bash
sudo service resolvconf disable-updates
sudo service resolvconf stop
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo systemctl enable systemd-resolved
sudo systemctl restart systemd-resolved
# vim:set et sts=4 ts=4 tw=80:
