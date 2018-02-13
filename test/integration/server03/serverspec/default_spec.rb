require 'spec_helper'

consul_bin_dir  = '/usr/local/bin'
consul_conf_dir = '/etc/consul.d'

describe file("#{consul_conf_dir}/server/config.json") do
  it { should be_file }
  it { should be_mode 644 }
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

describe command("#{consul_bin_dir}/consul --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match %r(Consul v1.0.1) }
end

describe command("#{consul_bin_dir}/consul operator raft list-peers| grep -c ':8300'") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match '3' }
end

describe service('consul') do
  it { should be_enabled }
  it { should be_running }
end

describe process('consul') do
  it { should be_running }
  its(:args) { should match %r(consul agent -config-dir .*) }
end
