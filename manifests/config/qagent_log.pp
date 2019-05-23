# @summary Configure the Qualys agent
#
# Manage the main qagent-log.conf configuration file
class qualys_agent::config::qagent_log {

  $channel_name = $::qualys_agent::config::channel_name
  $log_path = "${qualys_agent::log_file_dir}/qualys-cloud-agent.log"

  file { "${qualys_agent::conf_dir}/qagent-log.conf":
    ensure  => $::qualys_agent::config::ensure,
    owner   => $::qualys_agent::agent_user,
    group   => $::qualys_agent::agent_group,
    mode    => '0644',
    content => template('qualys_agent/qagent-log.conf.erb'),
  }

}