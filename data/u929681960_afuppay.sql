-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : sam. 28 fév. 2026 à 19:48
-- Version du serveur : 11.8.3-MariaDB-log
-- Version de PHP : 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `u929681960_afuppay`
--

-- --------------------------------------------------------

--
-- Structure de la table `administrateurs`
--

CREATE TABLE `administrateurs` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mot_de_passe` varchar(255) NOT NULL COMMENT 'Hash bcrypt du mot de passe',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `administrateurs`
--

INSERT INTO `administrateurs` (`id`, `nom`, `prenom`, `email`, `mot_de_passe`, `created_at`, `updated_at`) VALUES
(1, 'SMEB EDOH', 'Emmanuel', 'smebedoh33@gmail.com', '$2b$10$m19oimaPDMNWPSCYCIBrruKO/RnKkYAQpM0PzcayCxls5pfW4rtZ6', '2026-01-17 03:01:03', '2026-01-17 09:41:52'),
(2, 'MBINAH', 'Axel', 'consultant@axelmbinah.com', '$2b$10$m19oimaPDMNWPSCYCIBrruKO/RnKkYAQpM0PzcayCxls5pfW4rtZ6', '2026-01-17 03:01:03', '2026-01-17 16:28:07'),
(3, 'AREVOMA', 'Laure', 'laure.rekoula@yahoo.fr', '$2b$10$m19oimaPDMNWPSCYCIBrruKO/RnKkYAQpM0PzcayCxls5pfW4rtZ6', '2026-01-17 03:01:03', '2026-01-17 17:32:16'),
(4, 'MAHADY', 'Jean-Pierre', 'jpmahady@gmail.com', '$2b$10$m19oimaPDMNWPSCYCIBrruKO/RnKkYAQpM0PzcayCxls5pfW4rtZ6', '2026-01-17 03:01:03', '2026-01-17 16:26:31');

-- --------------------------------------------------------

--
-- Structure de la table `rotary_billets`
--

CREATE TABLE `rotary_billets` (
  `id` varchar(50) NOT NULL,
  `reference_billet` varchar(30) NOT NULL COMMENT 'Référence unique pour QR code',
  `evenement_id` varchar(50) NOT NULL,
  `categorie_id` varchar(50) NOT NULL,
  `user_id` varchar(128) DEFAULT NULL COMMENT 'Si utilisateur connecté',
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `quantite` int(11) UNSIGNED NOT NULL DEFAULT 1,
  `prix_unitaire` decimal(12,0) UNSIGNED NOT NULL,
  `montant_total` decimal(12,0) UNSIGNED NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'XAF',
  `statut_paiement` enum('en_attente','paye','partiellement_paye','echoue','rembourse','annule') NOT NULL DEFAULT 'en_attente',
  `statut_billet` enum('actif','utilise','annule','expire') NOT NULL DEFAULT 'actif',
  `date_utilisation` datetime DEFAULT NULL COMMENT 'Date de scan du billet',
  `utilise_par` varchar(255) DEFAULT NULL COMMENT 'Qui a scanné le billet',
  `notes_participant` text DEFAULT NULL,
  `besoins_speciaux` text DEFAULT NULL COMMENT 'Allergie, accessibilité, etc',
  `code_promo` varchar(50) DEFAULT NULL,
  `montant_reduction` decimal(12,2) DEFAULT 0.00,
  `source_achat` varchar(50) DEFAULT 'site_web',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Données supplémentaires flexibles' CHECK (json_valid(`metadata`)),
  `qr_code_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rotary_billets`
--

INSERT INTO `rotary_billets` (`id`, `reference_billet`, `evenement_id`, `categorie_id`, `user_id`, `prenom`, `nom`, `email`, `telephone`, `quantite`, `prix_unitaire`, `montant_total`, `currency_code`, `statut_paiement`, `statut_billet`, `date_utilisation`, `utilise_par`, `notes_participant`, `besoins_speciaux`, `code_promo`, `montant_reduction`, `source_achat`, `metadata`, `qr_code_url`, `created_at`, `updated_at`) VALUES
('BILLET-1768589720921-8C59CBC1', 'BIL-20260116-0452CF', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE AKANDA\nHébergement: Hôtel TARA-ME\nActivité: Excursion Omboué\nubuinj hu uiu', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 18:55:26', '2026-01-17 15:41:05'),
('BILLET-1768590401600-1A3EEFED', 'BIL-20260116-A3CCFA', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE AKANDA\nHébergement: Hôtel TARA-ME\nActivité: Excursion Omboué\nubuinj hu uiu', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 19:06:46', '2026-01-17 15:41:09'),
('BILLET-1768590543448-A9EA4016', 'BIL-20260116-61F645', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE AKANDA\nHébergement: Hôtel TARA-ME\nActivité: Excursion Omboué\nubuinj hu uiu', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 19:09:08', '2026-01-17 15:41:18'),
('BILLET-1768590859471-E65C9213', 'BIL-20260116-30B4BD', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 40000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE AKANDA\nHébergement: Hôtel TARA-ME\nActivité: Excursion Omboué\nubuinj hu uiu', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 19:14:24', '2026-01-17 15:41:21'),
('BILLET-1768591253664-B3196AE5', 'BIL-20260116-6DCD0B', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 30000, 30000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL OZOURI\nHébergement: Hôtel CHEZ JIMMY\nActivité: POG TOUR\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 19:20:58', '2026-01-17 15:41:25'),
('BILLET-1768591277854-7CB38B87', 'BIL-20260116-C78A98', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 30000, 30000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL OZOURI\nHébergement: Hôtel CHEZ JIMMY\nActivité: POG TOUR\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 19:21:23', '2026-01-17 15:41:28'),
('BILLET-1768591345210-808DBA58', 'BIL-20260116-6C12A1', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 30000, 30000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL OZOURI\nHébergement: Hôtel CHEZ JIMMY\nActivité: POG TOUR\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-16 19:22:30', '2026-01-17 15:41:33'),
('BILLET-1768615543858-76F97056', 'BIL-20260117-96C6BA', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 30000, 30000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB LIBREVILLE DOYEN\nHébergement: Hôtel SICKA\nActivité: POG TOUR\ntres ', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABv6SURBVO3BUarkiLIgQXdR+9+yT8MgiB+pdfLlqb6CMLN/sNZaL3Cw1lovcbDWWi9xsNZaL3Gw1lovcbDWWi9xsNZaL3Gw1lov8Yd/ofI3VEwqp4pPqXyq4lMqT1U8pTJVnFTuVJxUpoo7KqeKSWWqeErlVDGp3Kk4qdypOKk8VTGp3Kk4qTxVMal8qmJSOVV8SuVvqLhysNZaL3Gw1lovcbDWWi/xhx+q+AaVOxVPqZwqpopJ5UrFp1SuVEwqk8qpYlKZKq5U3FF5SmWq+ITKnYqTylRxR+VKxd9QMamcKn5LxRWVKypTxaRyqrhT8Q0qTx2stdZLHKy11kv84f9A5amKn1A5VTylMlVcqZhU7lQ8VXFSmSo+pTJV/IaKKypTxVMVVyomlaliqjip3FE5VUwqV1', '2026-01-17 02:05:49', '2026-01-17 16:45:48'),
('BILLET-1768647916956-073FA56D', 'BIL-20260117-F7FB94', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'Smeb', 'Edoh', 'smebedoh33@gmail.com', '+24177679339', 1, 30000, 30000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB LIBREVILLE MONTS DE CRISTAL\nHébergement: LE GUI\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nbiensur ', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABlhSURBVO3BQXLkWLIgQTMI739lm9qEiG/iVYBkZhf+uKr9g7XWeoCLtdZ6iIu11nqIi7XWeoiLtdZ6iIu11nqIi7XWeoiLtdZ6iC/+hcrfVPGOylTxEyonFd+l8psqJpV3KiaVqWJSmSpOVKaKSeWl4kTljopJ5bsq7lCZKiaVqWJSmSreUZkqTlSmikllqphUpooXlb+p4p2LtdZ6iIu11nqIi7XWeogvbqr4TSrvqEwVk8pPVEwqJyovFScVk8pUcaIyqUwV76icqEwVf4rKn1RxovKOylTxExUnFZPKS8VUcUfFpHJHxacqfpPKpy7WWushLtZa6yEu1lrrIb74IZU7Kn5LxaQyVZyoTBUnFS8qd1ScqJxUTCrfVXGiclIxqXxXxaQyVUwqU8WkMlVMKp9SOV', '2026-01-17 11:05:22', '2026-01-17 15:41:40'),
('BILLET-1768661835954-E878BF16', 'BIL-20260117-C2BC9D', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 30000, 30000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: Hôtel SICKA\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 14:57:21', '2026-01-17 15:41:44'),
('BILLET-1768663861612-71A33A11', 'BIL-20260117-0F48D3', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH Emmanuel', 'SAGOUNAMA-MENSAH Emmanuel ', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 40000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE OKOUME\nHébergement: Hôtel LE RANCH\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nessayons ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 15:31:06', '2026-01-17 15:41:48'),
('BILLET-1768664690678-194B6EDC', 'BIL-20260117-DAE5A9', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 70000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: LE GUI\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\neioced ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 15:44:56', '2026-01-17 15:46:31'),
('BILLET-1768666033821-6D283451', 'BIL-20260117-82F260', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'sarahnzamba5@gmail.com', '+24177679339', 1, 30000, 60000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL\nHébergement: Hôtel LE RANCH\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nfsdf gjf fg f', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABwGSURBVO3BUarkiLIgQXdR+9+yT8MgiB+pdfLmqX6CMLN/sNZaL3Cw1lovcbDWWi9xsNZaL3Gw1lovcbDWWi9xsNZaL3Gw1lov8Yd/ofI3VEwqp4pPqXyq4lMqT1U8pTJVnFTuVJxUpoo7KqeKSWWqeErlVDGp3Kk4qdypOKk8VTGp3Kk4qTxVMal8qmJSOVV8SuVvqLhysNZaL3Gw1lovcbDWWi/xhx+q+AaVOxVPqZwqpopJ5UrFp1SuVEwqk8qpYlKZKq5UTCqTyqnijspU8QmVOxUnlanijsqVir+hYlI5VfyWiisqV1SmiknlVHGn4htUnjpYa62XOFhrrZf4w/9A5amKn1A5VTylMlVcqZhU7lQ8VXFSmSo+pTJVXKmYVE4qU8VUcUVlqniq4krFpDJVTB', '2026-01-17 16:07:19', '2026-01-17 16:19:29'),
('BILLET-1768669344398-249D3DFB', 'BIL-20260117-AC6439', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 70000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL\nHébergement: Hôtel SICKA\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nessaie 2', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABwbSURBVO3BQY7kBpIAQXei//9lX10IxIUUKzerRwTCzP7BWmu9wMFaa73EwVprvcTBWmu9xMFaa73EwVprvcTBWmu9xMFaa73EH/6Fyt9QMamcKj6lcqViUpkqJpUrFZPKUxVXVKaKSeUTFT+hcqqYVKaKk8pUMamcKn6LyicqJpU7FSeVpyomlU9VTCqnik+p/A0VVw7WWuslDtZa6yUO1lrrJf7wQxXfoHKn4imVU8VUMak8pTJVnFTuVFxRmVROFT9R8QmVqWJSmSqeUjlVTCpXVKaKOyqniknlb6iYVE4Vv6XiisoVlaliUjlV3Kn4BpWnDtZa6yUO1lrrJf7w/6DyVMVPqJwqPqUyVZxUpoqnKiaVqeKkMlX8L6g8VfE3VFxRuVPxVMUVlSsqP1FxRWWqeK', '2026-01-17 17:02:29', '2026-01-17 17:03:52'),
('BILLET-1768673573668-5B22E980', 'BIL-20260117-B35AEE', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Axel', 'MBINAH', 'consultant@axelmbinah.com', '074721325', 1, 40000, 70000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe suis là ', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABksSURBVO3BQY4j15IAQfdE3f/KPtoQiA2fyCK79XMQZvYP1lrrBi7WWusmLtZa6yYu1lrrJi7WWusmLtZa6yYu1lrrJi7WWusmfvgXKn9TxW+pTBWTyicqXqXyTRWTyjMVk8pUMalMFScqU8Wk8lAxqZxUTConFScqr6o4UZkqJpWTiknloWJSOamYVKaKSWWqmFSmigeVv6nimYu11rqJi7XWuomLtda6iR/eVPFNKs+onFScqEwVk8o7VB4qTio+oTKpTBXPqJyoTBV/ispU8Y6KE5WTir+lYlL5loqTiknlHRWvqvgmlVddrLXWTVystdZNXKy11k388CGVd1T8VsU7Kk4qJpWTigeVd1RMKu+omFR+q+JEZao4UXmm4hMqU8UnVJ6pmFROVN6hMlU8qJyoTB', '2026-01-17 18:12:59', '2026-01-17 18:13:45'),
('BILLET-1768673765322-82F6F8BF', 'BIL-20260117-3C7EF0', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Laure', 'REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 077 36 00 85', 1, 40000, 70000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe suis là mes enfants ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 18:16:10', '2026-01-17 18:16:10'),
('BILLET-1768673784821-272BF7BD', 'BIL-20260117-D7E089', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Laure', 'REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 077 36 00 85', 1, 40000, 70000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe suis là mes enfants ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 18:16:30', '2026-01-17 18:16:30'),
('BILLET-1768673983589-84B81E54', 'BIL-20260117-A55C22', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Laure', 'REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 077360085', 1, 40000, 70000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe suis là mes enfants ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 18:19:48', '2026-01-17 18:19:48'),
('BILLET-1768674028784-F60A785F', 'BIL-20260117-CCF672', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Laure', 'REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 241077360085', 1, 40000, 70000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe suis là mes enfants ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-17 18:20:34', '2026-01-17 18:20:34'),
('BILLET-1768674437687-C3D2D624', 'BIL-20260117-8BE287', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Laure', 'REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', '077360085', 1, 40000, 70000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe suis là mes enfants ', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABl6SURBVO3BQY4j15IAQfdE3//KPtoQiA2fmFVszU8gzOwfrLXWA1ystdZDXKy11kNcrLXWQ1ystdZDXKy11kNcrLXWQ1ystdZD/OFfqPyXKn5KZar4JpWXikllqphUpooTlZOKF5WTijtUpooTlXcqJpWTikllqvgNlZ+quENlqnhH5aTiDpWTikllqnhR+S9VvHOx1loPcbHWWg9xsdZaD/GHmyq+SeVTKlPFN6mcVLxTMancoXKHykvFpHKiMlXcofIplb9JZao4qXhROan4jYqfqphUTip+o+JTFd+k8qmLtdZ6iIu11nqIi7XWeog//JLKHRU/VTGpTBWTylRxUjGpTCovFZPKVDGpTCpTxf+KiknlpOIdlaniRGWqOKk4UXmn4kRlqjhR+a9UTConFX+Lyh', '2026-01-17 18:27:23', '2026-01-17 18:29:16'),
('BILLET-1768674685487-EF3EBF20', 'BIL-20260117-A50D27', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Jean-Pierre', 'MAHADY', 'jpmahady@gmail.com', '074447714', 1, 40000, 70000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: Excursion Omboué + Excursion Omboué (30 000 F)\nJe viens avec ma femme ', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABkWSURBVO3BS67k1pIAQXei9r9lb00SiEkeJe+nntgIM/sHa631ABdrrfUQF2ut9RAXa631EBdrrfUQF2ut9RAXa631EBdrrfUQf/gXKn9TxTsqd1ScqNxR8SmVn1QxqbxTMalMFZPKVHGiMlVMKp+q+A6VqeK3qEwVk8pUcaLyUjGpnFRMKlPFpDJVTCpTxYvK31TxzsVaaz3ExVprPcTFWms9xB9uqvhJKu+oTBXfoXJHxaTyUnFS8R0qk8pU8Y7KicpU8bdUnKicVEwVk8pXVXxHxR0Vn6o4qZhU7qj4VMVPUvnUxVprPcTFWms9xMVaaz3EH75J5Y6Kr1KZKk5UpopJ5Y6KF5XvqJhUTiomla+qOFGZKqaKSeWnVEwqk8pUMVV8SmVSuUPlpGJSmSpeVE5Upo', '2026-01-17 18:31:30', '2026-01-17 18:32:13'),
('BILLET-1768675314198-A967FE55', 'BIL-20260117-F2C26C', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '+24177679339', 1, 40000, 60000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: Hôtel LE RANCH\nActivité: POG TOUR + POG TOUR (20 000 F)\ntrop', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABvuSURBVO3BQY7kBpIAQXei//9lX10IxIUUKzerNQTCzP7BWmu9wMFaa73EwVprvcTBWmu9xMFaa73EwVprvcTBWmu9xMFaa73EH/6Fyt9QMamcKj6lcqViUpkqJpUrFVdUpoqnVKaKSeVUMalMFSeVqeKOyqliUpkqTipTxaRyqvgtKp+omFTuVJxUnqqYVD5VMamcKj6l8jdUXDlYa62XOFhrrZc4WGutl/jDD1V8g8qdiqdUThVTxaTylMpUcVL5lMpU8amKk8q3qEwVT6mcKiaVKypTxR2VU8Wk8jdUTCqnit9ScUXlispUMamcKu5UfIPKUwdrrfUSB2ut9RJ/+H9QeariJ1ROFZ9SmSpOKlPFUxWTylRxpeI3VNxRearib6i4onKn4qmKKypXVH6i4orKVP', '2026-01-17 18:41:59', '2026-01-17 18:42:53'),
('BILLET-1768847652725-7290010D', 'BIL-20260119-C7C5B7', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 40000, 60000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE SUD\nHébergement: Hôtel CHEZ JIMMY\nActivité: POG TOUR + POG TOUR (20 000 F)\n', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABvWSURBVO3BQY7khrIgQXei739lH20IxIYUK39W63EQZvYP1lrrBQ7WWuslDtZa6yUO1lrrJQ7WWuslDtZa6yUO1lrrJQ7WWusl/vAvVP6GiknlVPEplSsVk8pUMalcqbiiMlU8pTJVTCpPVZxUpoo7KqeKSWWqOKlMFZPKqeK3qHyiYlK5U3FSeapiUvlUxaRyqviUyt9QceVgrbVe4mCttV7iYK21XuIPP1TxDSp3Kp5SOVVMFZPKUypTxUnlUypTxacqTipPVdxRmSqeUjlVTCpXVKaKOyqniknlb6iYVE4Vv6XiisoVlaliUjlV3Kn4BpWnDtZa6yUO1lrrJf7wf6DyVMVPqJwqPqUyVZxUpoqnKiaVqeJKxW+ouKNypWKq+BsqrqjcqXiq4orKFZWfqLiiMl', '2026-01-19 18:34:18', '2026-01-19 18:35:36'),
('BILLET-1769449463099-1D48BD73', 'BIL-20260126-D55429', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 30000, 50000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: Hôtel TARA-ME\nActivité: POG TOUR + POG TOUR (20 000 F)\ntrouble', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-26 17:44:29', '2026-01-26 17:44:29'),
('BILLET-1769458030329-8727DFBF', 'BIL-20260126-B12A40', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 30000, 50000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB LIBREVILLE MONTS DE CRISTAL\nHébergement: external\nActivité: POG TOUR + POG TOUR (20 000 F)\ntout va bien', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-26 20:07:16', '2026-01-26 20:07:16'),
('BILLET-1769458130308-ADC387F4', 'BIL-20260126-6937F8', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 40000, 60000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL\nHébergement: Hôtel OPHELIA LODGE\nActivité: POG TOUR + POG TOUR (20 000 F)\nok', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-26 20:08:56', '2026-01-26 20:08:56'),
('BILLET-1769518395144-76B85CB7', 'BIL-20260127-CFE9A5', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 30000, 50000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: Hôtel OPHELIA LODGE\nActivité: POG TOUR + POG TOUR (20 000 F)\ncool', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 12:53:21', '2026-01-27 12:53:21'),
('BILLET-1769519009380-CC1E1C66', 'BIL-20260127-B1F45F', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 30000, 50000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL\nHébergement: Hôtel LE RANCH\nActivité: POG TOUR + POG TOUR (20 000 F)\ntres', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 13:03:36', '2026-01-27 13:03:36'),
('BILLET-1769519189724-782E22FA', 'BIL-20260127-595AC0', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-INVITE', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 35000, 55000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB LIBREVILLE DOYEN\nHébergement: Hôtel SICKA\nActivité: POG TOUR + POG TOUR (20 000 F)\ntcuiu ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 13:06:36', '2026-01-27 13:06:36'),
('BILLET-1769519397381-7FD39365', 'BIL-20260127-6D07B1', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARACTIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 30000, 50000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE DOYEN\nHébergement: Hôtel OPHELIA LODGE\nActivité: POG TOUR + POG TOUR (20 000 F)\nessaie4 ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 13:10:04', '2026-01-27 13:10:04'),
('BILLET-1769519612565-87A07955', 'BIL-20260127-60E5BD', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: Hôtel LE RANCH\nActivité: none\net la', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 13:13:39', '2026-01-27 13:13:39'),
('BILLET-1769520560378-4523D1BA', 'BIL-20260127-4EBB90', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 40000, 60000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB LIBREVILLE KOMO\nHébergement: Hôtel MANDJI LOISIRS\nActivité: POG TOUR + POG TOUR (20 000 F)\ntest4', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 13:29:27', '2026-01-27 13:29:27'),
('BILLET-1769520830505-AC68E673', 'BIL-20260127-B78ADC', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 100, 400, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARACT CLUB LIBREVILLE MONTS DE CRISTAL\nHébergement: Hôtel LE BAMBOU\nActivité: POG TOUR + POG TOUR (200 F)\ntrouble', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABvvSURBVO3BQY7kBpIAQXei//9lX10IxIUUKzerNQTCzP7BWmu9wMFaa73EwVprvcTBWmu9xMFaa73EwVprvcTBWmu9xMFaa73EH/6Fyt9QMamcKj6lcqViUpkqJpUrFVdUpoqnVKaKSeUbKu6onComlanipDJVTCqnit+i8omKSeVOxUnlqYpJ5VMVk8qp4lMqf0PFlYO11nqJg7XWeomDtdZ6iT/8UMU3qNypeErlVDFVTCpPqUwVJ5VPqUwVn6o4qUwVn1KZKp5SOVVMKldUpoo7KqeKSeVvqJhUThW/peKKyhWVqWJSOVXcqfgGlacO1lrrJQ7WWusl/vD/oPJUxU+onCo+pTJVnFSmiqcqJpWp4krFb6i4o3KlYqr4GyquqNypeKriisoVlZ+ouKIyVTxVMa', '2026-01-27 13:33:57', '2026-01-27 13:39:57'),
('BILLET-1769533038473-499BDE9C', 'BIL-20260127-45B61C', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Karen', 'NDJAVE-NDJOY', 'ndjave@gmail.com', '077193212', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE AKANDA\nHébergement: Hôtel MANDJI\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-27 16:57:25', '2026-01-27 16:57:25'),
('BILLET-1769635271421-CD54CA31', 'BIL-20260128-ECA2FC', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Zeinabou', 'BOUCKAT', 'zbouckat@yahoo.fr', '077171073', 1, 40000, 60000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE MONDAH\nHébergement: external\nActivité: POG TOUR + POG TOUR (20 000 F)\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-28 21:21:18', '2026-01-28 21:21:18'),
('BILLET-1769683007471-7B27F1FA', 'BIL-20260129-E92BB7', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Clovis ', 'Nguema ', 'clovisnguema40@gmail.com', '062001751', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE AKANDA\nHébergement: ERING PALACE\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-29 10:36:54', '2026-01-29 10:36:54'),
('BILLET-1769779870052-7483E764', 'BIL-20260130-7EF08E', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Danielle', 'OGANDAGA ', 'danielleogandaga596@gmail.com', '062700334', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE CENTRE\nHébergement: Hôtel HIBISCUS\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-30 13:31:17', '2026-01-30 13:31:17'),
('BILLET-1769873231917-4B2BD241', 'BIL-20260131-B2EF0A', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-INVITE', NULL, 'Ingonguy ', 'Necsy ', 'ingonguy83@gmail.com', '066857272', 1, 35000, 35000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: external\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-31 15:27:19', '2026-01-31 15:27:19'),
('BILLET-1769873253708-75092665', 'BIL-20260131-3AFF24', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Erard', 'NDONG ÉMANE ', 'ndongemane77@gmail.com', '066300292', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-01-31 15:27:41', '2026-01-31 15:27:41'),
('BILLET-1770464401643-6F9C49C1', 'BIL-20260207-9FBD49', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Jean-Pierre ', 'MAHADY', 'jpmahady@gmail.com', '074447714', 1, 40000, 40000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB PORT-GENTIL\nHébergement: external\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABkWSURBVO3BQW4kRxIAQffC/P/LvroQiEunusjmaAsIM/sHa631ABdrrfUQF2ut9RAXa631EBdrrfUQF2ut9RAXa631EBdrrfUQf/gXKn9TxaeoTBWTylQxqUwV71L5pIpJ5ZWKSWWqmFSmihOVqWJS+a6KSeWkYlKZKl5RmSpOVKaKSeW7Kk5UpopJZaqYVKaKSWWq+KLyN1W8crHWWg9xsdZaD3Gx1loP8YebKj5J5RWVOyp+QmWqmFS+VJxUTCpTxYnKpDJVvKJyojJV/JaKO1T+lopPqjhRmSo+pWJSuaPiXRWfpPKui7XWeoiLtdZ6iIu11nqIP/yQyh0Vf0vFpPITFV9U7qiYVO6omFS+q+JEZao4UXlFZao4qZhUpoqTihOVLxWTyh0qn6IyVdyhclLxW1', '2026-02-07 11:40:09', '2026-02-07 11:40:56'),
('BILLET-1770620748982-7FB08788', 'BIL-20260209-A41A8A', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Erica Ingrid Greta ', 'AGOMA RENDAMBO ', 'sylgabamh@gmail.com', '077738024', 1, 40000, 40000, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE DOYEN\nHébergement: none\nActivité: none\nBonjour à tous.', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABuoSURBVO3BQW7lhpIAwUxC979yjjcEakM29b7UNjEVYf9grbVe4GCttV7iYK21XuJgrbVe4mCttV7iYK21XuJgrbVe4mCttV7iiz9Q+Rsq/jaVn1IxqZwqJpUrFZPKVDGp/ISKOyqniknlSsWk8hsq7qh8omJSuVNxUnmqYlL5VMWkcqr4lMrfUHHlYK21XuJgrbVe4mCttV7ii2+q+AkqP0XlVDGp/IaKp1TuVJxUpoo7FSeVqeJTKlPFUxVPVVxRuVNxUnmq4o7KlYpJZVI5VfyUiknlVDGpXFGZKiaVU8Wdip+g8tTBWmu9xMFaa73EF/8DlacqvkPlVDGpPFVxRWWqmFSmipPKVDFVXFF5SmWqmFROFU+pTBWfqphUrlRcUflUxaQyVZxU/gaVpyruqFxRmS', '2026-02-09 07:05:57', '2026-02-09 07:07:23'),
('BILLET-1770627769049-852EB084', 'BIL-20260209-5A4B95', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Erica Ingrid Greta ', 'AGOMA RENDAMBO ', 'sylgabamh@gmail.com', '077738024', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE DOYEN\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-09 09:02:57', '2026-02-09 09:02:57'),
('BILLET-1770652272503-9CD13699', 'BIL-20260209-F2B2BD', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'MISTA ', 'AGALIE ', 'mistaagalie@gmail.com', '066778686', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE KOMO\nHébergement: none\nActivité: none\nPour l\'activité, je vais me décider la semaine prochaine ', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-09 15:51:21', '2026-02-09 15:51:21'),
('BILLET-1770669224126-B3F8DAB6', 'BIL-20260209-20C3D4', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Jacques Fortune', 'NZOUGHET ESSAI', 'jacquesfortunenzoughetessia@gmai.com', '077410098', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-09 20:33:52', '2026-02-09 20:33:52'),
('BILLET-1770669525451-880BED51', 'BIL-20260209-50FCB1', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Jacques fortune', 'Nzoughet essia', 'jacquesfortunenzoughetessia@gmai.com', '077410098', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-09 20:38:54', '2026-02-09 20:38:54'),
('BILLET-1770669737244-02BC39B9', 'BIL-20260209-A6CAF0', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'JACQUES FORTUNE', 'NZOUGHET ESSIA', 'jacquesfortunenzoughetessia@gmal.com', '077410098', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARACT CLUB PORT-GENTIL OZOURI\nHébergement: none\nActivité: none\nPayement espece', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-09 20:42:25', '2026-02-09 20:42:25'),
('BILLET-1771321314705-60DD45A1', 'BIL-20260217-DB84A9', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Patrick', 'Mennesson ', 'patrickmennesson@yahoo.fr', '065666969', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE SUD\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-17 09:42:04', '2026-02-17 09:42:04'),
('BILLET-1771322839844-AB352634', 'BIL-20260217-419DC1', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'Patrick', 'Mennesson', 'patrickmennesson@yahoo.fr', '065666969', 1, 40000, 40000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE SUD\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-17 10:07:29', '2026-02-17 10:07:29'),
('BILLET-1771345024149-4EB9C1CC', 'BIL-20260217-82BDDD', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 40000, 300, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE DOYEN\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-17 16:17:13', '2026-02-17 16:17:13'),
('BILLET-1771345258747-23A13635', 'BIL-20260217-49325C', 'EV-ROTARY-FORUM-2026', 'CAT-FORUM-2026-ROTARIEN', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 40000, 300, 'XAF', 'paye', 'actif', NULL, NULL, 'Club: ROTARY CLUB LIBREVILLE DOYEN\nHébergement: none\nActivité: none\n', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABvSSURBVO3BQY7kBpIAQXei//9lX10IxIUUKzerRwTCzP7BWmu9wMFaa73EwVprvcTBWmu9xMFaa73EwVprvcTBWmu9xMFaa73EH/6Fyt9QMamcKj6lcqViUpkqJpUrFVdUpoqnVKaKSeVKxaRyqvgJlVPFpDJVnFSmiknlVPFbVD5RMancqTipPFUxqXyqYlI5VXxK5W+ouHKw1lovcbDWWi9xsNZaL/GHH6r4BpU7FU+pnCqmiknlKZWp4qTyKZWp4lMVV1Q+pTJVPKVyqphUrqhMFXdUThWTyt9QMamcKn5LxRWVKypTxaRyqrhT8Q0qTx2stdZLHKy11kv84f9B5amKn1A5VXxKZao4qUwVT1VMKlPFlYq/oWJSOalMFVPF31BxReVOxVMVV1SuqPxExRWVqe', '2026-02-17 16:21:08', '2026-02-17 16:23:07'),
('BILLET-1771850793154-CCE0ECC0', 'BIL-20260223-C8FA62', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-23 12:46:33', '2026-02-23 12:46:33'),
('BILLET-1771851091947-3A0B6128', 'BIL-20260223-D2ADEE', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-23 12:51:32', '2026-02-23 12:51:32'),
('BILLET-1771851139136-B0FB5A74', 'BIL-20260223-EF1EE1', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-23 12:52:19', '2026-02-23 12:52:19'),
('BILLET-1771851632741-CAEABB8C', 'BIL-20260223-F174E4', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-23 13:00:32', '2026-02-23 13:00:32'),
('BILLET-1771852100126-6A8E4A3E', 'BIL-20260223-0C0FF9', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-23 13:08:20', '2026-02-23 13:08:20'),
('BILLET-1771852551170-EDE92895', 'BIL-20260223-2414F9', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-23 13:15:51', '2026-02-23 13:15:51'),
('BILLET-1771852598122-BB56B266', 'BIL-20260223-645D7E', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'paye', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABkvSURBVO3BQXLkWLIgQTNI3v/KNrUJEd/wVYBBZjX+uKr9g7XWeoCLtdZ6iIu11nqIi7XWeoiLtdZ6iIu11nqIi7XWeoiLtdZ6iD/8C5W/qeJdKicVd6icVHxF5Y6KE5WTiheVn1Rxh8pvqfiEylTxFZWTik+ovKtiUpkqJpU7KiaVqeJF5W+q+MrFWms9xMVaaz3ExVprPcQfbqr4SSp/i8pPUbmj4kTlpGJSeamYVKaKE5U7VH5LxSdUpopJ5SsVf1PFi8pJxUnFpHJHxbsqfpLKuy7WWushLtZa6yEu1lrrIf7wIZU7Kr5LZao4UfktFZPKicpUMVWcqEwV36UyVZyoTBXvUjmpOFGZKiaVn6JyUnGiclIxqXyXylRxUvFbVO6o+K6LtdZ6iIu11nqIi7XWeo', '2026-02-23 13:16:38', '2026-02-23 13:17:55'),
('BILLET-1771868331317-E8A7AAD4', 'BIL-20260223-8FB947', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 3, 0, 11900, 'XAF', 'paye', 'actif', NULL, NULL, 'Brocantes: Brocante 1 (aw39ctwsPwVEeglxtDHs) | Brocante du Chateau / Angondje (p4EwhTLYgWtYNzJp3pcs)\nStands: stand0354 | 2*4m | 2900 | Brocante 1 ; stand04 | 2*4m | 4500 | Brocante du Chateau / Angondje ; stand03 | 1*2.5m | 4500 | Brocante du Chateau / Angondje', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABkjSURBVO3BQW4k15IAQfcE739lH20IxKaeKlns1s9BmNk/WGutB7hYa62HuFhrrYe4WGuth7hYa62HuFhrrYe4WGuth7hYa62H+OJfqPxNFX+Kyh0Vk8q3ijtUPlExqbxScaIyVUwqU8WkMlVMKt8qTlSmikllqphU/pSKSWWqmFTuqPgplZOKSWWqmFSmim8qf1PFKxdrrfUQF2ut9RAXa631EF/cVPGbVH5KZaqYVKaKSeVE5adUTiruUHmlYlL5RMUnKl5R+YTKHRWTyreKSWVSmSpOKiaVqWJSeaXib6p4V8VvUnnXxVprPcTFWms9xMVaaz3EFx9SuaPiXSpTxVRxUjGpnFRMKlPFN5U7KiaVqWJSOan4pnJS8QmVqeJE5X+FyisqU8WkcqJyh8q7VKaKO1', '2026-02-23 17:38:51', '2026-02-23 17:54:58'),
('BILLET-1771920142794-7BD9F0E5', 'BIL-20260224-10D907', 'EV-BROCANTE-2026-001', 'CAT-BROCANTE-2026-STAND', NULL, 'samira', 'Kananga', 'client1@gmail.com', '077001255', 1, 0, 7900, 'XAF', 'paye', 'actif', NULL, NULL, 'Brocantes: Brocante Homme beaux (pV3lRxYrJzQOEH1nVVX2)\nStands: StandA10 | 2*3 | 7900 | Brocante Homme beaux', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABksSURBVO3BQW4c2ZIAQfeE7n9lH20IxKZeV5Il6ecgzOw31lrrAS7WWushLtZa6yEu1lrrIS7WWushLtZa6yEu1lrrIS7WWushfvEfVP6mii8qU8VPqNxRMal8qbhD5ScqJpVXKk5UpopJZaqYVKaKSeVLxYnKVDGpTBWTyp9SMalMFZPKHRXfpXJSMalMFZPKVPFF5W+qeOVirbUe4mKttR7iYq21HuIXN1V8ksorFScqU8WkclIxqUwq71KZKqaKT6p4ReUOlU+q+KIyVfyEylRxh8qXiknlJyomlX9F5Y6Kd1V8ksq7LtZa6yEu1lrrIS7WWushfvFDKndUvEvlJypOVKaKd6lMFZPKVHGHylTxispUcYfKVDGp3KHypeIOlZ9QOan4ojJVnFRMKlPFd6l8Us', '2026-02-24 08:02:21', '2026-02-24 08:04:43'),
('BILLET-1772037052478-F4B72C35', 'BIL-20260225-4D52B5', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 16:30:52', '2026-02-25 16:30:52'),
('BILLET-1772037805007-80CB5578', 'BIL-20260225-257060', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 16:43:25', '2026-02-25 16:43:25'),
('BILLET-1772039107707-02A86E28', 'BIL-20260225-3177E1', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 17:05:07', '2026-02-25 17:05:07'),
('BILLET-1772039117855-CBEF4DF5', 'BIL-20260225-4FD8D9', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 17:05:18', '2026-02-25 17:05:18'),
('BILLET-1772039399806-66348B05', 'BIL-20260225-DD77B3', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 17:10:00', '2026-02-25 17:10:00'),
('BILLET-1772039418405-660AF650', 'BIL-20260225-1C2C86', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 17:10:18', '2026-02-25 17:10:18'),
('BILLET-1772039428293-D612DB6C', 'BIL-20260225-D2C10D', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 17:10:28', '2026-02-25 17:10:28'),
('BILLET-1772039433094-4830FF5F', 'BIL-20260225-CE3479', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'en_attente', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-25 17:10:33', '2026-02-25 17:10:33'),
('BILLET-1772039593244-9A13234B', 'BIL-20260225-AFBF5B', 'EV-SHAINA-SMARTAPP-001', 'CAT-SHAINA-STANDARD', 'xgTJC59LK7ThpADJMb7ZywL5FHi2', 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '', 1, 3500, 3500, 'XOF', 'paye', 'actif', NULL, NULL, 'submissionId=QCMRBF75GQhWdizEe3hI; documentType=pdf; style=simple; level=licence; operator=airtel', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABkcSURBVO3BQW4kRxIAQffC/P/LvroQiEunusjmrAoIM/sHa631ABdrrfUQF2ut9RAXa631EBdrrfUQF2ut9RAXa631EBdrrfUQf/gXKn9TxReVqWJS+aSKd6lMFScqP1HxispJxaRyR8WkMlVMKq9U3KEyVfyEypeKO1SmiknlpGJSeVfFpHJSMalMFZPKVPFF5W+qeOVirbUe4mKttR7iYq21HuIPN1V8ksorFScVJyp3qLyrYlI5qfhbKiaVqWJS+aSKd6mcVNyh8l0qU8UdFZPKpDJVfFGZKn5C5Y6Kd1V8ksq7LtZa6yEu1lrrIS7WWush/vBDKndUvEvljoqpYlKZKiaV76qYVCaVk4pJ5aTiS8VJxR0VP6HySsVUMamcqJxUTCpTxSsVJxWTylQxVbyr4k', '2026-02-25 17:13:13', '2026-02-25 18:30:20'),
('BILLET-1772304350663-C53BE243', 'BIL-20260228-CFEFCB', 'EV-WEDDING-PLANNER-2026', 'CAT-WEDDING-2026-INVITE', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 60000, 60000, 'XAF', 'en_attente', 'actif', NULL, NULL, 'Couple: sophie & rjg \nDate mariage: 7 mars 2026\nLieu: hj ev\nOffre: Faire-part + gestion invite', NULL, NULL, 0.00, 'site_web', NULL, NULL, '2026-02-28 18:45:50', '2026-02-28 18:45:50'),
('BILLET-1772304591960-B5E2BB4D', 'BIL-20260228-2459A4', 'EV-WEDDING-PLANNER-2026', 'CAT-WEDDING-2026-INVITE', NULL, 'SAGOUNAMA-MENSAH', 'Emmanuel', 'smebedoh33@gmail.com', '077679339', 1, 60000, 60000, 'XAF', 'paye', 'actif', NULL, NULL, 'Couple: sophie & rjg \nDate mariage: 7 mars 2026\nLieu: hj ev\nOffre: Faire-part + gestion invite', NULL, NULL, 0.00, 'site_web', NULL, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASwAAAEsCAYAAAB5fY51AAAAAklEQVR4AewaftIAABu3SURBVO3BQa7c2LIgQfeE9r9l75oQiMlhUfmvVI/oMLN/sNZaL/BhrbVe4sNaa73Eh7XWeokPa631Eh/WWuslPqy11kt8WGutl/jFv1D5GyqeUjmpeEplqphUTiomlaniROW/VnFHZao4UZkqTlSmihOVpyomlZOKp1Smijsql4pJZaq4qNypOFF5quJbKn9DxcmHtdZ6iQ9rrfUSH9Za6yV+8ZsqfoLKtypOVKaKSeVE5U7FUyqXiqnib1CZKr6lclIxqTylclLxlMpUcaIyVZxUTCpTxd+gMlVcKp5SmSomlUvFnYqfoPLUh7XWeokPa631Er/4P1B5quJbKk9VTConFXdUJpVLxVQxqZyofKtiUrlUPKXyOypOVKaKn6AyVUwqT6n8DRVPqVwq7qicqEwVJx', '2026-02-28 18:49:52', '2026-02-28 18:51:28');

-- --------------------------------------------------------

--
-- Structure de la table `rotary_billets_categories`
--

CREATE TABLE `rotary_billets_categories` (
  `id` varchar(50) NOT NULL,
  `evenement_id` varchar(50) NOT NULL,
  `nom_categorie` varchar(100) NOT NULL COMMENT 'Ex: VIP, Standard, Etudiant, Membre, Invité',
  `description` text DEFAULT NULL,
  `prix_unitaire` decimal(12,0) UNSIGNED NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'XAF',
  `quantite_disponible` int(11) UNSIGNED DEFAULT NULL COMMENT 'NULL = illimité',
  `quantite_vendue` int(11) UNSIGNED DEFAULT 0,
  `ordre_affichage` int(11) DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `couleur_badge` varchar(20) DEFAULT NULL COMMENT 'Pour UI (ex: gold, silver, bronze)',
  `avantages` text DEFAULT NULL COMMENT 'Liste des avantages de cette catégorie',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rotary_billets_categories`
--

INSERT INTO `rotary_billets_categories` (`id`, `evenement_id`, `nom_categorie`, `description`, `prix_unitaire`, `currency_code`, `quantite_disponible`, `quantite_vendue`, `ordre_affichage`, `is_active`, `couleur_badge`, `avantages`, `created_at`, `updated_at`) VALUES
('CAT-BROCANTE-2026-STAND', 'EV-BROCANTE-2026-001', 'Stand Brocante', 'Paiement des stands brocante', 0, 'XAF', NULL, 19, 1, 1, 'gold', 'Stand standard', '2026-02-18 23:18:24', '2026-02-24 08:04:42'),
('CAT-FORUM-2026-3RIVIERES', 'EV-ROTARY-FORUM-2026', 'Excursion 3 Rivières', 'Activité optionnelle - Découverte des 3 Rivières', 30000, 'XAF', 100, 0, 4, 1, 'orange', 'Transport, guide, déjeuner et visite guidée des 3 Rivières inclus', '2026-01-16 18:43:02', '2026-02-17 16:09:57'),
('CAT-FORUM-2026-EXCURSION', 'EV-ROTARY-FORUM-2026', 'Excursion Omboué', 'Activité optionnelle - Découverte d\'Omboué', 30000, 'XAF', 100, 0, 4, 1, 'orange', 'Transport, guide, déjeuner et visite guidée d\'Omboué inclus', '2026-01-16 18:43:02', '2026-01-27 14:25:32'),
('CAT-FORUM-2026-INVITE', 'EV-ROTARY-FORUM-2026', 'Invité', 'Tarif pour les invités et non-membres', 35000, 'XAF', 150, 0, 3, 1, 'silver', 'Accès à toutes les conférences, ateliers, pauses café, déjeuners et soirée de gala', '2026-01-16 18:43:02', '2026-01-27 14:25:41'),
('CAT-FORUM-2026-POG-TOUR', 'EV-ROTARY-FORUM-2026', 'POG TOUR', 'Activité optionnelle - Visite guidée de Port-Gentil', 20000, 'XAF', 100, 0, 5, 1, 'purple', 'Transport, guide et visite des sites touristiques de Port-Gentil', '2026-01-16 18:43:02', '2026-01-27 14:25:58'),
('CAT-FORUM-2026-ROTARACTIEN', 'EV-ROTARY-FORUM-2026', 'Rotaractien', 'Tarif réduit pour les membres Rotaract', 30000, 'XAF', 150, 7, 2, 1, 'green', 'Accès à toutes les conférences, ateliers, pauses café, déjeuners et soirée de gala', '2026-01-16 18:43:02', '2026-01-27 14:26:15'),
('CAT-FORUM-2026-ROTARIEN', 'EV-ROTARY-FORUM-2026', 'Rotarien', 'Tarif pour les membres Rotary - Accès complet au forum', 40000, 'XAF', 200, 13, 1, 1, 'blue', 'Accès à toutes les conférences, ateliers, pauses café, déjeuners et soirée de gala', '2026-01-16 18:43:02', '2026-02-17 16:23:07'),
('CAT-FORUM-2026-TEST', 'EV-ROTARY-FORUM-2026', 'Test', 'Activité optionnelle - Découverte d\'Omboué', 300, 'XAF', 100, 0, 4, 1, 'orange', 'Transport, guide, déjeuner et visite guidée d\'Omboué inclus', '2026-01-16 18:43:02', '2026-01-27 14:25:32'),
('CAT-SHAINA-BASIC', 'EV-SHAINA-SMARTAPP-001', 'Basique', 'Pack Basique Shaina', 2500, 'XOF', NULL, 0, 1, 1, 'bronze', '{\"features\":[\"Resume structure\",\"Format PDF simple\",\"Livraison en 48h\",\"Support email\"],\"documentTypes\":[\"resume\"],\"popular\":false}', '2026-02-25 15:59:43', '2026-02-25 15:59:43'),
('CAT-SHAINA-PREMIUM', 'EV-SHAINA-SMARTAPP-001', 'Premium', 'Pack Premium Shaina', 5000, 'XOF', NULL, 0, 3, 1, 'gold', '{\"features\":[\"Presentation PowerPoint\",\"Design personnalise\",\"Livraison en 12h\",\"Support 24/7\",\"2 revisions incluses\",\"Export multi-formats\"],\"documentTypes\":[\"expose\",\"pdf\",\"resume\"],\"popular\":false}', '2026-02-25 15:59:43', '2026-02-25 15:59:43'),
('CAT-SHAINA-STANDARD', 'EV-SHAINA-SMARTAPP-001', 'Standard', 'Pack Standard Shaina', 3500, 'XOF', NULL, 1, 2, 1, 'silver', '{\"features\":[\"Document PDF academique\",\"Mise en page professionnelle\",\"Livraison en 24h\",\"Support prioritaire\",\"Revision incluse\"],\"documentTypes\":[\"pdf\",\"resume\"],\"popular\":true}', '2026-02-25 15:59:43', '2026-02-25 18:30:19'),
('CAT-WEDDING-2026-INVITE', 'EV-WEDDING-PLANNER-2026', 'Faire-part  gestion invite', '60 000 XAF - Offre simple  gestion des invites et RSVP.', 60000, 'XAF', NULL, 1, 2, 1, 'green', 'Pack simple, gestion invites, suivi RSVP', '2026-02-28 17:44:00', '2026-02-28 18:51:27'),
('CAT-WEDDING-2026-PREMIUM', 'EV-WEDDING-PLANNER-2026', 'Gestion mariage  billets generes', '90 000 XAF - Offre complete avec generation de billets.', 90000, 'XAF', NULL, 0, 3, 1, 'gold', 'Pack invite, gestion complete mariage, billets generes', '2026-02-28 17:44:00', '2026-02-28 17:44:00'),
('CAT-WEDDING-2026-SIMPLE', 'EV-WEDDING-PLANNER-2026', 'Simple faire-part', '49 000 XAF - Creation du faire-part digital et page mariage de base.', 49000, 'XAF', NULL, 0, 1, 1, 'blue', 'Faire-part digital, design elegant, lien de partage', '2026-02-28 17:44:00', '2026-02-28 17:44:00');

-- --------------------------------------------------------

--
-- Structure de la table `rotary_codes_promo`
--

CREATE TABLE `rotary_codes_promo` (
  `id` varchar(50) NOT NULL,
  `code` varchar(50) NOT NULL,
  `evenement_id` varchar(50) DEFAULT NULL COMMENT 'NULL = valable pour tous les événements',
  `type_reduction` enum('pourcentage','montant_fixe') NOT NULL DEFAULT 'pourcentage',
  `valeur_reduction` decimal(10,2) UNSIGNED NOT NULL,
  `date_debut` datetime NOT NULL,
  `date_fin` datetime NOT NULL,
  `utilisation_max` int(11) UNSIGNED DEFAULT NULL COMMENT 'NULL = illimité',
  `utilisation_actuelle` int(11) UNSIGNED DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `description` varchar(255) DEFAULT NULL,
  `created_by_user_id` varchar(128) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rotary_codes_promo`
--

INSERT INTO `rotary_codes_promo` (`id`, `code`, `evenement_id`, `type_reduction`, `valeur_reduction`, `date_debut`, `date_fin`, `utilisation_max`, `utilisation_actuelle`, `is_active`, `description`, `created_by_user_id`, `created_at`, `updated_at`) VALUES
('PROMO-FORUM-2026-EARLY', 'EARLYBIRD2026', 'EV-ROTARY-FORUM-2026', 'pourcentage', 10.00, '2026-01-16 00:00:00', '2026-02-01 23:59:59', 50, 0, 1, 'Réduction early bird - 10% pour les inscriptions anticipées', NULL, '2026-01-16 18:43:02', '2026-01-16 18:43:02'),
('PROMO-FORUM-2026-GROUPE', 'GROUPE2026', 'EV-ROTARY-FORUM-2026', 'montant_fixe', 5000.00, '2026-01-16 00:00:00', '2026-02-15 23:59:59', 100, 0, 1, 'Réduction groupe - 5000 FCFA de réduction pour les inscriptions groupées', NULL, '2026-01-16 18:43:02', '2026-01-16 18:43:02');

-- --------------------------------------------------------

--
-- Structure de la table `rotary_email_logs`
--

CREATE TABLE `rotary_email_logs` (
  `id` varchar(50) NOT NULL,
  `billet_id` varchar(50) DEFAULT NULL,
  `transaction_id` varchar(50) DEFAULT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `email_type` enum('confirmation_achat','billet_envoye','rappel_evenement','annulation','remboursement') NOT NULL,
  `subject` varchar(255) NOT NULL,
  `sent_at` datetime DEFAULT NULL,
  `statut` enum('pending','sent','failed') NOT NULL DEFAULT 'pending',
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rotary_email_logs`
--

INSERT INTO `rotary_email_logs` (`id`, `billet_id`, `transaction_id`, `recipient_email`, `email_type`, `subject`, `sent_at`, `statut`, `error_message`, `created_at`) VALUES
('EMAIL-1768661046837-F11AEF73', 'BILLET-1768647916956-073FA56D', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 14:44:12', 'sent', NULL, '2026-01-17 14:44:12'),
('EMAIL-1768665045358-AC3ACB55', 'BILLET-1768647916956-073FA56D', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 15:50:50', 'sent', NULL, '2026-01-17 15:50:50'),
('EMAIL-1768666767443-9BD13355', 'BILLET-1768666033821-6D283451', NULL, 'sarahnzamba5@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 16:19:32', 'sent', NULL, '2026-01-17 16:19:32'),
('EMAIL-1768668348191-337D19E1', 'BILLET-1768615543858-76F97056', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 16:45:53', 'sent', NULL, '2026-01-17 16:45:53'),
('EMAIL-1768668666088-DC67A299', 'BILLET-1768666033821-6D283451', NULL, 'sarahnzamba5@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 16:51:11', 'sent', NULL, '2026-01-17 16:51:11'),
('EMAIL-1768669432151-C8AEB3AD', 'BILLET-1768669344398-249D3DFB', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 17:03:57', 'sent', NULL, '2026-01-17 17:03:57'),
('EMAIL-1768669588596-C2B48992', 'BILLET-1768669344398-249D3DFB', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 17:06:33', 'sent', NULL, '2026-01-17 17:06:33'),
('EMAIL-1768673621689-3761F968', 'BILLET-1768673573668-5B22E980', NULL, 'consultant@axelmbinah.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 18:13:47', 'sent', NULL, '2026-01-17 18:13:47'),
('EMAIL-1768674552297-BDB6787C', 'BILLET-1768674437687-C3D2D624', NULL, 'laure.rekoula@yahoo.fr', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 18:29:17', 'sent', NULL, '2026-01-17 18:29:17'),
('EMAIL-1768674729288-4C7A1455', 'BILLET-1768674685487-EF3EBF20', NULL, 'jpmahady@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 18:32:14', 'sent', NULL, '2026-01-17 18:32:14'),
('EMAIL-1768675369399-76127DB4', 'BILLET-1768675314198-A967FE55', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-17 18:42:54', 'sent', NULL, '2026-01-17 18:42:54'),
('EMAIL-1768847731789-4A53F9EF', 'BILLET-1768847652725-7290010D', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-19 18:35:37', 'sent', NULL, '2026-01-19 18:35:37'),
('EMAIL-1768847815798-B78088F3', 'BILLET-1768847652725-7290010D', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-19 18:37:01', 'sent', NULL, '2026-01-19 18:37:01'),
('EMAIL-1768847978560-0AD24063', 'BILLET-1768674437687-C3D2D624', NULL, 'laure.rekoula@yahoo.fr', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-19 18:39:44', 'sent', NULL, '2026-01-19 18:39:44'),
('EMAIL-1769521192530-71E43BF9', 'BILLET-1769520830505-AC68E673', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-01-27 13:39:59', 'sent', NULL, '2026-01-27 13:39:59'),
('EMAIL-1770464449845-0946C5AE', 'BILLET-1770464401643-6F9C49C1', NULL, 'jpmahady@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-02-07 11:40:58', 'sent', NULL, '2026-02-07 11:40:58'),
('EMAIL-1770620836435-FD410210', 'BILLET-1770620748982-7FB08788', NULL, 'sylgabamh@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-02-09 07:07:24', 'sent', NULL, '2026-02-09 07:07:24'),
('EMAIL-1771345379374-C28AE547', 'BILLET-1771345258747-23A13635', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour 22ème Forum des Clubs Rotary - Port-Gentil 2026', '2026-02-17 16:23:09', 'sent', NULL, '2026-02-17 16:23:09'),
('EMAIL-1771852676348-DD420183', 'BILLET-1771852598122-BB56B266', NULL, 'client1@gmail.com', 'billet_envoye', 'Votre inscription - Ouverture des Brocantes Solidaires', '2026-02-23 13:17:56', 'sent', NULL, '2026-02-23 13:17:56'),
('EMAIL-1771869298965-07C89FEF', 'BILLET-1771868331317-E8A7AAD4', NULL, 'client1@gmail.com', 'billet_envoye', 'Votre inscription - Ouverture des Brocantes Solidaires', '2026-02-23 17:54:59', 'sent', NULL, '2026-02-23 17:54:59'),
('EMAIL-1771920284633-D24F44D0', 'BILLET-1771920142794-7BD9F0E5', NULL, 'client1@gmail.com', 'billet_envoye', 'Votre inscription - Ouverture des Brocantes Solidaires', '2026-02-24 08:04:44', 'sent', NULL, '2026-02-24 08:04:44'),
('EMAIL-1772044222340-BE51A7A5', 'BILLET-1772039593244-9A13234B', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour Shaina Smart App - Commandes de documents', '2026-02-25 18:30:22', 'sent', NULL, '2026-02-25 18:30:22'),
('EMAIL-1772304689592-C5D491D4', 'BILLET-1772304591960-B5E2BB4D', NULL, 'smebedoh33@gmail.com', 'billet_envoye', '✅ Votre billet pour Wedding Planner AFUP - Offres mariage', '2026-02-28 18:51:29', 'sent', NULL, '2026-02-28 18:51:29');

-- --------------------------------------------------------

--
-- Structure de la table `rotary_evenements`
--

CREATE TABLE `rotary_evenements` (
  `id` varchar(50) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `type_evenement` enum('conference','gala','formation','collecte_fonds','activite_sociale','reunion','autres') NOT NULL DEFAULT 'conference',
  `date_evenement` datetime NOT NULL,
  `date_fin_evenement` datetime DEFAULT NULL,
  `lieu` varchar(255) DEFAULT NULL,
  `adresse_complete` text DEFAULT NULL,
  `capacite_max` int(11) UNSIGNED DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `organisateur_nom` varchar(255) DEFAULT NULL,
  `organisateur_email` varchar(255) DEFAULT NULL,
  `organisateur_telephone` varchar(20) DEFAULT NULL,
  `statut` enum('brouillon','publie','complet','annule','termine') NOT NULL DEFAULT 'brouillon',
  `date_limite_inscription` datetime DEFAULT NULL,
  `is_payant` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by_user_id` varchar(128) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rotary_evenements`
--

INSERT INTO `rotary_evenements` (`id`, `titre`, `description`, `type_evenement`, `date_evenement`, `date_fin_evenement`, `lieu`, `adresse_complete`, `capacite_max`, `image_url`, `organisateur_nom`, `organisateur_email`, `organisateur_telephone`, `statut`, `date_limite_inscription`, `is_payant`, `created_at`, `updated_at`, `created_by_user_id`) VALUES
('EV-BROCANTE-2026-001', 'Ouverture des Brocantes Solidaires', 'Rejoignez-nous pour la grande ouverture de la saison des brocantes.', '', '2026-02-15 08:00:00', '2026-02-15 18:00:00', 'Place de la Mairie', '12 rue de la Paix, Gabon', 200, NULL, 'Tout les commercants', NULL, NULL, 'publie', NULL, 0, '2026-02-14 17:10:15', '2026-02-18 16:34:32', NULL),
('EV-ROTARY-FORUM-2026', '22ème Forum des Clubs Rotary - Port-Gentil 2026', 'Unis pour Faire le Bien et Donner du Bonheur Ensemble et Autrement. Rejoignez-nous pour trois jours d\'enrichissement avec conférences, ateliers et excursion à Omboué.', 'conference', '2026-02-20 09:00:00', '2026-02-22 18:00:00', 'Canal Olympia', 'Canal Olympia, Port-Gentil, Gabon', 500, '/un-etudiant-en-medecine-noir-en-peignoir-fait-des-recherches-et-prend-des-notes-pour-sa-these.jpg', 'Rotary Club Port-Gentil', 'contact@rotaryportgentil.ga', '+241 XX XX XX XX', 'publie', '2026-02-15 23:59:59', 1, '2026-01-16 18:43:02', '2026-01-16 18:43:02', NULL),
('EV-SHAINA-SMARTAPP-001', 'Shaina Smart App - Commandes de documents', 'Paiement des packs Basique/Standard/Premium pour generation de documents.', 'autres', '2099-12-31 23:59:59', NULL, 'En ligne', 'Service digital', NULL, NULL, 'Shaina Smart', 'support@shainasmart.app', NULL, 'publie', NULL, 1, '2026-02-25 15:59:43', '2026-02-25 15:59:43', 'system'),
('EV-WEDDING-PLANNER-2026', 'Wedding Planner AFUP - Offres mariage', 'Achat des offres Wedding Planner: simple faire-part, gestion invite et gestion mariage complete.', 'autres', '2099-12-31 10:00:00', '2099-12-31 18:00:00', 'En ligne', 'Service digital', NULL, NULL, 'AFUP Wedding Planner', NULL, NULL, 'publie', '2099-12-30 23:59:59', 1, '2026-02-28 17:44:00', '2026-02-28 17:44:00', NULL);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `rotary_stats_evenements`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `rotary_stats_evenements` (
`evenement_id` varchar(50)
,`titre` varchar(255)
,`date_evenement` datetime
,`statut` enum('brouillon','publie','complet','annule','termine')
,`capacite_max` int(11) unsigned
,`total_billets` bigint(21)
,`total_places_vendues` decimal(33,0)
,`places_payees` decimal(33,0)
,`revenus_total` decimal(34,0)
,`participants_uniques` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure de la table `rotary_transactions`
--

CREATE TABLE `rotary_transactions` (
  `id` varchar(50) NOT NULL,
  `billet_id` varchar(50) NOT NULL,
  `evenement_id` varchar(50) NOT NULL,
  `bill_id` varchar(100) DEFAULT NULL COMMENT 'ID de la facture Ebilling',
  `external_reference` varchar(100) DEFAULT NULL COMMENT 'Référence externe de paiement',
  `transaction_id` varchar(100) DEFAULT NULL COMMENT 'ID de transaction du provider',
  `montant` decimal(12,2) UNSIGNED NOT NULL,
  `currency_code` char(3) NOT NULL DEFAULT 'XOF',
  `statut` enum('pending','success','failed','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL COMMENT 'mobile_money, carte, virement, especes',
  `payment_provider` varchar(50) DEFAULT 'ebilling' COMMENT 'ebilling, shap, autre',
  `payer_name` varchar(255) DEFAULT NULL,
  `payer_email` varchar(255) DEFAULT NULL,
  `payer_msisdn` varchar(20) DEFAULT NULL,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Détails du paiement (webhook data)' CHECK (json_valid(`payment_details`)),
  `webhook_received_at` datetime DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `refund_reason` text DEFAULT NULL,
  `refund_amount` decimal(12,2) DEFAULT NULL,
  `refund_date` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `rotary_transactions`
--

INSERT INTO `rotary_transactions` (`id`, `billet_id`, `evenement_id`, `bill_id`, `external_reference`, `transaction_id`, `montant`, `currency_code`, `statut`, `payment_method`, `payment_provider`, `payer_name`, `payer_email`, `payer_msisdn`, `payment_details`, `webhook_received_at`, `error_message`, `refund_reason`, `refund_amount`, `refund_date`, `created_at`, `updated_at`) VALUES
('TRANS-1768589720929-FC9C8840', 'BILLET-1768589720921-8C59CBC1', 'EV-ROTARY-FORUM-2026', '5550057506', 'REF-ROTARY-B71D3EF6E435', '5550057506', 40000.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-16 18:55:26', '2026-01-16 18:55:27'),
('TRANS-1768590401602-2E017ADC', 'BILLET-1768590401600-1A3EEFED', 'EV-ROTARY-FORUM-2026', '5550057507', 'REF-ROTARY-FBAF3B6A81BB', '5550057507', 40000.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-16 19:06:47', '2026-01-16 19:06:48'),
('TRANS-1768590543448-3B3C1940', 'BILLET-1768590543448-A9EA4016', 'EV-ROTARY-FORUM-2026', '5550057508', 'REF-ROTARY-244CB17DDE53', '5550057508', 40000.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-16 19:09:08', '2026-01-16 19:09:09'),
('TRANS-1768590859473-CF11C24D', 'BILLET-1768590859471-E65C9213', 'EV-ROTARY-FORUM-2026', '5550057509', 'REF-ROTARY-0BF243523D51', '5550057509', 40000.00, 'XOF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057509\",\"merchantid\":\"smeby33\",\"customerid\":\"074447714\",\"transactionid\":\"kxm2Zc4qZE4Ps6v\",\"reference\":\"REF-ROTARY-0BF243523D51\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"40000.0\",\"40000\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-16 20:14:20 +0100\",\"state\":\"paid\"}', '2026-01-17 02:51:53', NULL, NULL, NULL, NULL, '2026-01-16 19:14:24', '2026-01-17 02:51:53'),
('TRANS-1768591253676-F1503DCC', 'BILLET-1768591253664-B3196AE5', 'EV-ROTARY-FORUM-2026', '5550057510', 'REF-ROTARY-10FE6845C241', '5550057510', 30000.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-16 19:21:01', '2026-01-16 19:21:02'),
('TRANS-1768591277854-F4FB1371', 'BILLET-1768591277854-7CB38B87', 'EV-ROTARY-FORUM-2026', '5550057511', 'REF-ROTARY-DFDDE77D9A14', '5550057511', 30000.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-16 19:21:23', '2026-01-16 19:21:24'),
('TRANS-1768591345210-7F263113', 'BILLET-1768591345210-808DBA58', 'EV-ROTARY-FORUM-2026', '5550057512', 'REF-ROTARY-A8FB252D94D8', '5550057512', 30000.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-16 19:22:30', '2026-01-16 19:22:31'),
('TRANS-1768615543869-57B268C3', 'BILLET-1768615543858-76F97056', 'EV-ROTARY-FORUM-2026', '5550057513', 'REF-ROTARY-725959D035B3', '5550057513', 30000.00, 'XOF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057513\",\"merchantid\":\"smeby33\",\"customerid\":\"+24177679339\",\"transactionid\":\"ydacTEgrZpSHqJq\",\"reference\":\"REF-ROTARY-725959D035B3\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"30000.0\",\"30000\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotaractien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-17 03:05:45 +0100\",\"state\":\"paid\"}', '2026-01-17 02:46:44', NULL, NULL, NULL, NULL, '2026-01-17 02:05:49', '2026-01-17 02:46:44'),
('TRANS-1768647916957-2C3B6E14', 'BILLET-1768647916956-073FA56D', 'EV-ROTARY-FORUM-2026', '5550057531', 'REF-ROTARY-44856996D506', '5550057531', 30000.00, 'XOF', 'success', 'tmoney', 'ebilling', 'Smeb Edoh', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057531\",\"reference\":\"5550057531\",\"state\":\"paid\",\"amount\":\"30000\",\"paymentsystem\":\"tmoney\",\"timestamp\":\"2026-01-17T15:50:41.137Z\"}', '2026-01-17 15:50:46', NULL, NULL, NULL, NULL, '2026-01-17 11:05:22', '2026-01-17 15:50:46'),
('TRANS-1768661835968-B7411610', 'BILLET-1768661835954-E878BF16', 'EV-ROTARY-FORUM-2026', '5550057539', 'REF-ROTARY-ED2C7D3F271C', '5550057539', 30000.00, 'XOF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057539\",\"merchantid\":\"smeby33\",\"customerid\":\"+24177679339\",\"transactionid\":\"Fq5ixMB4ZRTXHcs\",\"reference\":\"REF-ROTARY-ED2C7D3F271C\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"30000.0\",\"30000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotaractien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-17 15:57:17 +0100\",\"state\":\"paid\"}', '2026-01-17 14:59:05', NULL, NULL, NULL, NULL, '2026-01-17 14:57:21', '2026-01-17 14:59:05'),
('TRANS-1768663861620-3BE8505E', 'BILLET-1768663861612-71A33A11', 'EV-ROTARY-FORUM-2026', '5550057540', 'REF-ROTARY-284D992A087F', '5550057540', 40000.00, 'XOF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel SAGOUNAMA-MENSAH Emmanuel ', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057540\",\"merchantid\":\"smeby33\",\"customerid\":\"+24177679339\",\"transactionid\":\"uamYrlZQ2HPrwwL\",\"reference\":\"REF-ROTARY-284D992A087F\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"40000.0\",\"40000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel SAGOUNAMA-MENSAH Emmanuel \",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-17 16:31:02 +0100\",\"state\":\"paid\"}', '2026-01-17 15:33:12', NULL, NULL, NULL, NULL, '2026-01-17 15:31:07', '2026-01-17 15:33:12'),
('TRANS-1768664690712-46F50FA1', 'BILLET-1768664690678-194B6EDC', 'EV-ROTARY-FORUM-2026', '5550057541', 'REF-ROTARY-C12F7C138A23', '5550057541', 70000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057541\",\"merchantid\":\"smeby33\",\"customerid\":\"+24177679339\",\"transactionid\":\"JLEn3eD4QGd3Flz\",\"reference\":\"REF-ROTARY-C12F7C138A23\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"70000.0\",\"70000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-17 16:44:51 +0100\",\"state\":\"paid\"}', '2026-01-17 15:46:31', NULL, NULL, NULL, NULL, '2026-01-17 15:44:56', '2026-01-17 15:46:31'),
('TRANS-1768666033838-DDAB5824', 'BILLET-1768666033821-6D283451', 'EV-ROTARY-FORUM-2026', '5550057542', 'REF-ROTARY-D9BF57602D64', '5550057542', 60000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'sarahnzamba5@gmail.com', '+24177679339', '{\"billingid\":\"5550057542\",\"merchantid\":\"smeby33\",\"customerid\":\"076588912\",\"transactionid\":\"UmcHZYolZBJ4cKb\",\"reference\":\"REF-ROTARY-D9BF57602D64\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"60000.0\",\"60000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotaractien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"sarahnzamba5@gmail.com\",\"createdat\":\"2026-01-17 17:07:15 +0100\",\"state\":\"paid\"}', '2026-01-17 16:10:02', NULL, NULL, NULL, NULL, '2026-01-17 16:07:19', '2026-01-17 16:10:02'),
('TRANS-1768669344409-807EA1BB', 'BILLET-1768669344398-249D3DFB', 'EV-ROTARY-FORUM-2026', '5550057543', 'REF-ROTARY-C14DD1A5D979', '5550057543', 70000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057543\",\"merchantid\":\"smeby33\",\"customerid\":\"+24177679339\",\"transactionid\":\"0jHyA6zg8WwWZ5w\",\"reference\":\"REF-ROTARY-C14DD1A5D979\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"70000.0\",\"70000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-17 18:02:25 +0100\",\"state\":\"paid\"}', '2026-01-17 17:03:21', NULL, NULL, NULL, NULL, '2026-01-17 17:02:29', '2026-01-17 17:03:21'),
('TRANS-1768673573668-DFAC68F4', 'BILLET-1768673573668-5B22E980', 'EV-ROTARY-FORUM-2026', '5550057544', 'REF-ROTARY-A3BFBFB2867A', '5550057544', 70000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'Axel MBINAH', 'consultant@axelmbinah.com', '074721325', '{\"billingid\":\"5550057544\",\"merchantid\":\"smeby33\",\"customerid\":\"074721325\",\"transactionid\":\"LgoTVZYLsnNtM3H\",\"reference\":\"REF-ROTARY-A3BFBFB2867A\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"70000.0\",\"70000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"Axel MBINAH\",\"payeremail\":\"consultant@axelmbinah.com\",\"createdat\":\"2026-01-17 19:12:53 +0100\",\"state\":\"paid\"}', '2026-01-17 18:13:44', NULL, NULL, NULL, NULL, '2026-01-17 18:12:59', '2026-01-17 18:13:44'),
('TRANS-1768673765323-B3DEECFC', 'BILLET-1768673765322-82F6F8BF', 'EV-ROTARY-FORUM-2026', NULL, 'REF-ROTARY-43B448B1331C', NULL, 70000.00, 'XAF', 'pending', NULL, 'ebilling', 'Laure REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 077 36 00 85', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-17 18:16:10', '2026-01-17 18:16:10'),
('TRANS-1768673784821-ED942441', 'BILLET-1768673784821-272BF7BD', 'EV-ROTARY-FORUM-2026', NULL, 'REF-ROTARY-D459881BC528', NULL, 70000.00, 'XAF', 'pending', NULL, 'ebilling', 'Laure REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 077 36 00 85', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-17 18:16:30', '2026-01-17 18:16:30'),
('TRANS-1768673983589-92D093E9', 'BILLET-1768673983589-84B81E54', 'EV-ROTARY-FORUM-2026', NULL, 'REF-ROTARY-3052E74F27FA', NULL, 70000.00, 'XAF', 'pending', NULL, 'ebilling', 'Laure REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 077360085', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-17 18:19:49', '2026-01-17 18:19:49'),
('TRANS-1768674028784-9826D111', 'BILLET-1768674028784-F60A785F', 'EV-ROTARY-FORUM-2026', NULL, 'REF-ROTARY-7831547160D0', NULL, 70000.00, 'XAF', 'pending', NULL, 'ebilling', 'Laure REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', ' 241077360085', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-17 18:20:34', '2026-01-17 18:20:34'),
('TRANS-1768674437687-99E41667', 'BILLET-1768674437687-C3D2D624', 'EV-ROTARY-FORUM-2026', '5550057545', 'REF-ROTARY-DD815D21A49B', '5550057545', 70000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'Laure REKOULA AVEROMA', 'laure.rekoula@yahoo.fr', '077360085', '{\"billingid\":\"5550057545\",\"merchantid\":\"smeby33\",\"customerid\":\"077360085\",\"transactionid\":\"y1V8AbAaHMWmls4\",\"reference\":\"REF-ROTARY-DD815D21A49B\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"70000.0\",\"70000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"Laure REKOULA AVEROMA\",\"payeremail\":\"laure.rekoula@yahoo.fr\",\"createdat\":\"2026-01-17 19:27:17 +0100\",\"state\":\"paid\"}', '2026-01-17 18:29:15', NULL, NULL, NULL, NULL, '2026-01-17 18:27:23', '2026-01-17 18:29:15'),
('TRANS-1768674685487-3DBA5A19', 'BILLET-1768674685487-EF3EBF20', 'EV-ROTARY-FORUM-2026', '5550057546', 'REF-ROTARY-3FDDA9D35045', '5550057546', 70000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'Jean-Pierre MAHADY', 'jpmahady@gmail.com', '074447714', '{\"billingid\":\"5550057546\",\"merchantid\":\"smeby33\",\"customerid\":\"074447714\",\"transactionid\":\"1i4JqUJUIJ2ZZSx\",\"reference\":\"REF-ROTARY-3FDDA9D35045\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"70000.0\",\"70000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"Jean-Pierre MAHADY\",\"payeremail\":\"jpmahady@gmail.com\",\"createdat\":\"2026-01-17 19:31:25 +0100\",\"state\":\"paid\"}', '2026-01-17 18:32:12', NULL, NULL, NULL, NULL, '2026-01-17 18:31:30', '2026-01-17 18:32:12'),
('TRANS-1768675314198-5F50211B', 'BILLET-1768675314198-A967FE55', 'EV-ROTARY-FORUM-2026', '5550057547', 'REF-ROTARY-73A0CA19B8B0', '5550057547', 60000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '+24177679339', '{\"billingid\":\"5550057547\",\"merchantid\":\"smeby33\",\"customerid\":\"+24177679339\",\"transactionid\":\"xzOwXwv5JLne27l\",\"reference\":\"REF-ROTARY-73A0CA19B8B0\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"60000.0\",\"60000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-17 19:41:54 +0100\",\"state\":\"paid\"}', '2026-01-17 18:42:52', NULL, NULL, NULL, NULL, '2026-01-17 18:41:59', '2026-01-17 18:42:52'),
('TRANS-1768847652725-8B689B82', 'BILLET-1768847652725-7290010D', 'EV-ROTARY-FORUM-2026', '5550057563', 'REF-ROTARY-BA8CBA58FC22', '5550057563', 60000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', '{\"billingid\":\"5550057563\",\"merchantid\":\"smeby33\",\"customerid\":\"074323255\",\"transactionid\":\"ty5LQDojqkrSUDG\",\"reference\":\"REF-ROTARY-BA8CBA58FC22\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"60000.0\",\"60000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-19 19:34:13 +0100\",\"state\":\"paid\"}', '2026-01-19 18:35:35', NULL, NULL, NULL, NULL, '2026-01-19 18:34:18', '2026-01-19 18:35:35'),
('TRANS-1769449463099-43D9473F', 'BILLET-1769449463099-1D48BD73', 'EV-ROTARY-FORUM-2026', '5550057655', 'REF-ROTARY-3D5578D05602', '5550057655', 50000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-26 17:44:29', '2026-01-26 17:44:30'),
('TRANS-1769458030329-7C090860', 'BILLET-1769458030329-8727DFBF', 'EV-ROTARY-FORUM-2026', '5550057666', 'REF-ROTARY-35B2B504AA56', '5550057666', 50000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-26 20:07:17', '2026-01-26 20:07:17'),
('TRANS-1769458130308-BDEEBBA3', 'BILLET-1769458130308-ADC387F4', 'EV-ROTARY-FORUM-2026', '5550057667', 'REF-ROTARY-9B22EA49B5C2', '5550057667', 60000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-26 20:08:57', '2026-01-26 20:08:57'),
('TRANS-1769518395144-36503A3C', 'BILLET-1769518395144-76B85CB7', 'EV-ROTARY-FORUM-2026', '5550057677', 'REF-ROTARY-6D351C99EFE6', '5550057677', 50000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 12:53:21', '2026-01-27 12:53:22'),
('TRANS-1769519009380-9AF12F6D', 'BILLET-1769519009380-CC1E1C66', 'EV-ROTARY-FORUM-2026', '5550057678', 'REF-ROTARY-474D11A644DC', '5550057678', 50000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 13:03:36', '2026-01-27 13:03:36'),
('TRANS-1769519189724-B2E20EC7', 'BILLET-1769519189724-782E22FA', 'EV-ROTARY-FORUM-2026', '5550057679', 'REF-ROTARY-F9F89E2D978F', '5550057679', 55000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 13:06:36', '2026-01-27 13:06:36'),
('TRANS-1769519397383-FFA66B27', 'BILLET-1769519397381-7FD39365', 'EV-ROTARY-FORUM-2026', '5574301361', 'REF-ROTARY-633D498801B6', '5574301361', 50000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 13:10:04', '2026-01-27 13:10:05'),
('TRANS-1769519612565-0B3DF93E', 'BILLET-1769519612565-87A07955', 'EV-ROTARY-FORUM-2026', '5550057680', 'REF-ROTARY-057C88EA32E9', '5550057680', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 13:13:39', '2026-01-27 13:13:39'),
('TRANS-1769520560379-C6A5EC8F', 'BILLET-1769520560378-4523D1BA', 'EV-ROTARY-FORUM-2026', '5574301586', 'REF-ROTARY-C596C7A9500A', '5574301586', 60000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 13:29:27', '2026-01-27 13:29:27'),
('TRANS-1769520830506-45C11EB0', 'BILLET-1769520830505-AC68E673', 'EV-ROTARY-FORUM-2026', '5574301636', 'REF-ROTARY-460BA218CD12', '5574301636', 400.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', '{\"billingid\":\"5574301636\",\"merchantid\":\"ProGraphiquePub\",\"customerid\":\"077095853\",\"transactionid\":\"MP260127.1439.C65124\",\"reference\":\"REF-ROTARY-460BA218CD12\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"amount\":[\"400.0\",\"400.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-01-27 14:33:50 +0100\",\"state\":\"paid\"}', '2026-01-27 13:39:56', NULL, NULL, NULL, NULL, '2026-01-27 13:33:57', '2026-01-27 13:39:56'),
('TRANS-1769533038473-C0DCED92', 'BILLET-1769533038473-499BDE9C', 'EV-ROTARY-FORUM-2026', '5574304150', 'REF-ROTARY-8CA843AC74CC', '5574304150', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Karen NDJAVE-NDJOY', 'ndjave@gmail.com', '077193212', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-27 16:57:25', '2026-01-27 16:57:25'),
('TRANS-1769635271422-3A2719CE', 'BILLET-1769635271421-CD54CA31', 'EV-ROTARY-FORUM-2026', '5574334039', 'REF-ROTARY-031DD5410388', '5574334039', 60000.00, 'XAF', 'pending', NULL, 'ebilling', 'Zeinabou BOUCKAT', 'zbouckat@yahoo.fr', '077171073', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-28 21:21:18', '2026-01-28 21:21:18'),
('TRANS-1769683007472-3399AE08', 'BILLET-1769683007471-7B27F1FA', 'EV-ROTARY-FORUM-2026', '5574338927', 'REF-ROTARY-638FFADEE564', '5574338927', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Clovis  Nguema ', 'clovisnguema40@gmail.com', '062001751', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-29 10:36:54', '2026-01-29 10:36:54'),
('TRANS-1769779870053-925E7144', 'BILLET-1769779870052-7483E764', 'EV-ROTARY-FORUM-2026', '5574355830', 'REF-ROTARY-EC74502CB5FC', '5574355830', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Danielle OGANDAGA ', 'danielleogandaga596@gmail.com', '062700334', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-30 13:31:17', '2026-01-30 13:31:17'),
('TRANS-1769873231917-945AC9B5', 'BILLET-1769873231917-4B2BD241', 'EV-ROTARY-FORUM-2026', '5574373170', 'REF-ROTARY-C90432EE8398', '5574373170', 35000.00, 'XAF', 'pending', NULL, 'ebilling', 'Ingonguy  Necsy ', 'ingonguy83@gmail.com', '066857272', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-31 15:27:19', '2026-01-31 15:27:19'),
('TRANS-1769873253709-7A70FB98', 'BILLET-1769873253708-75092665', 'EV-ROTARY-FORUM-2026', '5574373178', 'REF-ROTARY-9C257AF97B67', '5574373178', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Erard NDONG ÉMANE ', 'ndongemane77@gmail.com', '066300292', NULL, NULL, NULL, NULL, NULL, NULL, '2026-01-31 15:27:41', '2026-01-31 15:27:41'),
('TRANS-1770464401643-201430E7', 'BILLET-1770464401643-6F9C49C1', 'EV-ROTARY-FORUM-2026', '5574477598', 'REF-ROTARY-EDE8AF4465A5', '5574477598', 40000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'Jean-Pierre  MAHADY', 'jpmahady@gmail.com', '074447714', '{\"billingid\":\"5574477598\",\"merchantid\":\"ProGraphiquePub\",\"customerid\":\"074447714\",\"transactionid\":\"MP260207.1240.C96801\",\"reference\":\"REF-ROTARY-EDE8AF4465A5\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"amount\":[\"40000.0\",\"40000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"Jean-Pierre  MAHADY\",\"payeremail\":\"jpmahady@gmail.com\",\"createdat\":\"2026-02-07 12:40:01 +0100\",\"state\":\"paid\"}', '2026-02-07 11:40:55', NULL, NULL, NULL, NULL, '2026-02-07 11:40:10', '2026-02-07 11:40:55'),
('TRANS-1770620748982-ED19E0A9', 'BILLET-1770620748982-7FB08788', 'EV-ROTARY-FORUM-2026', '5574513027', 'REF-ROTARY-6BE9FE33F7A1', '5574513027', 40000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'Erica Ingrid Greta  AGOMA RENDAMBO ', 'sylgabamh@gmail.com', '077738024', '{\"billingid\":\"5574513027\",\"merchantid\":\"ProGraphiquePub\",\"customerid\":\"077738024\",\"transactionid\":\"MP260209.0807.A01229\",\"reference\":\"REF-ROTARY-6BE9FE33F7A1\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"amount\":[\"40000.0\",\"40000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"Erica Ingrid Greta  AGOMA RENDAMBO \",\"payeremail\":\"sylgabamh@gmail.com\",\"createdat\":\"2026-02-09 08:05:49 +0100\",\"state\":\"paid\"}', '2026-02-09 07:07:22', NULL, NULL, NULL, NULL, '2026-02-09 07:05:57', '2026-02-09 07:07:22'),
('TRANS-1770627769049-77CFEDB2', 'BILLET-1770627769049-852EB084', 'EV-ROTARY-FORUM-2026', '5574513947', 'REF-ROTARY-74E8B5296E39', '5574513947', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Erica Ingrid Greta  AGOMA RENDAMBO ', 'sylgabamh@gmail.com', '077738024', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-09 09:02:57', '2026-02-09 09:02:57'),
('TRANS-1770652272503-289087C7', 'BILLET-1770652272503-9CD13699', 'EV-ROTARY-FORUM-2026', '5574519506', 'REF-ROTARY-A879086C6232', '5574519506', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'MISTA  AGALIE ', 'mistaagalie@gmail.com', '066778686', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-09 15:51:21', '2026-02-09 15:51:21'),
('TRANS-1770669224126-634DADDC', 'BILLET-1770669224126-B3F8DAB6', 'EV-ROTARY-FORUM-2026', '5574524268', 'REF-ROTARY-8FAB66B2FC48', '5574524268', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Jacques Fortune NZOUGHET ESSAI', 'jacquesfortunenzoughetessia@gmai.com', '077410098', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-09 20:33:52', '2026-02-09 20:33:53'),
('TRANS-1770669525451-8741E86D', 'BILLET-1770669525451-880BED51', 'EV-ROTARY-FORUM-2026', '5574524379', 'REF-ROTARY-50B158D731E4', '5574524379', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Jacques fortune Nzoughet essia', 'jacquesfortunenzoughetessia@gmai.com', '077410098', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-09 20:38:54', '2026-02-09 20:38:54'),
('TRANS-1770669737244-69E10616', 'BILLET-1770669737244-02BC39B9', 'EV-ROTARY-FORUM-2026', '5574524443', 'REF-ROTARY-BAFE227419E7', '5574524443', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'JACQUES FORTUNE NZOUGHET ESSIA', 'jacquesfortunenzoughetessia@gmal.com', '077410098', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-09 20:42:25', '2026-02-09 20:42:26'),
('TRANS-1771321314706-CA9E3A9C', 'BILLET-1771321314705-60DD45A1', 'EV-ROTARY-FORUM-2026', '5574646197', 'REF-ROTARY-F9CCC97E1E36', '5574646197', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Patrick Mennesson ', 'patrickmennesson@yahoo.fr', '065666969', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-17 09:42:04', '2026-02-17 09:42:04'),
('TRANS-1771322839845-016B08C1', 'BILLET-1771322839844-AB352634', 'EV-ROTARY-FORUM-2026', '5574646530', 'REF-ROTARY-03901FF57896', '5574646530', 40000.00, 'XAF', 'pending', NULL, 'ebilling', 'Patrick Mennesson', 'patrickmennesson@yahoo.fr', '065666969', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-17 10:07:29', '2026-02-17 10:07:29'),
('TRANS-1771345024149-A0E6A07F', 'BILLET-1771345024149-4EB9C1CC', 'EV-ROTARY-FORUM-2026', '5574651922', 'REF-ROTARY-753B5CC2E7EB', '5574651922', 300.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-17 16:17:14', '2026-02-17 16:17:14'),
('TRANS-1771345258747-5A32AA34', 'BILLET-1771345258747-23A13635', 'EV-ROTARY-FORUM-2026', '5574651999', 'REF-ROTARY-99D38FC8C18F', '5574651999', 300.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', '{\"billingid\":\"5574651999\",\"merchantid\":\"ProGraphiquePub\",\"customerid\":\"077095853\",\"transactionid\":\"MP260217.1722.C51795\",\"reference\":\"REF-ROTARY-99D38FC8C18F\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"amount\":[\"300.0\",\"300.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Rotarien - 22ème Forum des Clubs Rotary - Port-Gentil 2026\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-02-17 17:20:58 +0100\",\"state\":\"paid\"}', '2026-02-17 16:23:06', NULL, NULL, NULL, NULL, '2026-02-17 16:21:08', '2026-02-17 16:23:06'),
('TRANS-1771850793154-D63BDDBE', 'BILLET-1771850793154-CCE0ECC0', 'EV-BROCANTE-2026-001', '5550058203', 'REF-BROCANTE-42CCEB13C026', '5550058203', 11900.00, 'XAF', 'pending', NULL, 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 12:46:33', '2026-02-23 12:46:35'),
('TRANS-1771851091947-B93FDF22', 'BILLET-1771851091947-3A0B6128', 'EV-BROCANTE-2026-001', '5550058204', 'REF-BROCANTE-36CE0E769282', '5550058204', 11900.00, 'XAF', 'pending', NULL, 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 12:51:32', '2026-02-23 12:51:33'),
('TRANS-1771851139137-E6BA0989', 'BILLET-1771851139136-B0FB5A74', 'EV-BROCANTE-2026-001', '5550058205', 'REF-BROCANTE-EC5F78F912D8', '5550058205', 11900.00, 'XAF', 'pending', NULL, 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 12:52:19', '2026-02-23 12:52:20'),
('TRANS-1771851632741-365F415D', 'BILLET-1771851632741-CAEABB8C', 'EV-BROCANTE-2026-001', '5550058207', 'REF-BROCANTE-DBAFB8380014', '5550058207', 11900.00, 'XAF', 'pending', NULL, 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 13:00:33', '2026-02-23 13:00:34'),
('TRANS-1771852100127-DBCE05FD', 'BILLET-1771852100126-6A8E4A3E', 'EV-BROCANTE-2026-001', '5550058208', 'REF-BROCANTE-7E9671C59B72', '5550058208', 11900.00, 'XAF', 'pending', NULL, 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 13:08:20', '2026-02-23 13:08:22'),
('TRANS-1771852551171-0EE3078A', 'BILLET-1771852551170-EDE92895', 'EV-BROCANTE-2026-001', '5550058209', 'REF-BROCANTE-98A1928C2519', '5550058209', 11900.00, 'XAF', 'pending', NULL, 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-23 13:15:51', '2026-02-23 13:15:52'),
('TRANS-1771852598122-4AAAF540', 'BILLET-1771852598122-BB56B266', 'EV-BROCANTE-2026-001', '5550058210', 'REF-BROCANTE-4B29BF7C3A8D', '5550058210', 11900.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', '{\"billingid\":\"5550058210\",\"merchantid\":\"afup\",\"customerid\":\"+24177001255\",\"transactionid\":\"06MCseyyStP2pQk\",\"reference\":\"REF-BROCANTE-4B29BF7C3A8D\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"11900.0\",\"11900.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"3 billet(s) - Ouverture des Brocantes Solidaires\",\"payername\":\"samira Kananga\",\"payeremail\":\"client1@gmail.com\",\"createdat\":\"2026-02-23 14:16:39 +0100\",\"state\":\"paid\"}', '2026-02-23 13:17:54', NULL, NULL, NULL, NULL, '2026-02-23 13:16:38', '2026-02-23 13:17:54'),
('TRANS-1771868331318-ED22998C', 'BILLET-1771868331317-E8A7AAD4', 'EV-BROCANTE-2026-001', '5550058211', 'REF-BROCANTE-2B01CF8A7B7D', '5550058211', 11900.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', '{\"billingid\":\"5550058211\",\"merchantid\":\"afup\",\"customerid\":\"+24177001255\",\"transactionid\":\"dpe7HVFubWW6LXP\",\"reference\":\"REF-BROCANTE-2B01CF8A7B7D\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"11900.0\",\"11900.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"3 billet(s) - Ouverture des Brocantes Solidaires\",\"payername\":\"samira Kananga\",\"payeremail\":\"client1@gmail.com\",\"createdat\":\"2026-02-23 18:38:54 +0100\",\"state\":\"paid\"}', '2026-02-23 17:54:57', NULL, NULL, NULL, NULL, '2026-02-23 17:38:51', '2026-02-23 17:54:57'),
('TRANS-1771920142794-C58DC0D4', 'BILLET-1771920142794-7BD9F0E5', 'EV-BROCANTE-2026-001', '5550058212', 'REF-BROCANTE-A68959AB1D1D', '5550058212', 7900.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'samira Kananga', 'client1@gmail.com', '077001255', '{\"billingid\":\"5550058212\",\"merchantid\":\"afup\",\"customerid\":\"077095853\",\"transactionid\":\"eKeDd8SDQypob52\",\"reference\":\"REF-BROCANTE-A68959AB1D1D\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"7900.0\",\"7900.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) - Ouverture des Brocantes Solidaires\",\"payername\":\"samira Kananga\",\"payeremail\":\"client1@gmail.com\",\"createdat\":\"2026-02-24 09:02:22 +0100\",\"state\":\"paid\"}', '2026-02-24 08:04:42', NULL, NULL, NULL, NULL, '2026-02-24 08:02:21', '2026-02-24 08:04:42'),
('TRANS-1772037052495-319EB015', 'BILLET-1772037052478-F4B72C35', 'EV-SHAINA-SMARTAPP-001', '5574779164', 'REF-ROTARY-59AE78A77D64', '5574779164', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 16:30:52', '2026-02-25 16:30:55'),
('TRANS-1772037805020-CBA6C770', 'BILLET-1772037805007-80CB5578', 'EV-SHAINA-SMARTAPP-001', '5574779399', 'REF-ROTARY-AB0413FC982C', '5574779399', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 16:43:25', '2026-02-25 16:43:26'),
('TRANS-1772039107718-697C21AF', 'BILLET-1772039107707-02A86E28', 'EV-SHAINA-SMARTAPP-001', '5550058218', 'REF-ROTARY-0C2B38724A70', '5550058218', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 17:05:08', '2026-02-25 17:05:09'),
('TRANS-1772039117856-73505EB9', 'BILLET-1772039117855-CBEF4DF5', 'EV-SHAINA-SMARTAPP-001', '5550058219', 'REF-ROTARY-F29EEA0959E8', '5550058219', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 17:05:18', '2026-02-25 17:05:19'),
('TRANS-1772039399811-C018999B', 'BILLET-1772039399806-66348B05', 'EV-SHAINA-SMARTAPP-001', '5550058220', 'REF-ROTARY-76D77AB1A98B', '5550058220', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 17:10:00', '2026-02-25 17:10:01'),
('TRANS-1772039418406-E9CD1A86', 'BILLET-1772039418405-660AF650', 'EV-SHAINA-SMARTAPP-001', '5550058221', 'REF-ROTARY-8E4B1076BB6E', '5550058221', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 17:10:18', '2026-02-25 17:10:19'),
('TRANS-1772039428293-E9D7F0A0', 'BILLET-1772039428293-D612DB6C', 'EV-SHAINA-SMARTAPP-001', '5550058222', 'REF-ROTARY-E662104D9BFE', '5550058222', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 17:10:28', '2026-02-25 17:10:29'),
('TRANS-1772039433094-38D5832F', 'BILLET-1772039433094-4830FF5F', 'EV-SHAINA-SMARTAPP-001', '5550058223', 'REF-ROTARY-B8382D40C26C', '5550058223', 3500.00, 'XOF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-25 17:10:33', '2026-02-25 17:10:33'),
('TRANS-1772039593263-CA7FEDA8', 'BILLET-1772039593244-9A13234B', 'EV-SHAINA-SMARTAPP-001', '5550058224', 'REF-ROTARY-C4035C3211E3', '5550058224', 3500.00, 'XOF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '', '{\"billingid\":\"5550058224\",\"merchantid\":\"afup\",\"customerid\":\"077095853\",\"transactionid\":\"cvsg2EpeFWa9H7I\",\"reference\":\"REF-ROTARY-C4035C3211E3\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"3500.0\",\"3500\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Standard - Shaina Smart App - Commandes de documents\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-02-25 18:13:14 +0100\",\"state\":\"paid\"}', '2026-02-25 18:30:19', NULL, NULL, NULL, NULL, '2026-02-25 17:13:13', '2026-02-25 18:30:19'),
('TRANS-1772304350664-489A461B', 'BILLET-1772304350663-C53BE243', 'EV-WEDDING-PLANNER-2026', '5574826589', 'REF-ROTARY-9B107F80395C', '5574826589', 60000.00, 'XAF', 'pending', NULL, 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', NULL, NULL, NULL, NULL, NULL, NULL, '2026-02-28 18:45:51', '2026-02-28 18:45:52'),
('TRANS-1772304591960-3806EC88', 'BILLET-1772304591960-B5E2BB4D', 'EV-WEDDING-PLANNER-2026', '5550058236', 'REF-ROTARY-26BF8FEE314B', '5550058236', 60000.00, 'XAF', 'success', 'airtelmoney', 'ebilling', 'SAGOUNAMA-MENSAH Emmanuel', 'smebedoh33@gmail.com', '077679339', '{\"billingid\":\"5550058236\",\"merchantid\":\"afup\",\"customerid\":\"077120055\",\"transactionid\":\"2se8JSk90hLlfp8\",\"reference\":\"REF-ROTARY-26BF8FEE314B\",\"payer_id\":\"\",\"payer_code\":\"\",\"paymentsystem\":\"airtelmoney\",\"data0\":\"\",\"amount\":[\"60000.0\",\"60000.0\"],\"subpaymentsystem\":\"\",\"paymentsystemtoken\":\"\",\"shortdescription\":\"1 billet(s) Faire-part  gestion invite - Wedding Planner AFUP - Offres mariage\",\"payername\":\"SAGOUNAMA-MENSAH Emmanuel\",\"payeremail\":\"smebedoh33@gmail.com\",\"createdat\":\"2026-02-28 19:49:53 +0100\",\"state\":\"paid\"}', '2026-02-28 18:51:27', NULL, NULL, NULL, NULL, '2026-02-28 18:49:52', '2026-02-28 18:51:27');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `rotary_transactions_pending`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `rotary_transactions_pending` (
`transaction_id` varchar(50)
,`external_reference` varchar(100)
,`bill_id` varchar(100)
,`montant` decimal(12,2) unsigned
,`created_at` timestamp
,`reference_billet` varchar(30)
,`prenom` varchar(100)
,`nom` varchar(100)
,`email` varchar(255)
,`evenement_titre` varchar(255)
,`date_evenement` datetime
);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `administrateurs`
--
ALTER TABLE `administrateurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Index pour la table `rotary_billets`
--
ALTER TABLE `rotary_billets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `reference_billet` (`reference_billet`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_statut_paiement` (`statut_paiement`),
  ADD KEY `idx_statut_billet` (`statut_billet`),
  ADD KEY `idx_evenement` (`evenement_id`),
  ADD KEY `fk_billet_user` (`user_id`),
  ADD KEY `fk_billet_categorie` (`categorie_id`);

--
-- Index pour la table `rotary_billets_categories`
--
ALTER TABLE `rotary_billets_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_categorie_evenement` (`evenement_id`);

--
-- Index pour la table `rotary_codes_promo`
--
ALTER TABLE `rotary_codes_promo`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_code_active` (`code`,`is_active`),
  ADD KEY `fk_promo_evenement` (`evenement_id`);

--
-- Index pour la table `rotary_email_logs`
--
ALTER TABLE `rotary_email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recipient` (`recipient_email`),
  ADD KEY `idx_statut` (`statut`),
  ADD KEY `fk_email_billet` (`billet_id`),
  ADD KEY `fk_email_transaction` (`transaction_id`);

--
-- Index pour la table `rotary_evenements`
--
ALTER TABLE `rotary_evenements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_date_evenement` (`date_evenement`),
  ADD KEY `idx_statut` (`statut`),
  ADD KEY `idx_type` (`type_evenement`),
  ADD KEY `fk_rotary_event_creator` (`created_by_user_id`);

--
-- Index pour la table `rotary_transactions`
--
ALTER TABLE `rotary_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bill_id` (`bill_id`),
  ADD KEY `idx_external_ref` (`external_reference`),
  ADD KEY `idx_statut` (`statut`),
  ADD KEY `idx_payer_email` (`payer_email`),
  ADD KEY `fk_transaction_billet` (`billet_id`),
  ADD KEY `fk_transaction_evenement` (`evenement_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `administrateurs`
--
ALTER TABLE `administrateurs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

-- --------------------------------------------------------

--
-- Structure de la vue `rotary_stats_evenements`
--
DROP TABLE IF EXISTS `rotary_stats_evenements`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u929681960_afuppay`@`127.0.0.1` SQL SECURITY DEFINER VIEW `rotary_stats_evenements`  AS SELECT `e`.`id` AS `evenement_id`, `e`.`titre` AS `titre`, `e`.`date_evenement` AS `date_evenement`, `e`.`statut` AS `statut`, `e`.`capacite_max` AS `capacite_max`, count(distinct `b`.`id`) AS `total_billets`, sum(`b`.`quantite`) AS `total_places_vendues`, sum(case when `b`.`statut_paiement` = 'paye' then `b`.`quantite` else 0 end) AS `places_payees`, sum(case when `b`.`statut_paiement` = 'paye' then `b`.`montant_total` else 0 end) AS `revenus_total`, count(distinct `b`.`email`) AS `participants_uniques` FROM (`rotary_evenements` `e` left join `rotary_billets` `b` on(`e`.`id` = `b`.`evenement_id`)) GROUP BY `e`.`id` ;

-- --------------------------------------------------------

--
-- Structure de la vue `rotary_transactions_pending`
--
DROP TABLE IF EXISTS `rotary_transactions_pending`;

CREATE ALGORITHM=UNDEFINED DEFINER=`u929681960_afuppay`@`127.0.0.1` SQL SECURITY DEFINER VIEW `rotary_transactions_pending`  AS SELECT `t`.`id` AS `transaction_id`, `t`.`external_reference` AS `external_reference`, `t`.`bill_id` AS `bill_id`, `t`.`montant` AS `montant`, `t`.`created_at` AS `created_at`, `b`.`reference_billet` AS `reference_billet`, `b`.`prenom` AS `prenom`, `b`.`nom` AS `nom`, `b`.`email` AS `email`, `e`.`titre` AS `evenement_titre`, `e`.`date_evenement` AS `date_evenement` FROM ((`rotary_transactions` `t` join `rotary_billets` `b` on(`t`.`billet_id` = `b`.`id`)) join `rotary_evenements` `e` on(`t`.`evenement_id` = `e`.`id`)) WHERE `t`.`statut` = 'pending' ORDER BY `t`.`created_at` DESC ;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `rotary_billets`
--
ALTER TABLE `rotary_billets`
  ADD CONSTRAINT `fk_billet_categorie` FOREIGN KEY (`categorie_id`) REFERENCES `rotary_billets_categories` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_billet_evenement` FOREIGN KEY (`evenement_id`) REFERENCES `rotary_evenements` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `rotary_billets_categories`
--
ALTER TABLE `rotary_billets_categories`
  ADD CONSTRAINT `fk_categorie_evenement` FOREIGN KEY (`evenement_id`) REFERENCES `rotary_evenements` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `rotary_codes_promo`
--
ALTER TABLE `rotary_codes_promo`
  ADD CONSTRAINT `fk_promo_evenement` FOREIGN KEY (`evenement_id`) REFERENCES `rotary_evenements` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `rotary_email_logs`
--
ALTER TABLE `rotary_email_logs`
  ADD CONSTRAINT `fk_email_billet` FOREIGN KEY (`billet_id`) REFERENCES `rotary_billets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_email_transaction` FOREIGN KEY (`transaction_id`) REFERENCES `rotary_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `rotary_transactions`
--
ALTER TABLE `rotary_transactions`
  ADD CONSTRAINT `fk_transaction_billet` FOREIGN KEY (`billet_id`) REFERENCES `rotary_billets` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_transaction_evenement` FOREIGN KEY (`evenement_id`) REFERENCES `rotary_evenements` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
