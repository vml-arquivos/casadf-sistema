CREATE TABLE `users` (
	`id` int AUTO_INCREMENT NOT NULL,
	`openId` varchar(64) NOT NULL,
	`name` text,
	`email` varchar(320),
	`loginMethod` varchar(64),
	`role` enum('user','admin') NOT NULL DEFAULT 'user',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	`lastSignedIn` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `users_id` PRIMARY KEY(`id`),
	CONSTRAINT `users_openId_unique` UNIQUE(`openId`)
);
CREATE TABLE `blog_categories` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(100) NOT NULL,
	`slug` varchar(100) NOT NULL,
	`description` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `blog_categories_id` PRIMARY KEY(`id`),
	CONSTRAINT `blog_categories_slug_unique` UNIQUE(`slug`)
);
--> statement-breakpoint
CREATE TABLE `blog_posts` (
	`id` int AUTO_INCREMENT NOT NULL,
	`title` varchar(255) NOT NULL,
	`slug` varchar(255) NOT NULL,
	`excerpt` text,
	`content` text NOT NULL,
	`featuredImage` varchar(500),
	`categoryId` int,
	`authorId` int,
	`metaTitle` varchar(255),
	`metaDescription` text,
	`published` boolean DEFAULT false,
	`publishedAt` timestamp,
	`views` int DEFAULT 0,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `blog_posts_id` PRIMARY KEY(`id`),
	CONSTRAINT `blog_posts_slug_unique` UNIQUE(`slug`)
);
--> statement-breakpoint
CREATE TABLE `interactions` (
	`id` int AUTO_INCREMENT NOT NULL,
	`leadId` int NOT NULL,
	`userId` int,
	`type` enum('ligacao','whatsapp','email','visita','reuniao','proposta','nota','status_change') NOT NULL,
	`subject` varchar(255),
	`description` text,
	`metadata` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `interactions_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `leads` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(255) NOT NULL,
	`email` varchar(320),
	`phone` varchar(20),
	`whatsapp` varchar(20),
	`source` enum('site','whatsapp','instagram','facebook','indicacao','portal_zap','portal_vivareal','portal_olx','google','outro') DEFAULT 'site',
	`stage` enum('novo','contato_inicial','qualificado','visita_agendada','visita_realizada','proposta','negociacao','fechado_ganho','fechado_perdido','sem_interesse') NOT NULL DEFAULT 'novo',
	`buyerProfile` enum('investidor','primeira_casa','upgrade','curioso','indeciso'),
	`interestedPropertyId` int,
	`budgetMin` int,
	`budgetMax` int,
	`preferredNeighborhoods` text,
	`preferredPropertyTypes` text,
	`notes` text,
	`tags` text,
	`assignedTo` int,
	`score` int DEFAULT 0,
	`priority` enum('baixa','media','alta','urgente') DEFAULT 'media',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	`lastContactedAt` timestamp,
	`convertedAt` timestamp,
	CONSTRAINT `leads_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `properties` (
	`id` int AUTO_INCREMENT NOT NULL,
	`title` varchar(255) NOT NULL,
	`description` text,
	`referenceCode` varchar(50),
	`propertyType` enum('casa','apartamento','cobertura','terreno','comercial','rural','lancamento') NOT NULL,
	`transactionType` enum('venda','locacao','ambos') NOT NULL,
	`address` varchar(255),
	`neighborhood` varchar(100),
	`city` varchar(100),
	`state` varchar(2),
	`zipCode` varchar(10),
	`latitude` varchar(50),
	`longitude` varchar(50),
	`salePrice` int,
	`rentPrice` int,
	`condoFee` int,
	`iptu` int,
	`bedrooms` int,
	`bathrooms` int,
	`suites` int,
	`parkingSpaces` int,
	`totalArea` int,
	`builtArea` int,
	`features` text,
	`images` text,
	`mainImage` varchar(500),
	`status` enum('disponivel','reservado','vendido','alugado','inativo') NOT NULL DEFAULT 'disponivel',
	`featured` boolean DEFAULT false,
	`published` boolean DEFAULT true,
	`metaTitle` varchar(255),
	`metaDescription` text,
	`slug` varchar(255),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	`createdBy` int,
	CONSTRAINT `properties_id` PRIMARY KEY(`id`),
	CONSTRAINT `properties_referenceCode_unique` UNIQUE(`referenceCode`),
	CONSTRAINT `properties_slug_unique` UNIQUE(`slug`)
);
--> statement-breakpoint
CREATE TABLE `site_settings` (
	`id` int AUTO_INCREMENT NOT NULL,
	`companyName` varchar(255),
	`companyDescription` text,
	`companyLogo` varchar(500),
	`realtorName` varchar(255),
	`realtorPhoto` varchar(500),
	`realtorBio` text,
	`realtorCreci` varchar(50),
	`phone` varchar(20),
	`whatsapp` varchar(20),
	`email` varchar(320),
	`address` text,
	`instagram` varchar(255),
	`facebook` varchar(255),
	`youtube` varchar(255),
	`tiktok` varchar(255),
	`linkedin` varchar(255),
	`siteTitle` varchar(255),
	`siteDescription` text,
	`siteKeywords` text,
	`googleAnalyticsId` varchar(50),
	`facebookPixelId` varchar(50),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `site_settings_id` PRIMARY KEY(`id`)
);
CREATE TABLE `propertyImages` (
	`id` int AUTO_INCREMENT NOT NULL,
	`propertyId` int NOT NULL,
	`imageUrl` varchar(500) NOT NULL,
	`imageKey` varchar(500) NOT NULL,
	`isPrimary` int NOT NULL DEFAULT 0,
	`displayOrder` int NOT NULL DEFAULT 0,
	`caption` varchar(255),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `propertyImages_id` PRIMARY KEY(`id`)
);
ALTER TABLE `leads` ADD `clientType` enum('comprador','locatario','proprietario') DEFAULT 'comprador' NOT NULL;--> statement-breakpoint
ALTER TABLE `leads` ADD `qualification` enum('quente','morno','frio','nao_qualificado') DEFAULT 'nao_qualificado' NOT NULL;--> statement-breakpoint
ALTER TABLE `leads` ADD `urgencyLevel` enum('baixa','media','alta','urgente') DEFAULT 'media';--> statement-breakpoint
ALTER TABLE `leads` ADD `transactionInterest` enum('venda','locacao','ambos') DEFAULT 'venda';CREATE TABLE `ai_context_status` (
	`id` int AUTO_INCREMENT NOT NULL,
	`sessionId` varchar(255) NOT NULL,
	`phone` varchar(20) NOT NULL,
	`message` text NOT NULL,
	`role` enum('user','assistant','system') NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `ai_context_status_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `client_interests` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientId` int NOT NULL,
	`propertyType` varchar(100),
	`interestType` enum('venda','locacao','ambos'),
	`budgetMin` int,
	`budgetMax` int,
	`preferredNeighborhoods` text,
	`notes` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `client_interests_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `message_buffer` (
	`id` int AUTO_INCREMENT NOT NULL,
	`phone` varchar(20) NOT NULL,
	`messageId` varchar(255) NOT NULL,
	`content` text,
	`type` enum('incoming','outgoing') NOT NULL,
	`timestamp` timestamp NOT NULL DEFAULT (now()),
	`processed` int NOT NULL DEFAULT 0,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `message_buffer_id` PRIMARY KEY(`id`),
	CONSTRAINT `message_buffer_messageId_unique` UNIQUE(`messageId`)
);
--> statement-breakpoint
CREATE TABLE `webhook_logs` (
	`id` int AUTO_INCREMENT NOT NULL,
	`source` varchar(50) NOT NULL,
	`event` varchar(100) NOT NULL,
	`payload` text,
	`response` text,
	`status` enum('success','error','pending') NOT NULL,
	`errorMessage` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `webhook_logs_id` PRIMARY KEY(`id`)
);
CREATE TABLE `owners` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(255) NOT NULL,
	`cpfCnpj` varchar(20),
	`email` varchar(320),
	`phone` varchar(20),
	`whatsapp` varchar(20),
	`address` text,
	`city` varchar(100),
	`state` varchar(2),
	`zipCode` varchar(10),
	`bankName` varchar(100),
	`bankAgency` varchar(20),
	`bankAccount` varchar(30),
	`pixKey` varchar(255),
	`notes` text,
	`active` boolean DEFAULT true,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `owners_id` PRIMARY KEY(`id`)
);
CREATE TABLE `analytics_events` (
	`id` int AUTO_INCREMENT NOT NULL,
	`eventType` varchar(50) NOT NULL,
	`propertyId` int,
	`leadId` int,
	`userId` int,
	`source` varchar(100),
	`medium` varchar(100),
	`campaign` varchar(255),
	`url` varchar(500),
	`referrer` varchar(500),
	`userAgent` text,
	`ipAddress` varchar(45),
	`metadata` json,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `analytics_events_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `campaign_sources` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(255) NOT NULL,
	`source` varchar(100) NOT NULL,
	`medium` varchar(100),
	`campaignId` varchar(255),
	`budget` decimal(10,2),
	`clicks` int DEFAULT 0,
	`impressions` int DEFAULT 0,
	`conversions` int DEFAULT 0,
	`active` boolean DEFAULT true,
	`startDate` date,
	`endDate` date,
	`notes` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `campaign_sources_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `commissions` (
	`id` int AUTO_INCREMENT NOT NULL,
	`propertyId` int NOT NULL,
	`leadId` int NOT NULL,
	`ownerId` int,
	`salePrice` decimal(12,2) NOT NULL,
	`commissionRate` decimal(5,2) NOT NULL,
	`commissionAmount` decimal(12,2) NOT NULL,
	`splitWithAgent` boolean DEFAULT false,
	`agentName` varchar(255),
	`agentCommissionAmount` decimal(12,2),
	`status` varchar(50) DEFAULT 'pending',
	`paymentDate` date,
	`notes` text,
	`transactionId` int,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `commissions_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `reviews` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientName` varchar(255) NOT NULL,
	`clientRole` varchar(100),
	`clientPhoto` varchar(500),
	`rating` int NOT NULL,
	`title` varchar(255),
	`content` text NOT NULL,
	`propertyId` int,
	`leadId` int,
	`approved` boolean DEFAULT false,
	`featured` boolean DEFAULT false,
	`displayOrder` int DEFAULT 0,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `reviews_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `transactions` (
	`id` int AUTO_INCREMENT NOT NULL,
	`type` varchar(50) NOT NULL,
	`category` varchar(100),
	`amount` decimal(12,2) NOT NULL,
	`currency` varchar(3) DEFAULT 'BRL',
	`propertyId` int,
	`leadId` int,
	`ownerId` int,
	`description` text NOT NULL,
	`notes` text,
	`status` varchar(50) DEFAULT 'pending',
	`paymentMethod` varchar(50),
	`paymentDate` date,
	`dueDate` date,
	`receiptUrl` varchar(500),
	`invoiceNumber` varchar(100),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `transactions_id` PRIMARY KEY(`id`)
);
