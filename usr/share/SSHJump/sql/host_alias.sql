CREATE TABLE `host_alias` (
	`host_id` INT UNSIGNED NOT NULL,
	`alias` VARCHAR(128) NOT NULL DEFAULT '',
	PRIMARY KEY (`host_id`, `alias`),
	UNIQUE KEY (`alias`),
	FOREIGN KEY (`host_id`)
		REFERENCES `host` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;
