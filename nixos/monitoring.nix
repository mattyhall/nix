{config, ...}: {
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "cpu"
        "cpufreq"
        "diskstats"
        "hwmon"
        "filesystem"
        "loadavg"
        "meminfo"
        "netdev"
      ];
      port = 9002;
    };
  };
}
