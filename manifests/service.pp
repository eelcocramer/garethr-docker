# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
class docker::service (
  $tcp_bind             = $docker::tcp_bind,
  $socket_bind          = $docker::socket_bind,
  $service_state        = $docker::service_state,
  $root_dir             = $docker::root_dir,
  $extra_parameters     = $docker::extra_parameters,
){
  case $::osfamily {
    'Debian': {
      service { 'docker':
        ensure     => $service_state,
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        provider   => upstart,
      }

      file { '/etc/init/docker.conf':
        ensure  => present,
        force   => true,
        content => template('docker/etc/init/docker.conf.erb'),
        notify  => Service['docker'],
      }
    }
    'RedHat': {
      service { 'docker':
        ensure     => $service_state,
      }

      file { '/etc/sysconfig/docker':
        ensure  => present,
        force   => true,
        content => template('docker/etc/sysconfig/docker.erb'),
        notify  => Service['docker'],
      }
    }
    'Archlinux': {
      service { 'docker':
        ensure    => $service_state,
        enable    => true,
        hasstatus => true,
        provider  => systemd,
      }

      file { '/usr/lib/systemd/system/docker.service':
        ensure  => present,
        force   => true,
        content => template('docker/etc/systemd/docker.service.erb'),
        notify  => Service['docker'],
      }
    }
    default: {
      fail('Docker needs a RedHat, Debian or Archlinux based system.')
    }
  }
}
