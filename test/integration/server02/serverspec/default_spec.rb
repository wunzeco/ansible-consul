require 'spec_helper'

consul_conf_dir = '/etc/consul.d'

describe file("#{consul_conf_dir}/server/config.json") do
  it { should be_file }
  it { should be_mode 644 }
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
