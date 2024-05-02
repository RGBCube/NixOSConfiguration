{ lib, pkgs, ... }: with lib; imports [

(let
  prometheusPort = 9020;
in systemConfiguration {
  services.prometheus = {
    exporters.postgres = enabled {
      listenAddress       = "[::1]";
      port                = prometheusPort;
      runAsLocalSuperUser = true;
    };

    scrapeConfigs = [{
      job_name = "postgres";

      static_configs = [{
        labels.job = "postgres";
        targets    = [ "[::1]:${toString prometheusPort}" ];
      }];
    }];
  };

  services.postgresql = enabled {
    package = pkgs.postgresql_14;

    enableJIT = true;

    initdbArgs    = [ "--locale=C" "--encoding=UTF8" ];
    initialScript = pkgs.writeText "grant-root-perms" ''
      GRANT pg_read_all_data  TO root;
      GRANT pg_write_all_data TO root;
    '';

    authentication = mkOverride 10 ''
      # Type Database DBUser Authentication
      local  all      all    peer
    '';

    ensureUsers = [
      {
        name = "postgres";
        ensureClauses = {
          createdb    = true;
          createrole  = true;
          login       = true;
          replication = true;
          superuser   = true;
        };
      }
      {
        name = "root";
        ensureClauses = {
          createdb    = true;
          createrole  = true;
          login       = true;
          replication = true;
          superuser   = true;
        };
      }
    ];

    settings = {
      listen_addresses = mkForce "";

      # https://pgconfigurator.cybertec.at/
      max_connections                = 100;
      superuser_reserved_connections = 3;

      # Memory Settings
      shared_buffers           = "1024 MB";
      work_mem                 = "32 MB";
      maintenance_work_mem     = "320 MB";
      huge_pages               = "off";
      effective_cache_size     = "3 GB";
      effective_io_concurrency = 1; # Concurrent IO only really activated if OS supports posix_fadvise function.
      random_page_cost         = 4; # Speed of random disk access relative to sequential access (1.0).

      # Monitoring
      shared_preload_libraries = "pg_stat_statements"; # Per statement resource usage stats.
      track_io_timing          = "on";                 # Measure exact block IO times.
      track_functions          = "pl";                 # Track execution times of pl-language procedures if any.

      # Replication
      wal_level          = "replica";
      max_wal_senders    = 0;
      synchronous_commit = "on";

      # Checkpointing
      checkpoint_timeout           = "15 min";
      checkpoint_completion_target = 0.9;
      max_wal_size                 = "1024 MB";
      min_wal_size                 = "512 MB";

      # WAL writing
      wal_compression        = "on";
      wal_buffers            = -1;    # auto-tuned by Postgres till maximum of segment size (16MB by default).
      wal_writer_delay       = "200ms";
      wal_writer_flush_after = "1MB";

      # Background writer
      bgwriter_delay          = "200ms";
      bgwriter_lru_maxpages   = 100;
      bgwriter_lru_multiplier = 2.0;
      bgwriter_flush_after    = 0;

      # Parallel queries
      max_worker_processes             = 2;
      max_parallel_workers_per_gather  = 1;
      max_parallel_maintenance_workers = 1;
      max_parallel_workers             = 2;
      parallel_leader_participation    = "on";

      # Advanced features
      enable_partitionwise_join      = "on";
      enable_partitionwise_aggregate = "on";
      jit                            = "on";
      max_slot_wal_keep_size         = "1000 MB";
      track_wal_io_timing            = "on";
    };
  };
})

(systemPackages (with pkgs; [
  postgresql
]))

]
