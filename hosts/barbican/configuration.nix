# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  secrets = import ../../secrets.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../common.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
  };

  networking.hostName = "barbican";

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.defaultSession = "xfce";

  environment.systemPackages = with pkgs; [
    vim 
    git
    fish
    firefox
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  users.users."mjh".openssh.authorizedKeys.keys = [
    # Rocket
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDb+9A1+2nM1bd3FU4degfifjSYnVPpru2tiYSKJ+tV5uO4mkyttyqyRTnJ2+9/Q+JZ6ktBLM4C+PBeVRhqZxUNHYqtjbq6BUbH5hBzhXIUgRhVJJAlEsX3yswbMNaYHbtIrT7lpWH30y9glce2Var6l9RTiG71nljRweEvp6ZQ3N3ojClbHWzBizg9wDm0eFB2fsE0O3akbvdmESauPXrgGfsTd6gG4M6IvO44qGDGZwrWfKAukTyxUyPQwzbTMRRBcKKNY70F03HnJiciTvniFyKk3v2X9b+DlRDLQodZADmotZh4Z6uucqFs97jIXCFVk4WgRbiG/Ys5dBKUkCCZRU2nOMMVtNo1pJPc9GjQ/+vuCPsjiQzt30469IpT5raxZ/P/rMj37+hMs3PySCIn7vzCFQ5YEdDFXdEQ5E3qgHarPHUcc0+ghopCKeEMXJu1Z7pH3QrdZg0xT65wtG4oi0g5DX7VjSYq9EmNPPOVMkKlSKVuioJ7/iSFHOfL/1c= mjh@DESKTOP-NJE68U1"
    # Jester
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDS/YEvkD+E7cBies5HKJfnZFyZKXgXvEgyUhU6MJVlfWiaQkVb65Q8wW3pHCaSTUXZqHdUMFzobpMSLhcSXuctShtHja6N5oTklM4D85TwDuN9pg+izUG+BXlO2Fj+KgdSqgOFCmjknk3/kju4hluTJ8cbgWqBvvAocoozN/KrDdkDaOWkNRLgXGqROiCwwHUWLUcLPN8pSbdF0P/9xEf7LgZkZgys8o5QnhvOrXsNaZk7QJYYG3eFMw8F0qBGc91FJxbOaeN4EZYfpvvz9O7jN2lpftd6Y8PM81xVUKpSh7QO2Z+7HO3MxM2sZJk0hnEQ8foi7DNHHdGJ1WV8hJJ9jea+XxeYxihtLGv4fimmobUAmK3wtfJwogn2qFPN+LToOktQgGGv4XGUJLxiyzY4Hb5O8JDC1Oq31gTHB67pZeMrYd2mOMMQ9UVWc8Ua7YQIt4nLqCdWkxs8G7s6FN1ZOcbskC0sWQagERCWdkws/pCm54E8QZi8+Szir/bSK20= mjh@jester"
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    dns = ["192.168.1.147" "8.8.8.8"];
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
    domain = "grafana.barbican.local";
    port = 2342;
    addr = "127.0.0.1";
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
        password = secrets.pihole.password;
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
            host = "pihole";
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

    virtualHosts."${config.services.grafana.domain}".locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
      '';
    };

    virtualHosts."qbit.barbican.local".locations."/".return = "301 http://192.168.1.147:8080";
  };

  networking.firewall.allowedTCPPorts = [ 80 4533 ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

