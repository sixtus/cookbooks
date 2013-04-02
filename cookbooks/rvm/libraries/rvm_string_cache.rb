#
# Cookbook Name:: rvm
# Library:: Chef::RVM::StringCache
#
# Author:: Fletcher Nichol <fnichol@nichol.ca>
#
# Copyright 2011, Fletcher Nichol
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

require 'chef/mixin/command'

module ChefUtils
  module RVM
    class StringCache

      class << self
        include ChefUtils::RVM
        include Chef::Mixin::Command
      end

      ##
      # Returns a fully qualified RVM Ruby string for the given input string
      #
      # @param [String] a string that can interpreted by RVM
      # @param [String] the username if this is for a user install or nil if
      #                 it is a system install
      # @return [String] a fully qualified RVM Ruby string
      def self.fetch(str, user = nil)
        @@strings ||= Hash.new
        rvm_install = user || "system"
        @@strings[rvm_install] ||= Hash.new

        return @@strings[rvm_install][str] if @@strings[rvm_install].has_key?(str)

        result = canonical_ruby_string(str, user)
        # cache everything except default environment
        if str == 'default'
          result
        else
          @@strings[rvm_install][str] = result
        end
      end

      protected

      def self.canonical_ruby_string(str, user)
        Chef::Log.debug("Fetching canonical RVM string for: #{str} " +
                        "(#{user || 'system'})")

        user_dir = Etc.getpwnam(user).dir

        cmd = ["source #{user_dir}/.rvm/scripts/rvm",
          "rvm strings '#{str}'"].join(" && ")
        _, stdin, stdout, _ = popen4('bash', shell_params(user, user_dir))
        stdin.puts(cmd)
        stdin.close

        result = stdout.read.split('\n').first.chomp
        if result =~ /^-/   # if the result has a leading dash, value is bogus
          Chef::Log.warn("Could not determine canonical RVM string for: #{str} " +
                         "(#{user || 'system'})")
          nil
        else
          Chef::Log.debug("Canonical RVM string is: #{str} => #{result} " +
                          "(#{user || 'system'})")
          result
        end
      end

      def self.shell_params(user, user_dir)
        {
          :user => user,
          :environment => {
            'USER' => user,
            'HOME' => user_dir
          }
        }
      end
    end
  end
end
