# Full configuration options can be found at https://www.consul.io/docs/agent/options.html
# This is not the complete configuration, the rest will come from HCP config file

bind_addr = "{{ GetInterfaceIP `ens5` }}"

connect {
  enabled = true
}

data_dir = "/opt/consul"

ports {
  grpc  = 8502
  http  = -1
  https = 8501
}
