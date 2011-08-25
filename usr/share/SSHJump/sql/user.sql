CREATE TABLE `user` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, 
	`username` VARCHAR(16) NOT NULL DEFAULT '',
	`real_name` VARCHAR(64) NOT NULL DEFAULT '',
	`email` VARCHAR(256) NOT NULL DEFAULT '',
	`phone` VARCHAR(16) NOT NULL DEFAULT '',
	`access` VARCHAR(16) NOT NULL DEFAULT 'USER',
	`active` CHAR(1) NOT NULL DEFAULT 'Y',
	PRIMARY KEY (`id`),
	UNIQUE KEY (`username`),
	INDEX (`real_name`),
	INDEX (`access`),
	INDEX (`active`)
) ENGINE=InnoDB;
