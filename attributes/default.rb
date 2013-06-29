#
# Cookbook Name:: activemq
# Attributes:: default
#
# Copyright 2009-2011, Opscode, Inc.
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

default['activemq']['mirror']  = "http://apache.mirrors.tds.net"
default['activemq']['version'] = "5.8.0"
default['activemq']['url'] = "#{activemq["mirror"]}/activemq/apache-activemq/#{activemq["version"]}/apache-activemq-#{activemq["version"]}-bin.tar.gz"
default['activemq']['home']  = "/usr/local/activemq"
default['activemq']['base'] = "/var/lib/activemq"
default['activemq']['data'] = "/var/lib/activemq/data"
default['activemq']['tmp'] = "/var/lib/activemq/tmp"
default['activemq']['conf'] = "/usr/local/activemq/conf"
default['activemq']['wrapper']['max_memory'] = "512"
default['activemq']['wrapper']['useDedicatedTaskRunner'] = "true"
default['activemq']['user'] = "activemq"

default['activemq']['stomp']['port'] = 61613
default['activemq']['stomp']['enable'] = true
default['activemq']['stomp+nio']['enable'] = false
default['activemq']['stomp+nio']['port'] = 61612
default['activemq']['stomp+ssl']['enable'] = false
default['activemq']['stomp+ssl']['port'] = 61612

default['activemq']['init_style'] = case platform
					when "ubuntu"
						"upstart"
					when "fedora"
						"systemd"
					when "debian"
						"runit"
					when "centos", "redhat"
						if platform_version.split(".").map(&:to_i) >= [6]
							"upstart"
						else
							"init"
						end
					else
						"init"
					end