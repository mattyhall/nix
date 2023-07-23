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

    process = {
      enable = true;
      port = 9004;

      settings.process_names = [
        {
          name = "{{.Matches.Wrapped}} {{ .Matches.Args }}";
          cmdline = ["^/nix/store[^ ]*/(?P<Wrapped>[^ /]*) (?P<Args>.*)"];
        }
      ];
    };
  };
}
