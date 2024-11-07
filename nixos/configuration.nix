{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

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
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Under normal circumstances we would listen to your server's cloud-init callback and mark the server
  # as installed at this point. As we don't deliver cloud-init with NixOS we have to use a workaround
  # to indicate that your server is successfully installed. You can remove the cronjob after the server
  # has been started the first time. It's no longer needed.

  services.cron.enable = true;
  services.cron.systemCronJobs = [
    "@reboot root sleep 30 && curl -L -XPOST -q https://portal.vps2day.com/api/service/v1/cloud-init/callback > /dev/null 2>&1"
  ];

  # Please remove the hardcoded password from the configuration and set
  # the password using the "passwd" command after the first boot.

  users.users.root = {
    isNormalUser = false;
    password = "mMbQ6CDXyRnPqnaeNW!m"; # changed
  };
  
  users.users.erica = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [ vim git blue];
  
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
			hostname = "user.agatha-budget.fr";
			http-port = 38080;
			proxy = "passthrough";
			http-enabled = true;
		};
		initialAdminPassword = "e6Wcm0RrtegMEHl";  # change on first login
		database = {
			type = "postgresql";
      username = "udu2xgpazxousvlttb9i";
			passwordFile = "/home/erica/config/secret/keycloak-db-password";

      # external DB
      host = "bpbosc8sbpdroefwgm8w-postgresql.services.clever-cloud.com:50013";
      name = "bpbosc8sbpdroefwgm8w";
      
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
}
