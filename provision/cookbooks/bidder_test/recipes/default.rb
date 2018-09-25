#
# Cookbook Name:: bidder_test
# Recipe:: default
#
# Copyright 2014, Simpli.fi
#
# All rights reserved - Do Not Redistribute
#

# For the Ruby Installer package
ruby_install_version = node.default['ruby_install']['version']
chruby_version = node.default['chruby']['version']
ruby_target_version = node.default['ruby']['version']

erlang_repo_version = node.default['erlang']['repo_version']
docker_compose_version = node.default['docker-compose']['version']
cppcheck_version = node.default['cppcheck']['version']
cmake_version = node.default['cmake']['version']
cmake_major_version = node.default['cmake']['major_version']

ENV['HOME'] = '/home/vagrant'
ENV['USER'] = 'vagrant'

# Needed before we can add a repository
package 'software-properties-common'

bash 'add newest tools' do
  code 'add-apt-repository ppa:ubuntu-toolchain-r/test'
end

bash 'apt-get update' do
  code 'apt-get update'
end

# Needed for building
package 'build-essential'
package 'git'
package 'xsel'
package 'libbz2-dev'
package 'libpcre3-dev'
package 'ragel'
package 'libxml2-dev'
package 'libxslt1-dev'
package 'libtool'
package 'autoconf'
package 'byacc'
package 'flex'
package 'libevent-dev'
package 'libglib2.0-dev'
package 'libcppunit-dev'
package 'ccache' #speeds up c/c++ builds dramatically
package 'gcc-5'
package 'g++-5'
package 'python-dev'
package 'python-pip'

# Needed for running
package 'libpq-dev'
package 'swig'
package 'nodejs'

# Needed for convienience
package 'silversearcher-ag'
package 'tmux'
package 'vim'
package 'emacs24'
package 'zsh'
package 'nfs-common'

# Needed for problem solving
package 'gdb'
package 'htop'

# Docker setup, needed for matching_generator
package 'apt-transport-https'
package 'ca-certificates'

bash 'set default gcc' do
  code 'sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5'
end

bash 'add docker apt repository' do
  code <<-CODE
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-add-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    sudo apt-get update
  CODE
  not_if "apt-cache policy | grep 'origin download.docker.com'"
end

package 'docker-ce'

# Create a docker group and add the user to it, so docker won't require sudo
group 'docker' do
  members 'vagrant'
end

docker_compose_binfile = '/usr/local/bin/docker-compose'

remote_file docker_compose_binfile do
  source "https://github.com/docker/compose/releases/download/#{docker_compose_version}/docker-compose-#{node[:kernel][:name]}-#{node[:kernel][:machine]}"
  mode '755'
  action :create_if_missing
end

# (end of Docker setup)

# Elixir setup, needed for matching_generator

erlang_deb_file = "erlang-solutions_#{erlang_repo_version}_all.deb"
erlang_deb_tmp = "#{Chef::Config[:file_cache_path]}/#{erlang_deb_file}"

remote_file erlang_deb_tmp do
  source "https://packages.erlang-solutions.com/#{erlang_deb_file}"
  action :create_if_missing
end

dpkg_package 'erlang-solutions' do
  source erlang_deb_tmp
end

bash 'apt update' do
  code 'sudo apt-get update'
end

package 'esl-erlang' do
  version '1:20.3'
end

package 'elixir' do
  version '1.6.5-1'
end
# (end of Elixir setup)

bash 'set timezone' do
  code 'timedatectl set-timezone America/Chicago'
end

bash 'install chruby' do
  creates '/usr/local/share/chruby/chruby.sh'
  code <<-CODE
    wget -O chruby-#{chruby_version}.tar.gz https://github.com/postmodern/chruby/archive/v#{chruby_version}.tar.gz
    tar -xzvf chruby-#{chruby_version}.tar.gz
    cd chruby-#{chruby_version}/
    sudo make install
  CODE
end

bash 'install ruby-install' do
  creates '/usr/local/bin/ruby-install'
  code <<-CODE
    wget -O ruby-install-#{ruby_install_version}.tar.gz https://github.com/postmodern/ruby-install/archive/v#{ruby_install_version}.tar.gz
    tar -xzvf ruby-install-#{ruby_install_version}.tar.gz
    cd ruby-install-#{ruby_install_version}/
    sudo make install
  CODE
end


bash "install ruby #{ruby_target_version}" do
  only_if { ::Dir.glob("/opt/rubies/ruby-#{ruby_target_version}*").empty? }
  code "ruby-install ruby #{ruby_target_version} --latest"
end

file '/etc/profile.d/chruby.sh' do
  mode 0755
  content <<-CODE
    if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
      source /usr/local/share/chruby/chruby.sh
      chruby ruby-#{ruby_target_version}
    fi
  CODE
end

bash "install cmake #{cmake_version}" do
  not_if "cmake --version | grep #{cmake_version}"
  code <<-CODE
    wget -O /tmp/cmake-#{cmake_version}.tar.gz --no-check-certificate --quiet https://cmake.org/files/v#{cmake_major_version}/cmake-#{cmake_version}.tar.gz
    cd /tmp/
    tar -xzf cmake-#{cmake_version}.tar.gz
    cd cmake-#{cmake_version}
    ./bootstrap > /dev/null
    make -s -j`nproc`
    make -s install > /dev/null
    cd /
    rm -rf /tmp/cmake*
    update-alternatives --install /usr/bin/cmake cmake /usr/local/bin/cmake 1 --force
  CODE
end

bash 'add github.com as a known host' do
  user 'vagrant'
  code 'mkdir -p /home/vagrant/.ssh && chmod 0700 /home/vagrant/.ssh && ssh-keyscan -H github.com >> /home/vagrant/.ssh/known_hosts'
end

WITH_CHRUBY = "source /usr/local/share/chruby/chruby.sh && chruby ruby-#{ruby_target_version} && "

bash 'install bundler' do
  code WITH_CHRUBY + 'gem update bundler'
end

bash 'add sifi source' do
  code WITH_CHRUBY + 'gem sources -a "http://simplifi:Fz*47u@dctest1.simpli.fi/gems/"'
end

git '/vagrant/sifi_cmake' do
  repository 'git@github.com:simplifi/sifi_cmake'
  user 'vagrant'
  action :checkout
end

git '/vagrant/bidder' do
  repository 'git@github.com:simplifi/bidder'
  user 'vagrant'
  action :checkout
end

bash 'bundle install bidder' do
  user 'vagrant'
  cwd '/vagrant/bidder'
  code WITH_CHRUBY + 'echo `which bundle` && echo `which ruby` && ruby -e "puts RUBY_VERSION" && bundle install --deployment'
end

#set up agent forwarding from your mac
template '/home/vagrant/.ssh/config' do
  source 'ssh_config.erb'
  mode '0440'
  owner 'vagrant'
  variables(server_username: node["server_username"])
end

#get chef repo cloned
git '/vagrant/chef-repo' do
  repository 'git@github.com:simplifi/chef-repo.git'
  user 'vagrant'
  action :checkout
end

cookbook_file '/home/vagrant/.legacy_env_vars.rc' do
  source 'legacy_env_vars.rc'
  mode 0644
  owner 'vagrant'
  group 'vagrant'
end

cookbook_file '/home/vagrant/.sifi.rc' do
  source 'sifi.rc'
  mode 0644
  owner 'vagrant'
  group 'vagrant'
end

#clone the exuser_update_service repo
git '/vagrant/exuser_update_service' do
  repository 'git@github.com:simplifi/exuser_update_service'
  user 'vagrant'
  action :checkout
end

#clone the matching_generator repo
git '/vagrant/matching_generator' do
  repository 'git@github.com:simplifi/matching_generator'
  user 'vagrant'
  action :checkout
end

ruby_block 'add sifi enviroment settings' do
  block do
    file = Chef::Util::FileEdit.new('/home/vagrant/.bashrc')
    line = 'source ~/.legacy_env_vars.rc'
    file.insert_line_if_no_match(line, line)
    line = 'source ~/.sifi.rc'
    file.insert_line_if_no_match(line, line)
    file.write_file
  end
end

# install cppcheck
cppcheck_tgz = "cppcheck-#{cppcheck_version}.tar.gz"
cppcheck_tgz_tmp_path = "#{Chef::Config[:file_cache_path]}/#{cppcheck_tgz}"

remote_file cppcheck_tgz_tmp_path do
  source "https://github.com/danmar/cppcheck/archive/#{cppcheck_version}.tar.gz"
  action :create_if_missing
end

bash 'install cppcheck' do
  not_if "cppcheck --version | grep -q '#{cppcheck_version}'"
  cwd Chef::Config[:file_cache_path]
  # Note, the make install args come straight from the readme.txt of cppcheck.
  code <<-CODE
    tar -xvzf #{cppcheck_tgz_tmp_path}
    cd cppcheck-#{cppcheck_version}
    make install SRCDIR=build CFGDIR=/usr/share/cppcheck-#{cppcheck_version}/ HAVE_RULES=yes
  CODE
end
