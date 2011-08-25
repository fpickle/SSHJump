CREATE TABLE `log` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, 
	`user_id` INT UNSIGNED NOT NULL,
	`host_id` INT UNSIGNED NOT NULL,
	`session_id` INT UNSIGNED NOT NULL,
	`entry_type` VARCHAR(16) NOT NULL DEFAULT '',
	`entry_time` TIMESTAMP DEFAULT NOW(),
	`entry` VARCHAR(1024) NOT NULL DEFAULT '',
	PRIMARY KEY (`id`),
	INDEX (`host_id`),
	INDEX (`entry_type`),
	INDEX (`entry_time`),
	FOREIGN KEY (`user_id`)
		REFERENCES `user` (`id`)
		ON DELETE CASCADE,
	FOREIGN KEY (`host_id`)
		REFERENCES `host` (`id`)
		ON DELETE CASCADE,
	FOREIGN KEY (`session_id`)
		REFERENCES `session` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;
