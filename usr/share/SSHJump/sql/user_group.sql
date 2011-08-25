CREATE TABLE `user_group` (
	`user_id` INT UNSIGNED NOT NULL,
	`group_id` INT UNSIGNED NOT NULL,
	PRIMARY KEY (`user_id`, `group_id`),
	FOREIGN KEY (`user_id`)
		REFERENCES `user` (`id`)
		ON DELETE CASCADE,
	FOREIGN KEY (`group_id`)
		REFERENCES `group` (`id`)
		ON DELETE CASCADE
) ENGINE=InnoDB;
