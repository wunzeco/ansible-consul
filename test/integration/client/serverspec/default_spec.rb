require 'spec_helper'

consul_user     = 'consul'
consul_group    = consul_user
consul_home     = '/opt/consul'
consul_bin_dir  = '/usr/local/bin'
consul_conf_dir = '/etc/consul.d'
consul_scripts  = %w( disk.sh mem.sh )

describe group(consul_group) do
  it { should exist }
end

describe user(consul_user) do
  it { should exist }
  it { should belong_to_group consul_group }
end

%w( jq python-pip unzip ).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

%W( 
  #{consul_home}/data
  #{consul_home}/logs
  #{consul_home}/scripts
  #{consul_home}/ui
).each do |dir|
  describe file(dir) do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by consul_user }
  end
end

%W( 
  #{consul_bin_dir}
  #{consul_conf_dir}
  #{consul_conf_dir}/server
  #{consul_conf_dir}/client
).each do |dir|
  describe file(dir) do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
  end
end

describe file("#{consul_conf_dir}/client/config.json") do
  it { should be_file }
  it { should be_mode 644 }
end

describe file("#{consul_bin_dir}/consul") do
  it { should be_file }
  it { should be_mode 755 }
end

describe command("#{consul_bin_dir}/consul --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match %r(Consul v0.7.5) }
end

consul_scripts.each do |f|
  describe file("#{consul_home}/scripts/#{f}") do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by consul_user }
  end
end

if os[:family] =~ /ubuntu|debian/
  describe file('/etc/init/consul.conf') do
    it { should be_file }
    it { should be_mode 644 }
  end
end

if os[:family] =~ /centos|redhat/
  describe file('/usr/lib/systemd/system/consul.service') do
    it { should be_file }
    it { should be_mode 644 }
  end
end

describe service('consul') do
  it { should be_enabled }
  it { should be_running }
end

describe process('consul') do
  it { should be_running }
  its(:args) { should match %r(consul agent -config-dir .*) }
end

describe file("#{consul_home}/ui/index.html") do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by consul_user }
end

describe command("curl -s http://localhost:8500/v1/kv/?recurse | jq '.[] | .Key'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match %r(web/key1) }
  its(:stdout) { should match %r(web/key2) }
end
