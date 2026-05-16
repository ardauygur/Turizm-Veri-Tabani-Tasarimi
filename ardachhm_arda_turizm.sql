-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Dec 21, 2025 at 03:22 PM
-- Server version: 8.0.40
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `asd`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_departman_personelleri` (IN `p_departman` VARCHAR(50))   SELECT 
    P.personel_id,
    CONCAT(K.ad, ' ', K.soyad) AS personel_adi_soyadi,
    P.departman,
    P.pozisyon,
    P.ise_giris_tarihi,
    P.maas,
    K.email,
    K.telefon
FROM personeller P
INNER JOIN kullanicilar K ON P.kullanici_id = K.kullanici_id
WHERE P.departman = p_departman
ORDER BY P.ise_giris_tarihi ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_en_cok_rezervasyon_yapan_musteriler` ()   SELECT 
    M.musteri_id,
    CONCAT(K.ad, ' ', K.soyad) AS musteri_adi_soyadi,
    K.email,
    COUNT(DISTINCT MR.rezervasyon_id) AS rezervasyon_sayisi,
    SUM(R.toplam_ucret) AS toplam_harcama,
    AVG(R.toplam_ucret) AS ortalama_harcama
FROM musteriler M
INNER JOIN kullanicilar K ON M.kullanici_id = K.kullanici_id
INNER JOIN musteriler_rezervasyonlar MR ON M.musteri_id = MR.musteri_id
INNER JOIN rezervasyonlar R ON MR.rezervasyon_id = R.rezervasyon_id
GROUP BY M.musteri_id, K.ad, K.soyad, K.email
ORDER BY rezervasyon_sayisi DESC, toplam_harcama DESC
LIMIT 10$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_fiyat_araligindaki_programlar` (IN `p_min_fiyat` DECIMAL(10,2), IN `p_max_fiyat` DECIMAL(10,2))   SELECT 
    SP.program_id,
    SP.tur_adi,
    SP.baslangic_tarihi,
    SP.bitis_tarihi,
    SP.fiyat,
    SP.max_katilimci_sayisi,
    SP.mevcut_katilimci_sayisi,
    COUNT(DISTINCT R.rezervasyon_id) AS rezervasyon_sayisi
FROM seyahat_programlari SP
LEFT JOIN rezervasyonlar R ON SP.program_id = R.program_id
WHERE SP.fiyat BETWEEN p_min_fiyat AND p_max_fiyat
GROUP BY SP.program_id, SP.tur_adi, SP.baslangic_tarihi, SP.bitis_tarihi, SP.fiyat, SP.max_katilimci_sayisi, SP.mevcut_katilimci_sayisi
ORDER BY SP.fiyat ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_musteri_rezervasyonlari` (IN `p_musteri_id` INT)   SELECT 
    R.rezervasyon_id,
    SP.tur_adi,
    O.otel_adi,
    R.rezervasyon_tarihi,
    R.tur_baslangic_tarihi,
    R.tur_bitis_tarihi,
    R.kisi_sayisi,
    R.toplam_ucret,
    R.odeme_durumu
FROM rezervasyonlar R
INNER JOIN musteriler_rezervasyonlar MR ON R.rezervasyon_id = MR.rezervasyon_id
INNER JOIN seyahat_programlari SP ON R.program_id = SP.program_id
INNER JOIN oteller O ON R.otel_id = O.otel_id
WHERE MR.musteri_id = p_musteri_id
ORDER BY R.rezervasyon_tarihi DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_odeme_durumu_rezervasyonlari` (IN `p_odeme_durumu` VARCHAR(20))   SELECT 
    R.rezervasyon_id,
    CONCAT(K.ad, ' ', K.soyad) AS musteri_adi_soyadi,
    SP.tur_adi,
    O.otel_adi,
    R.rezervasyon_tarihi,
    R.toplam_ucret,
    R.odeme_durumu
FROM rezervasyonlar R
INNER JOIN musteriler_rezervasyonlar MR ON R.rezervasyon_id = MR.rezervasyon_id
INNER JOIN musteriler M ON MR.musteri_id = M.musteri_id
INNER JOIN kullanicilar K ON M.kullanici_id = K.kullanici_id
INNER JOIN seyahat_programlari SP ON R.program_id = SP.program_id
INNER JOIN oteller O ON R.otel_id = O.otel_id
WHERE R.odeme_durumu = p_odeme_durumu
ORDER BY R.rezervasyon_tarihi DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_program_sehirleri` (IN `p_program_id` INT)   SELECT 
    SP.program_id,
    SP.tur_adi,
    S.sehir_id,
    S.sehir_adi,
    S.ulke
FROM seyahat_programlari SP
INNER JOIN seyahat_programlari_sehirler SPS ON SP.program_id = SPS.program_id
INNER JOIN sehirler S ON SPS.sehir_id = S.sehir_id
WHERE SP.program_id = p_program_id
ORDER BY S.sehir_adi$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rehber_istatistikleri` ()   SELECT 
    R.rehber_id,
    CONCAT(K.ad, ' ', K.soyad) AS rehber_adi_soyadi,
    R.bildigi_diller,
    R.deneyim_yili,
    COUNT(DISTINCT RSP.program_id) AS program_sayisi,
    COUNT(DISTINCT REZ.rezervasyon_id) AS rezervasyon_sayisi
FROM rehberler R
INNER JOIN personeller P ON R.personel_id = P.personel_id
INNER JOIN kullanicilar K ON P.kullanici_id = K.kullanici_id
LEFT JOIN rehberler_seyahat_programlari RSP ON R.rehber_id = RSP.rehber_id
LEFT JOIN seyahat_programlari SP ON RSP.program_id = SP.program_id
LEFT JOIN rezervasyonlar REZ ON SP.program_id = REZ.program_id
GROUP BY R.rehber_id, K.ad, K.soyad, R.bildigi_diller, R.deneyim_yili
ORDER BY program_sayisi DESC, deneyim_yili DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rehber_programlari` (IN `p_rehber_id` INT)   SELECT 
    SP.program_id,
    SP.tur_adi,
    SP.baslangic_tarihi,
    SP.bitis_tarihi,
    SP.kalkis_noktasi,
    SP.varis_noktasi,
    CONCAT(K.ad, ' ', K.soyad) AS rehber_adi_soyadi,
    R.bildigi_diller,
    R.deneyim_yili
FROM seyahat_programlari SP
INNER JOIN rehberler_seyahat_programlari RSP ON SP.program_id = RSP.program_id
INNER JOIN rehberler R ON RSP.rehber_id = R.rehber_id
INNER JOIN personeller P ON R.personel_id = P.personel_id
INNER JOIN kullanicilar K ON P.kullanici_id = K.kullanici_id
WHERE R.rehber_id = p_rehber_id
ORDER BY SP.baslangic_tarihi$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rezervasyonlari_listele` (IN `p_baslangic_tarihi` DATE, IN `p_bitis_tarihi` DATE)   SELECT 
    R.rezervasyon_id,
    CONCAT(K.ad, ' ', K.soyad) AS musteri_adi_soyadi,
    SP.tur_adi,
    R.rezervasyon_tarihi,
    R.tur_baslangic_tarihi,
    R.tur_bitis_tarihi,
    R.kisi_sayisi,
    R.toplam_ucret,
    R.odeme_durumu
FROM rezervasyonlar R
INNER JOIN musteriler_rezervasyonlar MR ON R.rezervasyon_id = MR.rezervasyon_id
INNER JOIN musteriler M ON MR.musteri_id = M.musteri_id
INNER JOIN kullanicilar K ON M.kullanici_id = K.kullanici_id
INNER JOIN seyahat_programlari SP ON R.program_id = SP.program_id
WHERE R.rezervasyon_tarihi BETWEEN p_baslangic_tarihi AND p_bitis_tarihi
ORDER BY R.rezervasyon_tarihi DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_sehir_otelleri_listele` (IN `p_sehir_adi` VARCHAR(50))   SELECT 
    O.otel_id,
    O.otel_adi,
    O.yildiz_sayisi,
    O.gunluk_fiyat,
    S.sehir_adi,
    S.ulke
FROM oteller O
INNER JOIN oteller_sehirler OS ON O.otel_id = OS.otel_id
INNER JOIN sehirler S ON OS.sehir_id = S.sehir_id
WHERE S.sehir_adi LIKE CONCAT('%', p_sehir_adi, '%')
ORDER BY O.yildiz_sayisi DESC, O.gunluk_fiyat ASC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_vip_musteriler` ()   SELECT 
    M.musteri_id,
    CONCAT(K.ad, ' ', K.soyad) AS musteri_adi_soyadi,
    K.email,
    K.telefon,
    M.vip_durumu,
    M.indirim_orani,
    COUNT(DISTINCT MR.rezervasyon_id) AS toplam_rezervasyon_sayisi,
    SUM(R.toplam_ucret) AS toplam_harcama
FROM musteriler M
INNER JOIN kullanicilar K ON M.kullanici_id = K.kullanici_id
LEFT JOIN musteriler_rezervasyonlar MR ON M.musteri_id = MR.musteri_id
LEFT JOIN rezervasyonlar R ON MR.rezervasyon_id = R.rezervasyon_id
WHERE M.vip_durumu = TRUE
GROUP BY M.musteri_id, K.ad, K.soyad, K.email, K.telefon, M.vip_durumu, M.indirim_orani
ORDER BY toplam_harcama DESC$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_yildiz_otelleri` (IN `p_yildiz_sayisi` INT)   SELECT 
    O.otel_id,
    O.otel_adi,
    O.yildiz_sayisi,
    O.gunluk_fiyat,
    GROUP_CONCAT(DISTINCT S.sehir_adi ORDER BY S.sehir_adi SEPARATOR ', ') AS sehirler,
    COUNT(DISTINCT OS.sehir_id) AS sehir_sayisi
FROM oteller O
LEFT JOIN oteller_sehirler OS ON O.otel_id = OS.otel_id
LEFT JOIN sehirler S ON OS.sehir_id = S.sehir_id
WHERE O.yildiz_sayisi = p_yildiz_sayisi
GROUP BY O.otel_id, O.otel_adi, O.yildiz_sayisi, O.gunluk_fiyat
ORDER BY O.gunluk_fiyat ASC$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kullanicilar`
--

CREATE TABLE `kullanicilar` (
  `kullanici_id` int NOT NULL,
  `ad` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `soyad` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `telefon` varchar(15) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `sehir_id` int DEFAULT NULL,
  `kayit_tarihi` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `kullanicilar`
--

INSERT INTO `kullanicilar` (`kullanici_id`, `ad`, `soyad`, `email`, `telefon`, `sehir_id`, `kayit_tarihi`) VALUES
(1, 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@email.com', '05321111111', 34, '2025-12-19 23:53:19'),
(2, 'Ayşe', 'Demir', 'ayse.demir@email.com', '05322222222', 6, '2025-12-19 23:53:19'),
(3, 'Mehmet', 'Kaya', 'mehmet.kaya@email.com', '05323333333', 35, '2025-12-19 23:53:19'),
(4, 'Fatma', 'Şahin', 'fatma.sahin@email.com', '05324444444', 16, '2025-12-19 23:53:19'),
(5, 'Ali', 'Çelik', 'ali.celik@email.com', '05325555555', 7, '2025-12-19 23:53:19'),
(6, 'Zeynep', 'Arslan', 'zeynep.arslan@email.com', '05326666666', 34, '2025-12-19 23:53:19'),
(7, 'Mustafa', 'Özdemir', 'mustafa.ozdemir@email.com', '05327777777', 6, '2025-12-19 23:53:19'),
(8, 'Elif', 'Doğan', 'elif.dogan@email.com', '05328888888', 35, '2025-12-19 23:53:19'),
(9, 'Can', 'Aksoy', 'can.aksoy@email.com', '05329999999', 16, '2025-12-19 23:53:19'),
(10, 'Selin', 'Kara', 'selin.kara@email.com', '05320000000', 7, '2025-12-19 23:53:19'),
(11, 'Murat', 'Aksoy', 'murat.aksoy@email.com', '05321111112', 34, '2025-12-19 23:53:19'),
(12, 'Sibel', 'Yılmaz', 'sibel.yilmaz@email.com', '05322222223', 6, '2025-12-19 23:53:19'),
(13, 'Emre', 'Kara', 'emre.kara@email.com', '05323333334', 35, '2025-12-19 23:53:19'),
(14, 'Can', 'Şahin', 'can.sahin@email.com', '05324444445', 16, '2025-12-19 23:53:19'),
(15, 'Gizem', 'Demir', 'gizem.demir@email.com', '05326666667', 34, '2025-12-19 23:53:19'),
(16, 'Kerem', 'Yıldız', 'kerem.yildiz@email.com', '05327777778', 6, '2025-12-19 23:53:19'),
(17, 'Pınar', 'Arslan', 'pinar.arslan@email.com', '05328888889', 35, '2025-12-19 23:53:19'),
(18, 'Onur', 'Çelik', 'onur.celik@email.com', '05329999990', 16, '2025-12-19 23:53:19'),
(19, 'Aslı', 'Koç', 'asli.koc@email.com', '05320000001', 7, '2025-12-19 23:53:19'),
(20, 'Tolga', 'Aydın', 'tolga.aydin@email.com', '05321111113', 34, '2025-12-19 23:53:19'),
(21, 'Deniz', 'Yıldız', 'deniz.yildiz@email.com', '05321111114', 34, '2025-12-19 23:53:19'),
(22, 'Burak', 'Koç', 'burak.koc@email.com', '05322222224', 6, '2025-12-19 23:53:19'),
(23, 'Cem', 'Özkan', 'cem.ozkan@email.com', '05323333335', 35, '2025-12-19 23:53:19'),
(24, 'Derya', 'Aydın', 'derya.aydin@email.com', '05324444446', 16, '2025-12-19 23:53:19'),
(25, 'Ege', 'Kurt', 'ege.kurt@email.com', '05325555557', 7, '2025-12-19 23:53:19'),
(26, 'Fulya', 'Şen', 'fulya.sen@email.com', '05326666668', 16, '2025-12-19 23:53:19'),
(27, 'Gökhan', 'Yıldırım', 'gokhan.yildirim@email.com', '05327777779', 34, '2025-12-19 23:53:19'),
(28, 'Hülya', 'Çetin', 'hulya.cetin@email.com', '05328888890', 6, '2025-12-19 23:53:19'),
(29, 'İbrahim', 'Öztürk', 'ibrahim.ozturk@email.com', '05329999991', 35, '2025-12-19 23:53:19'),
(30, 'Jale', 'Kılıç', 'jale.kilic@email.com', '05320000002', 16, '2025-12-19 23:53:19'),
(31, 'Kemal', 'Avcı', 'kemal.avci@email.com', '05321111116', 7, '2025-12-19 23:53:19'),
(32, 'Leyla', 'Bulut', 'leyla.bulut@email.com', '05322222227', 34, '2025-12-19 23:53:19');

-- --------------------------------------------------------

--
-- Table structure for table `musteriler`
--

CREATE TABLE `musteriler` (
  `musteri_id` int NOT NULL,
  `kullanici_id` int NOT NULL,
  `tckn` char(11) COLLATE utf8mb4_turkish_ci NOT NULL,
  `vip_durumu` tinyint(1) DEFAULT '0',
  `indirim_orani` decimal(3,2) DEFAULT '0.00'
) ;

--
-- Dumping data for table `musteriler`
--

INSERT INTO `musteriler` (`musteri_id`, `kullanici_id`, `tckn`, `vip_durumu`, `indirim_orani`) VALUES
(1, 1, '12345678901', 1, 0.15),
(2, 2, '12345678902', 1, 0.10),
(3, 3, '12345678903', 1, 0.15),
(4, 4, '12345678904', 1, 0.15),
(5, 5, '12345678905', 0, 0.00),
(6, 6, '12345678906', 1, 0.20),
(7, 7, '12345678907', 0, 0.00),
(8, 8, '12345678908', 0, 0.00),
(9, 9, '12345678909', 1, 0.10),
(10, 10, '12345678910', 0, 0.00),
(11, 11, '12345678911', 1, 0.15),
(12, 12, '12345678912', 1, 0.15);

--
-- Triggers `musteriler`
--
DELIMITER $$
CREATE TRIGGER `trg_vip_indirim_uygulama` AFTER UPDATE ON `musteriler` FOR EACH ROW BEGIN
    -- VIP durumu TRUE yapıldıysa ve indirim oranı değiştiyse
    IF NEW.vip_durumu = TRUE AND OLD.vip_durumu = FALSE AND NEW.indirim_orani > 0 THEN
        -- Bekleyen rezervasyonlara indirim uygula
        UPDATE rezervasyonlar R
        INNER JOIN musteriler_rezervasyonlar MR ON R.rezervasyon_id = MR.rezervasyon_id
        SET R.toplam_ucret = R.toplam_ucret * (1 - NEW.indirim_orani)
        WHERE MR.musteri_id = NEW.musteri_id 
        AND R.odeme_durumu = 'Beklemede';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `musteriler_rezervasyonlar`
--

CREATE TABLE `musteriler_rezervasyonlar` (
  `musteri_id` int NOT NULL,
  `rezervasyon_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `musteriler_rezervasyonlar`
--

INSERT INTO `musteriler_rezervasyonlar` (`musteri_id`, `rezervasyon_id`) VALUES
(1, 1),
(4, 1),
(2, 2),
(5, 2),
(3, 3),
(6, 3),
(4, 4),
(7, 4),
(5, 5),
(8, 5),
(6, 6),
(9, 6),
(7, 7),
(10, 7),
(8, 8),
(11, 8),
(9, 9),
(12, 9),
(10, 10),
(11, 11),
(12, 12),
(2, 14);

-- --------------------------------------------------------

--
-- Table structure for table `oteller`
--

CREATE TABLE `oteller` (
  `otel_id` int NOT NULL,
  `otel_adi` varchar(100) COLLATE utf8mb4_turkish_ci NOT NULL,
  `yildiz_sayisi` int DEFAULT NULL,
  `gunluk_fiyat` decimal(10,2) DEFAULT NULL
) ;

--
-- Dumping data for table `oteller`
--

INSERT INTO `oteller` (`otel_id`, `otel_adi`, `yildiz_sayisi`, `gunluk_fiyat`) VALUES
(1, 'Grand İstanbul Hotel', 5, 1020.00),
(2, 'Ankara Plaza Hotel', 4, 600.00),
(3, 'İzmir Coast Resort', 5, 900.00),
(4, 'Bursa Thermal Hotel', 4, 550.00),
(5, 'Antalya Beach Resort', 5, 1100.00),
(6, 'Trabzon Black Sea Hotel', 3, 691.20),
(7, 'Van Lake Hotel', 4, 500.00),
(8, 'Şanlıurfa Historical Hotel', 3, 350.00),
(9, 'Konya Mevlana Hotel', 4, 450.00),
(10, 'Muğla Marina Hotel', 5, 1200.00),
(11, 'Rize Tea Garden Hotel', 3, 380.00),
(12, 'Artvin Nature Hotel', 2, 250.00);

--
-- Triggers `oteller`
--
DELIMITER $$
CREATE TRIGGER `trg_otel_fiyat_guncelleme_sonrasi_rezervasyon_guncelleme` AFTER UPDATE ON `oteller` FOR EACH ROW BEGIN
    DECLARE v_gun_sayisi INT;
    DECLARE v_eski_toplam DECIMAL(10,2);
    DECLARE v_yeni_toplam DECIMAL(10,2);
    DECLARE v_fark DECIMAL(10,2);
    IF OLD.gunluk_fiyat != NEW.gunluk_fiyat THEN
        UPDATE rezervasyonlar
        SET toplam_ucret = (
            NEW.gunluk_fiyat * DATEDIFF(tur_bitis_tarihi, tur_baslangic_tarihi) * kisi_sayisi
        )
        WHERE otel_id = NEW.otel_id 
        AND odeme_durumu = 'Beklemede';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `oteller_sehirler`
--

CREATE TABLE `oteller_sehirler` (
  `otel_id` int NOT NULL,
  `sehir_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `oteller_sehirler`
--

INSERT INTO `oteller_sehirler` (`otel_id`, `sehir_id`) VALUES
(2, 6),
(3, 6),
(5, 7),
(6, 7),
(12, 8),
(4, 16),
(5, 16),
(1, 34),
(2, 34),
(3, 35),
(4, 35),
(9, 42),
(10, 42),
(10, 48),
(11, 48),
(1, 50),
(11, 53),
(12, 53),
(6, 61),
(7, 61),
(8, 63),
(9, 63),
(7, 65),
(8, 65);

-- --------------------------------------------------------

--
-- Table structure for table `personeller`
--

CREATE TABLE `personeller` (
  `personel_id` int NOT NULL,
  `kullanici_id` int NOT NULL,
  `ise_giris_tarihi` date NOT NULL,
  `maas` decimal(10,2) DEFAULT NULL,
  `departman` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `pozisyon` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `personeller`
--

INSERT INTO `personeller` (`personel_id`, `kullanici_id`, `ise_giris_tarihi`, `maas`, `departman`, `pozisyon`) VALUES
(1, 13, '2020-01-15', 15000.00, 'Yönetim', 'Müdür'),
(2, 14, '2021-03-20', 12000.00, 'Satış', 'Satış Temsilcisi'),
(3, 15, '2022-05-10', 10000.00, 'Operasyon', 'Operasyon Uzmanı'),
(4, 16, '2020-07-01', 18000.00, 'Yönetim', 'Genel Müdür'),
(5, 17, '2021-09-15', 11000.00, 'Satış', 'Satış Temsilcisi'),
(6, 18, '2022-11-01', 9500.00, 'Operasyon', 'Operasyon Uzmanı'),
(7, 19, '2023-01-10', 13000.00, 'İnsan Kaynakları', 'İK Uzmanı'),
(8, 20, '2021-06-20', 14000.00, 'Muhasebe', 'Muhasebeci'),
(9, 21, '2023-02-15', 10500.00, 'Operasyon', 'Operasyon Uzmanı'),
(10, 22, '2022-08-20', 12500.00, 'Satış', 'Satış Müdürü'),
(11, 23, '2023-03-10', 11500.00, 'Operasyon', 'Operasyon Uzmanı'),
(12, 24, '2022-09-15', 13500.00, 'Satış', 'Satış Temsilcisi');

-- --------------------------------------------------------

--
-- Table structure for table `rehberler`
--

CREATE TABLE `rehberler` (
  `rehber_id` int NOT NULL,
  `personel_id` int NOT NULL,
  `bildigi_diller` varchar(200) COLLATE utf8mb4_turkish_ci DEFAULT NULL,
  `deneyim_yili` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `rehberler`
--

INSERT INTO `rehberler` (`rehber_id`, `personel_id`, `bildigi_diller`, `deneyim_yili`) VALUES
(1, 1, 'Türkçe, İngilizce', 6),
(2, 2, 'Türkçe, İngilizce, Almanca', 3),
(3, 3, 'Türkçe, İngilizce, Fransızca', 7),
(4, 4, 'Türkçe, İngilizce, İspanyolca', 4),
(5, 5, 'Türkçe, İngilizce, Rusça', 6),
(6, 6, 'Türkçe, İngilizce, Arapça', 2),
(7, 7, 'Türkçe, İngilizce, İtalyanca', 8),
(8, 8, 'Türkçe, İngilizce, Çince', 3),
(9, 9, 'Türkçe, İngilizce, Japonca', 5),
(10, 10, 'Türkçe, İngilizce, Yunanca', 4),
(11, 11, 'Türkçe, İngilizce, Portekizce', 6),
(12, 12, 'Türkçe, İngilizce, Felemenkçe', 2);

-- --------------------------------------------------------

--
-- Table structure for table `rehberler_seyahat_programlari`
--

CREATE TABLE `rehberler_seyahat_programlari` (
  `rehber_id` int NOT NULL,
  `program_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `rehberler_seyahat_programlari`
--

INSERT INTO `rehberler_seyahat_programlari` (`rehber_id`, `program_id`) VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 3),
(3, 4),
(4, 4),
(4, 5),
(5, 5),
(5, 6),
(6, 6),
(6, 7),
(7, 7),
(7, 8),
(8, 8),
(8, 9),
(9, 9),
(9, 10),
(10, 10),
(10, 11),
(11, 11),
(11, 12),
(12, 12);

-- --------------------------------------------------------

--
-- Table structure for table `rezervasyonlar`
--

CREATE TABLE `rezervasyonlar` (
  `rezervasyon_id` int NOT NULL,
  `program_id` int NOT NULL,
  `otel_id` int NOT NULL,
  `rezervasyon_tarihi` datetime DEFAULT CURRENT_TIMESTAMP,
  `tur_baslangic_tarihi` date NOT NULL,
  `tur_bitis_tarihi` date NOT NULL,
  `kisi_sayisi` int NOT NULL,
  `toplam_ucret` decimal(10,2) NOT NULL,
  `odeme_durumu` varchar(20) DEFAULT 'Beklemede'
) ;

--
-- Dumping data for table `rezervasyonlar`
--

INSERT INTO `rezervasyonlar` (`rezervasyon_id`, `program_id`, `otel_id`, `rezervasyon_tarihi`, `tur_baslangic_tarihi`, `tur_bitis_tarihi`, `kisi_sayisi`, `toplam_ucret`, `odeme_durumu`) VALUES
(1, 2, 1, '2025-12-20 00:01:07', '2025-06-01', '2025-06-03', 3, 7000.00, 'Tamamlandi'),
(2, 2, 2, '2025-12-20 00:01:07', '2025-07-10', '2025-07-15', 1, 4800.00, 'Tamamlandi'),
(3, 3, 3, '2025-12-20 00:01:07', '2025-08-05', '2025-08-12', 3, 12600.00, 'Tamamlandi'),
(4, 4, 4, '2025-12-20 00:01:07', '2025-05-15', '2025-05-18', 2, 5600.00, 'Tamamlandi'),
(5, 5, 5, '2025-12-20 00:01:07', '2025-07-20', '2025-07-25', 4, 22000.00, 'Tamamlandi'),
(6, 6, 6, '2025-12-20 00:01:07', '2025-09-01', '2025-09-08', 2, 9676.80, 'Beklemede'),
(7, 7, 7, '2025-12-20 00:01:07', '2025-08-15', '2025-08-22', 1, 4500.00, 'Tamamlandi'),
(8, 8, 8, '2025-12-20 00:01:07', '2025-06-20', '2025-06-25', 3, 9600.00, 'Tamamlandi'),
(9, 9, 9, '2025-12-20 00:01:07', '2025-07-05', '2025-07-12', 2, 10400.00, 'Beklemede'),
(10, 10, 10, '2025-12-20 00:01:07', '2025-09-10', '2025-09-17', 1, 4000.00, 'Tamamlandi'),
(11, 11, 11, '2025-12-20 00:01:07', '2025-08-01', '2025-08-07', 2, 6120.00, 'Beklemede'),
(12, 12, 12, '2025-12-20 00:01:07', '2025-07-10', '2025-07-15', 1, 2400.00, 'Tamamlandi'),
(13, 1, 1, '2025-12-20 00:01:07', '2025-06-01', '2025-06-03', 1, 3500.00, 'Tamamlandi'),
(14, 5, 5, '2025-12-20 00:01:07', '2025-07-20', '2025-07-25', 2, 11000.00, 'Beklemede');

--
-- Triggers `rezervasyonlar`
--
DELIMITER $$
CREATE TRIGGER `trg_maksimum_katilimci_kontrolu` BEFORE INSERT ON `rezervasyonlar` FOR EACH ROW BEGIN
    DECLARE v_mevcut_katilimci INT;
    DECLARE v_max_katilimci INT;
    
    SELECT mevcut_katilimci_sayisi, max_katilimci_sayisi
    INTO v_mevcut_katilimci, v_max_katilimci
    FROM seyahat_programlari
    WHERE program_id = NEW.program_id;
    
    IF (v_mevcut_katilimci + NEW.kisi_sayisi) > v_max_katilimci THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'HATA: Maksimum katılımcı sayısı aşıldı!';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_rezervasyon_ekleme_sonrasi_katilimci_guncelleme` AFTER INSERT ON `rezervasyonlar` FOR EACH ROW BEGIN
    UPDATE seyahat_programlari
    SET mevcut_katilimci_sayisi = mevcut_katilimci_sayisi + NEW.kisi_sayisi
    WHERE program_id = NEW.program_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_rezervasyon_silme_sonrasi_katilimci_guncelleme` BEFORE DELETE ON `rezervasyonlar` FOR EACH ROW BEGIN
    UPDATE seyahat_programlari
    SET mevcut_katilimci_sayisi = GREATEST(0, mevcut_katilimci_sayisi - OLD.kisi_sayisi)
    WHERE program_id = OLD.program_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sehirler`
--

CREATE TABLE `sehirler` (
  `sehir_id` int NOT NULL,
  `sehir_adi` varchar(50) COLLATE utf8mb4_turkish_ci NOT NULL,
  `ulke` varchar(50) COLLATE utf8mb4_turkish_ci DEFAULT 'Türkiye'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `sehirler`
--

INSERT INTO `sehirler` (`sehir_id`, `sehir_adi`, `ulke`) VALUES
(1, 'Adana', 'Türkiye'),
(2, 'Adıyaman', 'Türkiye'),
(3, 'Afyonkarahisar', 'Türkiye'),
(4, 'Ağrı', 'Türkiye'),
(5, 'Amasya', 'Türkiye'),
(6, 'Ankara', 'Türkiye'),
(7, 'Antalya', 'Türkiye'),
(8, 'Artvin', 'Türkiye'),
(9, 'Aydın', 'Türkiye'),
(10, 'Balıkesir', 'Türkiye'),
(11, 'Bilecik', 'Türkiye'),
(12, 'Bingöl', 'Türkiye'),
(13, 'Bitlis', 'Türkiye'),
(14, 'Bolu', 'Türkiye'),
(15, 'Burdur', 'Türkiye'),
(16, 'Bursa', 'Türkiye'),
(17, 'Çanakkale', 'Türkiye'),
(18, 'Çankırı', 'Türkiye'),
(19, 'Çorum', 'Türkiye'),
(20, 'Denizli', 'Türkiye'),
(21, 'Diyarbakır', 'Türkiye'),
(22, 'Edirne', 'Türkiye'),
(23, 'Elazığ', 'Türkiye'),
(24, 'Erzincan', 'Türkiye'),
(25, 'Erzurum', 'Türkiye'),
(26, 'Eskişehir', 'Türkiye'),
(27, 'Gaziantep', 'Türkiye'),
(28, 'Giresun', 'Türkiye'),
(29, 'Gümüşhane', 'Türkiye'),
(30, 'Hakkari', 'Türkiye'),
(31, 'Hatay', 'Türkiye'),
(32, 'Isparta', 'Türkiye'),
(33, 'Mersin', 'Türkiye'),
(34, 'İstanbul', 'Türkiye'),
(35, 'İzmir', 'Türkiye'),
(36, 'Kars', 'Türkiye'),
(37, 'Kastamonu', 'Türkiye'),
(38, 'Kayseri', 'Türkiye'),
(39, 'Kırklareli', 'Türkiye'),
(40, 'Kırşehir', 'Türkiye'),
(41, 'Kocaeli', 'Türkiye'),
(42, 'Konya', 'Türkiye'),
(43, 'Kütahya', 'Türkiye'),
(44, 'Malatya', 'Türkiye'),
(45, 'Manisa', 'Türkiye'),
(46, 'Kahramanmaraş', 'Türkiye'),
(47, 'Mardin', 'Türkiye'),
(48, 'Muğla', 'Türkiye'),
(49, 'Muş', 'Türkiye'),
(50, 'Nevşehir', 'Türkiye'),
(51, 'Niğde', 'Türkiye'),
(52, 'Ordu', 'Türkiye'),
(53, 'Rize', 'Türkiye'),
(54, 'Sakarya', 'Türkiye'),
(55, 'Samsun', 'Türkiye'),
(56, 'Siirt', 'Türkiye'),
(57, 'Sinop', 'Türkiye'),
(58, 'Sivas', 'Türkiye'),
(59, 'Tekirdağ', 'Türkiye'),
(60, 'Tokat', 'Türkiye'),
(61, 'Trabzon', 'Türkiye'),
(62, 'Tunceli', 'Türkiye'),
(63, 'Şanlıurfa', 'Türkiye'),
(64, 'Uşak', 'Türkiye'),
(65, 'Van', 'Türkiye'),
(66, 'Yozgat', 'Türkiye'),
(67, 'Zonguldak', 'Türkiye'),
(68, 'Aksaray', 'Türkiye'),
(69, 'Bayburt', 'Türkiye'),
(70, 'Karaman', 'Türkiye'),
(71, 'Kırıkkale', 'Türkiye'),
(72, 'Batman', 'Türkiye'),
(73, 'Şırnak', 'Türkiye'),
(74, 'Bartın', 'Türkiye'),
(75, 'Ardahan', 'Türkiye'),
(76, 'Iğdır', 'Türkiye'),
(77, 'Yalova', 'Türkiye'),
(78, 'Karabük', 'Türkiye'),
(79, 'Kilis', 'Türkiye'),
(80, 'Osmaniye', 'Türkiye'),
(81, 'Düzce', 'Türkiye');

-- --------------------------------------------------------

--
-- Table structure for table `seyahat_programlari`
--

CREATE TABLE `seyahat_programlari` (
  `program_id` int NOT NULL,
  `tur_adi` varchar(100) NOT NULL,
  `baslangic_tarihi` date NOT NULL,
  `bitis_tarihi` date NOT NULL,
  `kalkis_noktasi` varchar(100) DEFAULT NULL,
  `varis_noktasi` varchar(100) DEFAULT NULL,
  `max_katilimci_sayisi` int DEFAULT '30',
  `mevcut_katilimci_sayisi` int DEFAULT '0',
  `fiyat` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `seyahat_programlari`
--

INSERT INTO `seyahat_programlari` (`program_id`, `tur_adi`, `baslangic_tarihi`, `bitis_tarihi`, `kalkis_noktasi`, `varis_noktasi`, `max_katilimci_sayisi`, `mevcut_katilimci_sayisi`, `fiyat`) VALUES
(1, 'Kapadokya Balon Turu', '2025-06-01', '2025-06-03', 'İstanbul', 'Nevşehir', 20, 0, 3500.00),
(2, 'Ege Kıyıları Turu', '2025-07-10', '2025-07-15', 'İstanbul', 'İzmir', 30, 3, 4800.00),
(3, 'Akdeniz Turu', '2025-08-05', '2025-08-12', 'Ankara', 'Antalya', 25, 0, 4200.00),
(4, 'Karadeniz Turu', '2025-05-15', '2025-05-18', 'İstanbul', 'Trabzon', 20, 0, 2800.00),
(5, 'Doğu Anadolu Turu', '2025-07-20', '2025-07-25', 'Ankara', 'Van', 15, 0, 5500.00),
(6, 'Güneydoğu Anadolu Turu', '2025-09-01', '2025-09-08', 'İstanbul', 'Şanlıurfa', 18, 0, 3800.00),
(7, 'Marmara Bölgesi Turu', '2025-08-15', '2025-08-22', 'İstanbul', 'Bursa', 30, 0, 4500.00),
(8, 'İç Anadolu Turu', '2025-06-20', '2025-06-25', 'Ankara', 'Konya', 25, 0, 3200.00),
(9, 'Akdeniz Kıyıları Turu', '2025-07-05', '2025-07-12', 'İzmir', 'Antalya', 30, 0, 5200.00),
(10, 'Ege Adaları Turu', '2025-09-10', '2025-09-17', 'İzmir', 'Muğla', 20, 0, 4000.00),
(11, 'Karadeniz Kıyıları Turu', '2025-08-01', '2025-08-07', 'Trabzon', 'Rize', 15, 0, 3600.00),
(12, 'Doğu Karadeniz Turu', '2025-07-10', '2025-07-15', 'Trabzon', 'Artvin', 12, 0, 2400.00);

-- --------------------------------------------------------

--
-- Table structure for table `seyahat_programlari_sehirler`
--

CREATE TABLE `seyahat_programlari_sehirler` (
  `program_id` int NOT NULL,
  `sehir_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_turkish_ci;

--
-- Dumping data for table `seyahat_programlari_sehirler`
--

INSERT INTO `seyahat_programlari_sehirler` (`program_id`, `sehir_id`) VALUES
(2, 6),
(3, 7),
(5, 7),
(9, 7),
(12, 8),
(4, 16),
(7, 16),
(1, 34),
(2, 35),
(3, 35),
(8, 42),
(9, 42),
(10, 48),
(1, 50),
(11, 53),
(4, 61),
(6, 61),
(6, 63),
(8, 63),
(5, 65),
(7, 65);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `kullanicilar`
--
ALTER TABLE `kullanicilar`
  ADD PRIMARY KEY (`kullanici_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `sehir_id` (`sehir_id`);

--
-- Indexes for table `musteriler`
--
ALTER TABLE `musteriler`
  ADD PRIMARY KEY (`musteri_id`),
  ADD UNIQUE KEY `kullanici_id` (`kullanici_id`),
  ADD UNIQUE KEY `tckn` (`tckn`);

--
-- Indexes for table `musteriler_rezervasyonlar`
--
ALTER TABLE `musteriler_rezervasyonlar`
  ADD PRIMARY KEY (`musteri_id`,`rezervasyon_id`),
  ADD KEY `rezervasyon_id` (`rezervasyon_id`);

--
-- Indexes for table `oteller`
--
ALTER TABLE `oteller`
  ADD PRIMARY KEY (`otel_id`);

--
-- Indexes for table `oteller_sehirler`
--
ALTER TABLE `oteller_sehirler`
  ADD PRIMARY KEY (`otel_id`,`sehir_id`),
  ADD KEY `sehir_id` (`sehir_id`);

--
-- Indexes for table `personeller`
--
ALTER TABLE `personeller`
  ADD PRIMARY KEY (`personel_id`),
  ADD UNIQUE KEY `kullanici_id` (`kullanici_id`);

--
-- Indexes for table `rehberler`
--
ALTER TABLE `rehberler`
  ADD PRIMARY KEY (`rehber_id`),
  ADD KEY `personel_id` (`personel_id`);

--
-- Indexes for table `rehberler_seyahat_programlari`
--
ALTER TABLE `rehberler_seyahat_programlari`
  ADD PRIMARY KEY (`rehber_id`,`program_id`),
  ADD KEY `program_id` (`program_id`);

--
-- Indexes for table `rezervasyonlar`
--
ALTER TABLE `rezervasyonlar`
  ADD PRIMARY KEY (`rezervasyon_id`),
  ADD KEY `program_id` (`program_id`),
  ADD KEY `otel_id` (`otel_id`);

--
-- Indexes for table `sehirler`
--
ALTER TABLE `sehirler`
  ADD PRIMARY KEY (`sehir_id`),
  ADD UNIQUE KEY `sehir_adi` (`sehir_adi`);

--
-- Indexes for table `seyahat_programlari`
--
ALTER TABLE `seyahat_programlari`
  ADD PRIMARY KEY (`program_id`),
  ADD UNIQUE KEY `tur_adi` (`tur_adi`);

--
-- Indexes for table `seyahat_programlari_sehirler`
--
ALTER TABLE `seyahat_programlari_sehirler`
  ADD PRIMARY KEY (`program_id`,`sehir_id`),
  ADD KEY `sehir_id` (`sehir_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `kullanicilar`
--
ALTER TABLE `kullanicilar`
  MODIFY `kullanici_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `musteriler`
--
ALTER TABLE `musteriler`
  MODIFY `musteri_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `oteller`
--
ALTER TABLE `oteller`
  MODIFY `otel_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personeller`
--
ALTER TABLE `personeller`
  MODIFY `personel_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `rehberler`
--
ALTER TABLE `rehberler`
  MODIFY `rehber_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `rezervasyonlar`
--
ALTER TABLE `rezervasyonlar`
  MODIFY `rezervasyon_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seyahat_programlari`
--
ALTER TABLE `seyahat_programlari`
  MODIFY `program_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `kullanicilar`
--
ALTER TABLE `kullanicilar`
  ADD CONSTRAINT `kullanicilar_ibfk_1` FOREIGN KEY (`sehir_id`) REFERENCES `sehirler` (`sehir_id`) ON DELETE SET NULL;

--
-- Constraints for table `musteriler`
--
ALTER TABLE `musteriler`
  ADD CONSTRAINT `musteriler_ibfk_1` FOREIGN KEY (`kullanici_id`) REFERENCES `kullanicilar` (`kullanici_id`) ON DELETE CASCADE;

--
-- Constraints for table `musteriler_rezervasyonlar`
--
ALTER TABLE `musteriler_rezervasyonlar`
  ADD CONSTRAINT `musteriler_rezervasyonlar_ibfk_1` FOREIGN KEY (`musteri_id`) REFERENCES `musteriler` (`musteri_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `musteriler_rezervasyonlar_ibfk_2` FOREIGN KEY (`rezervasyon_id`) REFERENCES `rezervasyonlar` (`rezervasyon_id`) ON DELETE CASCADE;

--
-- Constraints for table `oteller_sehirler`
--
ALTER TABLE `oteller_sehirler`
  ADD CONSTRAINT `oteller_sehirler_ibfk_1` FOREIGN KEY (`otel_id`) REFERENCES `oteller` (`otel_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `oteller_sehirler_ibfk_2` FOREIGN KEY (`sehir_id`) REFERENCES `sehirler` (`sehir_id`) ON DELETE CASCADE;

--
-- Constraints for table `personeller`
--
ALTER TABLE `personeller`
  ADD CONSTRAINT `personeller_ibfk_1` FOREIGN KEY (`kullanici_id`) REFERENCES `kullanicilar` (`kullanici_id`) ON DELETE CASCADE;

--
-- Constraints for table `rehberler`
--
ALTER TABLE `rehberler`
  ADD CONSTRAINT `rehberler_ibfk_1` FOREIGN KEY (`personel_id`) REFERENCES `personeller` (`personel_id`) ON DELETE CASCADE;

--
-- Constraints for table `rehberler_seyahat_programlari`
--
ALTER TABLE `rehberler_seyahat_programlari`
  ADD CONSTRAINT `rehberler_seyahat_programlari_ibfk_1` FOREIGN KEY (`rehber_id`) REFERENCES `rehberler` (`rehber_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rehberler_seyahat_programlari_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `seyahat_programlari` (`program_id`) ON DELETE CASCADE;

--
-- Constraints for table `rezervasyonlar`
--
ALTER TABLE `rezervasyonlar`
  ADD CONSTRAINT `rezervasyonlar_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `seyahat_programlari` (`program_id`),
  ADD CONSTRAINT `rezervasyonlar_ibfk_2` FOREIGN KEY (`otel_id`) REFERENCES `oteller` (`otel_id`);

--
-- Constraints for table `seyahat_programlari_sehirler`
--
ALTER TABLE `seyahat_programlari_sehirler`
  ADD CONSTRAINT `seyahat_programlari_sehirler_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `seyahat_programlari` (`program_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `seyahat_programlari_sehirler_ibfk_2` FOREIGN KEY (`sehir_id`) REFERENCES `sehirler` (`sehir_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
