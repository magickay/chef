#
# Author:: Adam Edwards (<adamed@opscode.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'chef/platform/query_helpers'
require 'chef/resource/script'
require 'chef/mixin/windows_architecture_helper'

class Chef
  class Resource
    class WindowsScript < Chef::Resource::Script
      resource_name :windows_script

      set_guard_inherited_attributes(:architecture)

      property :default_guard_interpreter, default: lazy { resource_name }
      property :architecture, [ :x86_64, :i386 ],
                 coerce: proc { |v| assert_architecture_compatible!(v) }

      protected

      def initialize(name, run_context, resource_name=nil, interpreter=nil)
        super(name, run_context)
        @interpreter = interpreter if interpreter
        @resource_name = resource_name if resource_name
      end

      include Chef::Mixin::WindowsArchitectureHelper

      protected

      def assert_architecture_compatible!(desired_architecture)
        if desired_architecture == :i386 && Chef::Platform.windows_nano_server?
          raise Chef::Exceptions::Win32ArchitectureIncorrect,
            "cannot execute script with requested architecture 'i386' on Windows Nano Server"
        elsif ! node_supports_windows_architecture?(node, desired_architecture)
          raise Chef::Exceptions::Win32ArchitectureIncorrect,
            "cannot execute script with requested architecture '#{desired_architecture.to_s}' on a system with architecture '#{node_windows_architecture(node)}'"
        end
      end
    end
  end
end
