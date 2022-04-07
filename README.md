# packer
Here lies the code to push an AMI artifact to HCP Packer and AWS Cloud in a specified VPC.

You will need HCP, AWS, and Azure credentials.

```
hashidemos-base
  |    |    |
  |    |    -- hashidemos: generic worker node with web server
  |    |
  |    -- hashidemos-k3s: k3s
  |
  -- hashidemos-nomad: nomad server
```

TODO
clean up unused vars