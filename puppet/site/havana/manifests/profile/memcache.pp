# The profile to install a local instance of memcache
class havana::profile::memcache {
  class { 'memcached':
    listen_ip => hiera('havana::controller::address::management'), #'127.0.0.1',
    tcp_port  => '11211',
    udp_port  => '11211',
  }
}
