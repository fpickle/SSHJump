CREATE TABLE `group` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, 
	`groupname` VARCHAR(32) NOT NULL DEFAULT '',
	`description` VARCHAR(512) NOT NULL DEFAULT '',
	`remote_user` VARCHAR(16) NOT NULL DEFAULT '',
	`sshkey_id` INT UNSIGNED NOT NULL,
	PRIMARY KEY (`id`),
	UNIQUE KEY (`groupname`),
	FOREIGN KEY (`sshkey_id`)
		REFERENCES `sshkey` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;
