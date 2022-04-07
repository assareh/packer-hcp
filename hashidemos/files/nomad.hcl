# Full configuration options can be found at https://www.nomadproject.io/docs/configuration

advertise {
  http = "{{ GetInterfaceIP \`ens5\` }}"
  rpc  = "{{ GetInterfaceIP \`ens5\` }}"
  serf = "{{ GetInterfaceIP \`ens5\` }}"
}

bind_addr = "0.0.0.0"

client {
  enabled = true
  servers = ["NOMAD_ADDR:4647"]
}

consul {
  address   = "127.0.0.1:8501"
  ca_file   = "/etc/nomad.d/ca.pem"
  cert_file = "/etc/nomad.d/dc1-client-consul.pem"
  key_file  = "/etc/nomad.d/dc1-client-consul-key.pem"
  ssl       = true
}

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

// telemetry {
//   datadog_address            = "localhost:8125"
//   datadog_tags               = ["role:castle"]
//   disable_hostname           = true
//   prometheus_metrics         = true
//   publish_allocation_metrics = true
//   publish_node_metrics       = true
// }

