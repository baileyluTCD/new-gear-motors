{ pkgs }:
let
  postgresConf = pkgs.writeText "postgresql.conf" ''
    unix_socket_directories = '/tmp'
  '';

  pgSetup = ''
    CREATE USER postgres WITH PASSWORD 'postgres' CREATEDB SUPERUSER;
    CREATE DATABASE next_gear_motors_dev;
  '';
in
pkgs.writeShellApplication {
  name = "postgres-dev";

  runtimeInputs = with pkgs; [
    postgresql
  ];

  runtimeEnv = {
    PGDATA = ".database";
  };

  text = ''
    if [ ! -d $PGDATA ]; then
      initdb -D $PGDATA

      cat "${postgresConf}" >> $PGDATA/postgresql.conf

      postgres --single -E postgres <<< "${pgSetup}"
    fi

    exec postgres
  '';
}
