pid_file = "./pidfile"

exit_after_auth = true

vault {
  address = "VAULT_ADDR"

  retry {
    num_retries = 3
  }
}

auto_auth {
  method {
    type      = "aws"
    namespace = "admin"

    config = {
      type = "ec2"
      role = "nomad"
    }
  }

  sink "file" {
    config = {
      path = "vault-token-via-agent"
      mode = 0400
    }
  }
}
