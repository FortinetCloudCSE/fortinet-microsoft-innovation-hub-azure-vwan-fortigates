locals {
  static_routes = {
    "azure_lb_health_probe" = {
      dst      = "168.63.129.16 255.255.255.255"
      gateway  = "10.100.112.1"
      device   = "port2"
      distance = 5

      priority = 1
      status   = "enable"
    }
    "azure_vwan_network" = {
      dst      = "10.100.0.0/16"
      gateway  = "10.100.112.1"
      device   = "port2"
      distance = 10

      priority = 1
      status   = "enable"
    }
  }
  vip_spoke_1_webserver = "VIP-Spoke-1-Webserver"
  vip_spoke_2_webserver = "VIP-Spoke-2-Webserver"

  firewall_vips = {
    (local.vip_spoke_1_webserver) = {
      name             = local.vip_spoke_1_webserver
      extintf          = "port1"
      extip            = "172.191.214.169"
      extport          = "80"
      portforward      = "enable"
      portmapping_type = "1-to-1"
      protocol         = "tcp"
      mappedport       = "80"
      type             = "static-nat"
      mappedip = {
        range = "192.168.10.4"
      }
    }
    (local.vip_spoke_2_webserver) = {
      name             = local.vip_spoke_2_webserver
      extintf          = "port1"
      extip            = "172.191.214.169"
      extport          = "8080"
      portforward      = "enable"
      portmapping_type = "1-to-1"
      protocol         = "tcp"
      mappedport       = "80"
      type             = "static-nat"
      mappedip = {
        range = "192.168.20.4"
      }
    }
  }

  firewall_policys = {
    "port2_to_port2" = {
      name = "port2_to_port2"

      srcintf = [{
        name = "port2"
      }]

      dstintf = [{
        name = "port2"
      }]

      srcaddr = [{
        name = "all"
      }]

      dstaddr = [{
        name = "all"
      }]

      schedule = "always"

      service = [{
        name = "ALL"
      }]

      action     = "accept"
      nat        = "disable"
      logtraffic = "all"

      status = "enable"
    }
    "port2_to_internet" = {
      name = "port2_to_internet"

      srcintf = [{
        name = "port2"
      }]

      dstintf = [{
        name = "port1"
      }]

      srcaddr = [{
        name = "all"
      }]

      dstaddr = [{
        name = "all"
      }]

      schedule = "always"

      service = [{
        name = "ALL"
      }]

      action     = "accept"
      nat        = "enable"
      logtraffic = "all"

      status = "enable"
    }
    "internet_to_spoke_1_webserver" = {
      name = "internet_to_spoke_1_webserver"

      srcintf = [{
        name = "port1"
      }]

      dstintf = [{
        name = "port2"
      }]

      srcaddr = [{
        name = "all"
      }]

      dstaddr = [{
        name = fortios_firewall_vip.firewall_vip_fgt-0[local.vip_spoke_1_webserver].name
      }]

      schedule = "always"

      service = [{
        name = "HTTP"
      }]

      action     = "accept"
      nat        = "enable"
      logtraffic = "all"

      status = "enable"
    }
    "internet_to_spoke_2_webserver" = {
      name = "internet_to_spoke_2_webserver"

      srcintf = [{
        name = "port1"
      }]

      dstintf = [{
        name = "port2"
      }]

      srcaddr = [{
        name = "all"
      }]

      dstaddr = [{
        name = fortios_firewall_vip.firewall_vip_fgt-0[local.vip_spoke_2_webserver].name
      }]

      schedule = "always"

      service = [{
        name = "HTTP"
      }]

      action     = "accept"
      nat        = "enable"
      logtraffic = "all"

      status = "enable"
    }
  }
}