# @summary Configure the Qualys agent
#
# Manage the main qualys-cloud-agent.conf configuration file.  This class also includes the `qagent_log` and
# `qagent_udc_log` subclasses to configure both log configuration files.
#
class qualys_agent::config {

  if $qualys_agent::log_dest_type == 'file' {
    $channel_name = 'c3'
  } else {
    $channel_name = 'c2'
  }

  if $qualys_agent::ensure == 'present' {
    $ensure = 'file'
  } else {
    $ensure = $qualys_agent::ensure
  }

  $requires = [
    $qualys_agent::package::package_dep,
    $qualys_agent::user::user_dep,
    $qualys_agent::user::group_dep,
  ]

  if $qualys_agent::proxy_url {
    case $facts['os']['family'] {
      'RedHat': {
        file { '/etc/sysconfig/qualys-cloud-agent':
          content => "qualys_https_proxy=${qualys_agent::proxy_url}\n",
        }
      }
      'Debian': {
        file { '/etc/default/qualys-cloud-agent':
          content => "qualys_https_proxy=${qualys_agent::proxy_url}\n",
        }
      }
      'windows': {
        #exec { "\"C:\\Program Files\\Qualys\\QualysAgent\\QualysProxy.exe\" /u ${qualys_agent::proxy_url}":
        #}
      }
      default: {
        fail "Unsupported ${qualys_agent::proxy_url} on OS: ${facts['os']['family']}"
      }
    }
  }

  file { 'qualys_config':
    ensure    => $ensure,
    content   => epp('qualys_agent/qualys-cloud-agent.conf.epp', {
      activation_id        => $qualys_agent::activation_id,
      cmd_max_timeout      => $qualys_agent::cmd_max_timeout,
      cmd_stdout_size      => $qualys_agent::cmd_stdout_size,
      customer_id          => $qualys_agent::customer_id,
      hostid_search_dir    => $qualys_agent::hostid_search_dir,
      log_file_dir         => $qualys_agent::log_file_dir,
      log_level            => $qualys_agent::log_level,
      process_priority     => $qualys_agent::process_priority,
      request_timeout      => $qualys_agent::request_timeout,
      sudo_command         => $qualys_agent::sudo_command,
      sudo_user            => $qualys_agent::sudo_user,
      use_audit_dispatcher => $qualys_agent::use_audit_dispatcher,
      use_sudo             => $qualys_agent::use_sudo,
      user                 => $qualys_agent::agent_user,
      user_group           => $qualys_agent::agent_group,
    }),
    path      => "${qualys_agent::conf_dir}/qualys-cloud-agent.conf",
    owner     => $qualys_agent::owner,
    group     => $qualys_agent::agent_group,
    mode      => '0640',
    show_diff => true,
    require   => $requires,
  }

  # For some reason, a .properties file needs to exist on first start, so create it here
  # and keep it present, but don't restart the service if it changes.  Just restart if the
  # *actual* config changes.
  file { 'qualys_properties':
    ensure    => $ensure,
    content   => epp('qualys_agent/qualys-cloud-agent.conf.epp', {
      activation_id        => $qualys_agent::activation_id,
      cmd_max_timeout      => $qualys_agent::cmd_max_timeout,
      cmd_stdout_size      => $qualys_agent::cmd_stdout_size,
      customer_id          => $qualys_agent::customer_id,
      hostid_search_dir    => $qualys_agent::hostid_search_dir,
      log_file_dir         => $qualys_agent::log_file_dir,
      log_level            => $qualys_agent::log_level,
      process_priority     => $qualys_agent::process_priority,
      request_timeout      => $qualys_agent::request_timeout,
      sudo_command         => $qualys_agent::sudo_command,
      sudo_user            => $qualys_agent::sudo_user,
      use_audit_dispatcher => $qualys_agent::use_audit_dispatcher,
      use_sudo             => $qualys_agent::use_sudo,
      user                 => $qualys_agent::agent_user,
      user_group           => $qualys_agent::agent_group,
    }),
    path      => "${qualys_agent::conf_dir}/qualys-cloud-agent.properties",
    owner     => $qualys_agent::owner,
    group     => $qualys_agent::agent_group,
    mode      => '0640',
    show_diff => true,
    require   => $requires,
  }

  file {  'qualys_hostid':
    ensure  => $ensure,
    path    => $qualys_agent::hostid_path,
    owner   => 'root',
    group   => $qualys_agent::agent_group,
    mode    => '0660',
    require => $requires,
  }

  include qualys_agent::config::qagent_log
  include qualys_agent::config::qagent_udc_log
}
