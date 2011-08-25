CREATE TABLE `host` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, 
	`hostname` VARCHAR(128) NOT NULL DEFAULT '',
	`customer` VARCHAR(64) NOT NULL DEFAULT '',
	`active` CHAR(1) NOT NULL DEFAULT 'Y',
	PRIMARY KEY (`id`),
	UNIQUE KEY (`hostname`),
	INDEX (`customer`),
	INDEX (`active`)
) ENGINE=InnoDB;
