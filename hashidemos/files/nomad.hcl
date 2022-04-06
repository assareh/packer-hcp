# Full configuration options can be found at https://www.nomadproject.io/docs/configuration

advertise {
  http = "{{ GetInterfaceIP `ens5` }}"
  rpc  = "{{ GetInterfaceIP `ens5` }}"
  serf = "{{ GetInterfaceIP `ens5` }}"
}

autopilot {
  cleanup_dead_servers      = true
  disable_upgrade_migration = false
  enable_custom_upgrades    = true
  enable_redundancy_zones   = false
  last_contact_threshold    = "200ms"
  max_trailing_logs         = 250
  server_stabilization_time = "10s"
}

bind_addr = "0.0.0.0"

client {
  enabled = false
}

// consul {
//   address   = "127.0.0.1:8501"
//   ca_file   = "/etc/vault.d/consul-agent-ca.pem"
//   cert_file = "/etc/vault.d/dc1-client-consul.pem"
//   key_file  = "/etc/vault.d/dc1-client-consul-key.pem"
//   ssl       = true
// }

data_dir = "/opt/nomad"

leave_on_terminate = true

log_level = "INFO"

// plugin "containerd-driver" {
//   config {
//     enabled            = true
//     containerd_runtime = "io.containerd.runc.v2"
//   }
// }

// plugin "docker" {
//   config {
//     allow_caps = ["AUDIT_WRITE", "CHOWN", "DAC_OVERRIDE", "FOWNER", "FSETID", "KILL", "MKNOD", "NET_ADMIN",
//     "NET_BIND_SERVICE", "NET_BROADCAST", "NET_RAW", "SETFCAP", "SETGID", "SETPCAP", "SETUID", "SYS_CHROOT"]
//     allow_privileged = true # required for NFS CSI Plugin
//     volumes {
//       enabled = true
//     }
//   }
// }

// plugin "raw_exec" {
//   config {
//     enabled = true
//   }
// }

server {
  enabled          = true
  bootstrap_expect = 1
  license_path     = "/etc/nomad.d/license.hclic"
  raft_protocol    = 3
  upgrade_version  = "0.0.0"
}

// telemetry {
//   datadog_address            = "localhost:8125"
//   datadog_tags               = ["role:castle"]
//   disable_hostname           = true
//   prometheus_metrics         = true
//   publish_allocation_metrics = true
//   publish_node_metrics       = true
// }

vault {
  address   = "VAULT_ADDR"
  enabled   = true
  namespace = "admin"

  #  create_from_role = "nomad-cluster"
}
