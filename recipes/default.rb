#
# Cookbook Name:: activemq
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"

activemq_home = node['activemq']['home']

user node["activemq"]["user"] do
  system true
  group "nogroup"
end

ark "activemq" do
  version node["activemq"]["version"]
  checksum node["activemq"]["checksum"]
  url node["activemq"]["url"]
  home_dir activemq_home
end

file "#{activemq_home}/bin/activemq" do
  owner "root"
  group "root"
  mode "0755"
end

%w(base data tmp conf).each do |dir|
directory node["activemq"][dir] do
    owner node["activemq"]["user"]
    mode "0755"
  end
end

template ::File.join(node["activemq"]["conf"], "activemq.xml") do
  source "activemq.xml.erb"
  mode "0644"
  notifies :restart, "service[activemq]"
end

case node["activemq"]["init_style"]
when "runit"
  include_recipe "runit"
  runit_service "activemq"
when "upstart"
  template "/etc/init/activemq.conf" do
    mode "0644"
    source "activemq.upstart.conf.erb"
    notifies :restart, "service[activemq]"
  end

  service "activemq" do
    supports  :restart => true, :status => true
    action [:enable, :start]
    provider ::Chef::Provider::Service::Upstart
  end

when "systemd"
  raise NotImplementedError, "systemd init_style not implemented yet"
else
  # TODO: make this more robust
  arch = (node['kernel']['machine'] == "x86_64") ? "x86-64" : "x86-32"

  link "/etc/init.d/activemq" do
    to "#{activemq_home}/bin/linux-#{arch}/activemq"
  end

  # symlink so the default wrapper.conf can find the native wrapper library
  link "#{activemq_home}/bin/linux" do
    to "#{activemq_home}/bin/linux-#{arch}"
  end

  # symlink the wrapper's pidfile location into /var/run
  link "/var/run/activemq.pid" do
    to "#{activemq_home}/bin/linux/ActiveMQ.pid"
    not_if "test -f /var/run/activemq.pid"
  end

  template "#{activemq_home}/bin/linux/wrapper.conf" do
    source "wrapper.conf.erb"
    mode 0644
    notifies :restart, 'service[activemq]'
  end  

  service "activemq" do
    supports  :restart => true, :status => true
    action [:enable, :start]
  end
end
