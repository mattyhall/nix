{ pkgs, config, ... }: {
  imports = [ ./hardware.nix ../configuration.nix ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking.hostName = "barbican";

  machine.graphical = {
    enable = true;
    wm = "xfce";
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users."mjh".openssh.authorizedKeys.keys = [
    (builtins.readFile ../../keys/rocket.pub)
    (builtins.readFile ../../keys/jester.pub)
  ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = ["192.168.1.147" "8.8.8.8"];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };

  services.grafana = {
    enable = true;
    settings.server = {
      http_addr = "127.0.0.1";
      http_port = 2342;
      domain = "grafana.barbican.local";
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "cpu" "cpufreq" "diskstats" "hwmon" "filesystem" "loadavg" "meminfo" "netdev" ];
        port = 9002;
      };
      pihole = {
        enable = true;
        piholeHostname = "192.168.1.147";
        # FIXME: find a way of storing the password
        # password = builtins.readFile ../../secrets/pihole.pass;
        port = 9003;
      };
    };

    scrapeConfigs = [
      {
        job_name = "barbican";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "pihole";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.pihole.port}" ];
        }];
      }
    ];
  };

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3030;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
        max_transfer_retries = 0;
      };

      schema_config = {
        configs = [{
          from = "2022-06-06";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };

      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          cache_ttl = "24h";
          shared_store = "filesystem";
        };

        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };

      chunk_store_config = {
        max_look_back_period = "0s";
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor = {
        working_directory = "/var/lib/loki";
        shared_store = "filesystem";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3031;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [{
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
      }];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = "barbican";
          };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };

  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/run/media/mjh/ddf2e11c-7aa4-4833-9cfc-8c84e9a453f9/music/";
      Port = 4533;
      Address = "0.0.0.0";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."dns.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8000";
    virtualHosts."films.barbican.local".locations."/".proxyPass = "http://127.0.0.1:7878";
    virtualHosts."tv.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8989";
    virtualHosts."jellyfin.barbican.local".locations."/".proxyPass = "http://127.0.0.1:8096";
    virtualHosts."prometheus.barbican.local".locations."/".proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
    virtualHosts."music.barbican.local".locations."/".proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}";

    virtualHosts."${config.services.grafana.settings.server.domain}".locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };

    virtualHosts."qbit.barbican.local".locations."/".return = "301 http://192.168.1.147:8080";
  };

  networking.firewall.allowedTCPPorts = [ 80 3389 4533 ];

  system.stateVersion = "22.05";
}
