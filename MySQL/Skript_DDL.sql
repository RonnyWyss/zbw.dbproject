DROP DATABASE IF EXISTS inventarisierungsloesung;

CREATE DATABASE IF NOT EXISTS Inventarisierungsloesung
CHARACTER SET utf8;

USE Inventarisierungsloesung;

CREATE TABLE IF NOT EXISTS Town (
town_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
zip INT UNSIGNED NOT NULL,
town VARCHAR(100));

CREATE TABLE IF NOT EXISTS Address (
address_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
town_fk INT UNSIGNED NOT NULL,
streetname VARCHAR(100) NOT NULL,
streetnumber VARCHAR(25) NOT NULL,
country VARCHAR(45) NOT NULL,
additive VARCHAR(45),
po_Box INT UNSIGNED,
FOREIGN KEY (town_fk) REFERENCES Town(town_id)ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Person (
person_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT,
firstname VARCHAR(45) NOT NULL,
lastname VARCHAR(45) NOT NULL);

CREATE Table IF NOT EXISTS Kundenkonto (
kundenkonto_id INT UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT);

CREATE Table IF NOT EXISTS Customer (
person_fk INT UNSIGNED NOT NULL,
address_fk INT UNSIGNED NOT NULL,
kundenkonto_fk INT UNSIGNED NOT NULL,
tel VARCHAR(20),
eMail VARCHAR(30),
url VARCHAR(30),
FOREIGN KEY (person_fk) REFERENCES Person(Person_id) ON DELETE CASCADE,
FOREIGN KEY (address_fk) REFERENCES Address(address_id) ON DELETE CASCADE,
FOREIGN KEY (kundenkonto_fk) REFERENCES Kundenkonto(kundenkonto_id) ON DELETE CASCADE);

CREATE TABLE IF NOT EXISTS Location (
location_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
address_fk INT UNSIGNED NOT NULL,
designation VARCHAR(45) NOT NULL,
building INT UNSIGNED NOT NULL,
room INT UNSIGNED NOT NULL,
FOREIGN KEY (address_fk) REFERENCES Address(address_id)ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Contact (
contact_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
person_fk INT UNSIGNED NOT NULL,
priority ENUM('First Priority','Second Priority','Emergency Contact') NOT NULL,
FOREIGN KEY (person_fk) REFERENCES Person(person_id)ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS PointOfDelivery (
pod_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
customer_person_fk INT UNSIGNED NOT NULL,
contact_person_fk INT UNSIGNED NOT NULL,
location_fk INT UNSIGNED NOT NULL,
designation VARCHAR(45),
timezone TIME NOT NULL,
timeZonePositiv TINYINT NOT NULL,
ntpServerIp VARCHAR(20),
FOREIGN KEY (`customer_person_fk`) REFERENCES `customer`(`person_fk`)ON DELETE CASCADE,
FOREIGN KEY (`contact_person_fk`) REFERENCES `contact`(`contact_id`)ON DELETE CASCADE,
FOREIGN KEY (`location_fk`) REFERENCES `location`(`location_id`) ON DELETE CASCADE
);

CREATE Table IF NOT EXISTS DevicesTypes (
deviceTypes_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
manifacture VARCHAR(255) NOT NULL,
model VARCHAR(255) NOT NULL,
version VARCHAR(255) NOT NULL,
PRIMARY KEY(deviceTypes_id)
);

CREATE Table IF NOT EXISTS Devices (
device_id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
location_fk INT UNSIGNED NOT NULL,
deviceTypes_fk INT UNSIGNED NOT NULL,
inventoryDate DATE NOT NULL,
deactivateDate DATE NOT NULL,
hostname VARCHAR(255),
domain VARCHAR(255),
description VARCHAR(255),
FOREIGN KEY (location_fk) REFERENCES Location(location_id) ON DELETE CASCADE,
FOREIGN KEY (deviceTypes_fk) REFERENCES DevicesTypes(deviceTypes_id) ON DELETE CASCADE
);

CREATE Table IF NOT EXISTS Operatingsystem (
operatingsystem_id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
operatingsystemName VARCHAR(255) NOT NULL,
model VARCHAR(255) NOT NULL,
version VARCHAR(255)
);

CREATE Table IF NOT EXISTS DevicesTypes_has_operatingsystem (
deviceTypes_fk INT UNSIGNED NOT NULL,
operatingsystem_fk INT UNSIGNED NOT NULL,
PRIMARY KEY(deviceTypes_fk,operatingsystem_fk),
FOREIGN KEY (deviceTypes_fk) REFERENCES DevicesTypes(deviceTypes_id) ON DELETE CASCADE,
FOREIGN KEY (operatingsystem_fk) REFERENCES Operatingsystem(operatingsystem_id) ON DELETE CASCADE
);

CREATE Table IF NOT EXISTS Log (
log_id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY,
device_fk INT UNSIGNED NOT NULL,
timestamp DATETIME NOT NULL,
logMessage VARCHAR(255) NOT NULL,
level ENUM('Low','Middle','High') NOT NULL,
FOREIGN KEY (device_fk) REFERENCES Devices(device_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Network (
  network_id INT NOT NULL AUTO_INCREMENT,
  subnet VARCHAR(15) NOT NULL,
  mask VARCHAR(15) NOT NULL,
  vlan INT NOT NULL DEFAULT 1,
  description VARCHAR(255) NULL,
  PRIMARY KEY (network_id));

CREATE TABLE IF NOT EXISTS DeviceTypes (
  deviceTypes_id INT NOT NULL AUTO_INCREMENT,
  manifacturer VARCHAR(255) NOT NULL,
  model VARCHAR(255) NOT NULL,
  version VARCHAR(255) NULL,
  PRIMARY KEY (deviceTypes_id)
  );


CREATE TABLE IF NOT EXISTS Credentials (
  credentials_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  benutzername VARCHAR(255) NOT NULL,
  passwort VARCHAR(255) NOT NULL,
  snmp VARCHAR(255) NOT NULL,
  PRIMARY KEY (credentials_id) 
  );
  
CREATE TABLE IF NOT EXISTS Interfaces (
  interface_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  network_id_fk INT NOT NULL,
  devices_id_fk INT UNSIGNED NOT NULL,
  ip_adress_v4 VARCHAR(15) NOT NULL,
  isFullDuplex BIT(1) NOT NULL DEFAULT 1,
  bandwith INT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY (interface_id),
  FOREIGN KEY (network_id_fk) REFERENCES Network (network_id)ON DELETE CASCADE,
  FOREIGN KEY (devices_id_fk) REFERENCES Devices (device_id)ON DELETE CASCADE
  );

  CREATE TABLE IF NOT EXISTS Abrechnung (
  abrechnung_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kundenkonto_fk INT UNSIGNED NOT NULL,
  location_fk INT UNSIGNED NOT NULL,
  device_fk INT UNSIGNED NOT NULL,
  interface_fk INT UNSIGNED NOT NULL,
  PRIMARY KEY (abrechnung_id),
  FOREIGN KEY (kundenkonto_fk) REFERENCES Kundenkonto (kundenkonto_id)ON DELETE CASCADE,
  FOREIGN KEY (location_fk) REFERENCES Location (location_id)ON DELETE CASCADE,
  FOREIGN KEY (device_fk) REFERENCES Devices (device_id)ON DELETE CASCADE,
  FOREIGN KEY (interface_fk) REFERENCES Interfaces (interface_id)ON DELETE CASCADE
  );
  
CREATE TABLE IF NOT EXISTS SoftwareDienstleistung (
  software_id INT NOT NULL AUTO_INCREMENT,
  stundenaufwand INT NOT NULL,
  abrechung_fk INT UNSIGNED NOT NULL,
  PRIMARY KEY (software_id),
  Foreign Key (abrechung_fk) REFERENCES Abrechnung(abrechnung_id) ON DELETE CASCADE);
  
CREATE TABLE IF NOT EXISTS Produktegruppe (
  produktegruppe_id INT NOT NULL AUTO_INCREMENT,
  hardware VARCHAR(255),
  software VARCHAR(255),
  sonstigeArtikel VARCHAR(255),
  abrechung_fk INT UNSIGNED NOT NULL,
  PRIMARY KEY (produktegruppe_id),
  Foreign Key (abrechung_fk) REFERENCES Abrechnung(abrechnung_id)ON DELETE CASCADE
  );
  
CREATE TABLE IF NOT EXISTS Produkte (
  artikelnummer_id INT NOT NULL AUTO_INCREMENT,
  artikelname VARCHAR(255) NOT NULL,
  preis FLOAT NOT NULL,
  produktegruppe_fk INT NOT NULL,
  PRIMARY KEY (artikelnummer_id),
  Foreign Key (produktegruppe_fk) REFERENCES Produktegruppe(produktegruppe_id)ON DELETE CASCADE
  );

  CREATE TABLE IF NOT EXISTS Devices_has_Credentials (
  devices_devices_id INT UNSIGNED NOT NULL,
  credentials_credentials_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (devices_devices_id, credentials_credentials_id),
  FOREIGN KEY (devices_devices_id) REFERENCES Devices (device_id) ON DELETE CASCADE,
  FOREIGN KEY (credentials_credentials_id) REFERENCES Credentials (credentials_id) ON DELETE CASCADE
  ); 