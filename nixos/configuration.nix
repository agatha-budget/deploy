{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 		
    ./keycloak
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
	system.stateVersion = "24.11"; # Did you read the comment?

  time.timeZone = "Europe/Paris";

  # You should only edit the lines below if you know what you are doing.

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # This is the server's hostname you chose during the order process. Feel free to change it.

  networking.hostName = "epona";

  # We use the dhcpcd daemon to automatically configure your network. For IPv6 we need to make sure
  # that no temporary addresses (or privacy extensions) are used. Your server is required to use the
  # network data that is displayed in the Network tab in our client portal, otherwise your server will
  # loose internet access due to network filters that are in place.

  networking.dhcpcd.IPv6rs = true;
  networking.dhcpcd.persistent = true;
  networking.tempAddresses = "disabled";
  networking.interfaces.ens3.tempAddress = "disabled";

  # To allow you to properly use and access your VPS via SSH, we enable the OpenSSH server and
  # grant you root access. This is just our default configuration, you are free to remove root
  # access, create your own users and further secure your server.

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
	# 22 ssh
	# 80 http
	# 38080 keycloak
	# 443 TCP/IP for https
  networking.firewall.allowedTCPPorts = [ 22 80 38080 443];

  users.users.root = {
    isNormalUser = false;
  };
  
  users.users.erica = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [ 
    vim 
    git
    go-task
    keycloak
		custom_keycloak_themes.agatha
    temurin-bin 
    flyway
  ];
  

  ##########
  ## Cron ##
  ##########
	services.cron = {
		enable = true;
		systemCronJobs = [
			"0 1 * * * erica	/run/current-system/sw/bin/sh /home/erica/deploy/scripts/sync_bank.sh"
		];
	};

  ######################
  ## Keycloak Service ##
  ######################

  ## see : https://nixos.org/manual/nixos/stable/index.html#module-services-keycloak

  services.keycloak = {
		enable = true;
		themes = with pkgs ; {
			agatha = custom_keycloak_themes.agatha;
		};
		settings = {
			hostname = "user2.agatha-budget.fr";
			http-port = 38080;
			proxy-headers = "xforwarded";
			proxy = "passthrough";
			http-enabled = true;
		};
		initialAdminPassword = "adminin";  # change on first login
		database = {
			type = "postgresql";
      		username = "u5jsxn5dekflumihlgwz";
			passwordFile = "/home/erica/config/secret/keycloak-db-password";

      # external DB
			host = "hv-par8-008.clvrcld.net";
			port = 11703;
			name = "bm7wzozpsofh2nfiid0z";
			useSSL = false;

      # local DB
      #	createLocally = true;
		};
	};

  #####################
  ## Backend Service ##
  #####################

  ## Backend default
  systemd.services.backend = {
		description = "run the application backend";
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			User = "erica";
			WorkingDirectory = "/home/erica/deploy/release_back/default";
			ExecStartPre = "${pkgs.flyway}/bin/flyway -configFiles=flyway.conf migrate";
			ExecStart = "${pkgs.temurin-bin}/bin/java -jar -Dlogback.configurationFile=logback.xml tresorier-backend-uber.jar";
		};
	};

  ## Backend beta
	systemd.services.betabackend = {
		description = "run the application beta version of the backend";
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			User = "erica";
			WorkingDirectory = "/home/erica/deploy/release_back/beta";
			ExecStartPre = "${pkgs.flyway}/bin/flyway -configFiles=flyway.conf migrate";
			ExecStart = "${pkgs.temurin-bin}/bin/java -jar -Dlogback.configurationFile=logback.xml tresorier-backend-uber.jar";
		};
	};

  ###########
  ## NGINX ##
  ###########

  security.acme.acceptTerms = true;
	security.acme.defaults.email = "erica@agatha-budget.fr";
	users.users.nginx.extraGroups = [ "acme" ];
	systemd.services.nginx.serviceConfig.ProtectHome = false;
	services.nginx = {
		enable = true;
		recommendedProxySettings = true;
		recommendedTlsSettings = true;
		virtualHosts = {
			"mon2.agatha-budget.fr" = {
				forceSSL = true;
				enableACME = true;
				root = "/var/www/front/";
				locations."/" = {
					tryFiles = "$uri $uri/ /index.html"; 
				};
			};
			"beta2.agatha-budget.fr" = {
				forceSSL = true;
				enableACME = true;
				root = "/var/www/beta/";
				locations."/" = {
					tryFiles = "$uri $uri/ /index.html"; # redirect subpages url
				};
			};
			"api2.agatha-budget.fr" = {
				forceSSL = true;
				enableACME = true;
				locations."/" = {
					proxyPass = "http://localhost:7000";
				};
			};
			"betapi2.agatha-budget.fr" = {
				forceSSL = true;
				enableACME = true;
				locations."/" = {
					proxyPass = "http://localhost:8000";
				};
			};
			"user2.agatha-budget.fr" = {
				forceSSL = true;
				enableACME = true;
				locations."/" = {
						proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}";
            # https://www.getpagespeed.com/server-setup/nginx/tuning-proxy_buffer_size-in-nginx
						extraConfig = ''
              proxy_buffer_size 410k;
							proxy_busy_buffers_size 410k;
							proxy_buffers 110 4k;
						'';
				};
			};
		};
	};
}
