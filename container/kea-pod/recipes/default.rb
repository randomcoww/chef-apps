#
# Cookbook Name:: kea-pod
# Recipe:: default
#
# Copyright (C) 2017 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "kea-pod::_mysql_packages"
include_recipe "kea-pod::_mysql_seed"
