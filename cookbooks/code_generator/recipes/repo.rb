# encoding: utf-8
# frozen_string_literal: true
#
# Cookbook Name:: cookbook-guide-generator
# Recipe:: repo.rb
#
# Copyright 2016 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
context = ChefDK::Generator.context
repo_dir = File.join(context.repo_root, context.repo_name)

# repo root dir
directory repo_dir

# Top level files
template "#{repo_dir}/LICENSE" do
  source "LICENSE.#{context.license}.erb"
  helpers(ChefDK::Generator::TemplateHelper)
  action :create_if_missing
end

cookbook_file "#{repo_dir}/.chef-repo.txt" do
  source 'repo/dot-chef-repo.txt'
  action :create_if_missing
end

cookbook_file "#{repo_dir}/README.md" do
  source 'repo/README.md'
  action :create_if_missing
end

cookbook_file "#{repo_dir}/chefignore" do
  source 'chefignore'
  action :create_if_missing
end

directories_to_create = %w(cookbooks data_bags)

directories_to_create += if context.use_roles
                           %w(roles environments)
                         else
                           %w(policies)
                         end

directories_to_create.each do |tlo|
  remote_directory "#{repo_dir}/#{tlo}" do
    source "repo/#{tlo}"
    action :create_if_missing
  end
end

cookbook_file "#{repo_dir}/cookbooks/README.md" do
  if context.policy_only
    source 'cookbook_readmes/README-policy.md'
  else
    source 'cookbook_readmes/README.md'
  end
  action :create_if_missing
end

# git
if context.have_git
  unless context.skip_git_init
    execute('initialize-git') do
      command('git init .')
      cwd repo_dir
      not_if { File.exist?("#{repo_dir}/.gitignore") }
    end
  end
  template "#{repo_dir}/.gitignore" do
    source 'repo/gitignore.erb'
    helpers(ChefDK::Generator::TemplateHelper)
    action :create_if_missing
  end
end
