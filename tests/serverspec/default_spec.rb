require "spec_helper"
require "serverspec"

package = "mopidy"
service = "mopidy"
config  = "/etc/mopidy/mopidy.conf"
user    = "mopidy"
group   = "audio"
ports   = [ 6600, 6680 ]
log_dir = "/var/log/mopidy"
cache_dir  = "/var/cache/mopidy"
data_dir = "/var/lib/mopidy"
media_dir = "/var/lib/mopidy/media"
playlists_dir = "/var/lib/mopidy/playlists"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/mopidy.conf"
  db_dir = "/var/db/mopidy"
end

describe package(package) do
  it { should be_installed }
end 

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("mopidy") }
end

[ log_dir, cache_dir, data_dir, media_dir, playlists_dir ].each do |d|
  describe file(d) do
    it { should exist }
    it { should be_mode 755 }
    it { should be_owned_by user }
    it { should be_grouped_into group }
  end
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/mopidy") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
