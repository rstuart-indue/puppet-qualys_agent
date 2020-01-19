# @summary Configure the Qualys agent service
#
# Manage the system service that runs the Qualys agent
#
class qualys_agent::service {

  if $qualys_agent::manage_service {
    # Force service stopped and disabled if agent ensure is "absent"
    $ensure = $qualys_agent::ensure ? {
      present => $qualys_agent::service_ensure,
      absent  => 'stopped',
    }
    $enable = $qualys_agent::ensure ? {
      present => $qualys_agent::service_enable,
      absent  => false,
    }

    service { 'qualys_agent':
      ensure    => $ensure,
      enable    => $enable,
      name      => $qualys_agent::service_name,
      subscribe => [
        File['qualys_config'],
        File['qualys_log_config'],
        File['qualys_udc_log_config'],
        $qualys_agent::package::package_dep,
      ],
    }
  }
}
