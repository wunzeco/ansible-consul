require 'spec_helper'

consul_bin_dir  = '/usr/local/bin'
consul_work_dir = '/opt/consul'
consul_conf_dir = '/etc/consul.d'
consul_scripts  = %w( disk.sh mem.sh )

%w( jq python-pip unzip ).each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

%W( 
  #{consul_bin_dir}
  #{consul_conf_dir}
  #{consul_work_dir}/logs
  #{consul_work_dir}/scripts
).each do |dir|
  describe file(dir) do
    it { should be_directory }
    it { should be_mode 755 }
  end
end

describe file("#{consul_bin_dir}/consul") do
  it { should be_file }
  it { should be_mode 755 }
end

consul_scripts.each do |f|
  describe file("#{consul_work_dir}/scripts/#{f}") do
    it { should be_file }
    it { should be_mode 755 }
  end
end

describe file('/etc/init/consul.conf') do
  it { should be_file }
  it { should be_mode 644 }
end

describe service('consul') do
  it { should be_enabled }
end

describe process('consul') do
  it { should be_running }
  its(:args) { should match %r(agent -data-dir .* -config-dir .*) }
end
