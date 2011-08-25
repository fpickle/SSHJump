CREATE TABLE `host_group` (
	`host_id` INT UNSIGNED NOT NULL,
	`group_id` INT UNSIGNED NOT NULL,
	UNIQUE KEY (`host_id`, `group_id`),
	FOREIGN KEY (`host_id`)
		REFERENCES `host` (`id`)
		ON DELETE CASCADE,
	FOREIGN KEY (`group_id`)
		REFERENCES `group` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;
