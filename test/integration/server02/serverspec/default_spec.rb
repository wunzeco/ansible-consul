require 'spec_helper'

consul_bin_dir  = '/usr/local/bin'
consul_conf_dir = '/etc/consul.d'

describe file("#{consul_conf_dir}/server/config.json") do
  it { should be_file }
  it { should be_mode 644 }
end

service_startup_file = '/lib/systemd/system/consul.service'
if os[:family] =~ /ubuntu|debian/ and os[:release] == '14.04'
    service_startup_file = '/etc/init/consul.conf'
elsif os[:family] =~ /centos|redhat/
  service_startup_file = '/usr/lib/systemd/system/consul.service'
end

describe file(service_startup_file) do
  it { should be_file }
  it { should be_mode 644 }
end

describe command("#{consul_bin_dir}/consul --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match %r(Consul v1.0.1) }
end

describe service('consul') do
  it { should be_enabled }
  it { should be_running }
end

describe process('consul') do
  it { should be_running }
  its(:args) { should match %r(consul agent -config-dir .*) }
end
