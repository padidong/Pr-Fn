-- Create database
CREATE DATABASE IF NOT EXISTS per_fn;
USE per_fn;

-- Table: polling_station
CREATE TABLE IF NOT EXISTS polling_station (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    zone VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL
);

-- Table: violation_type
CREATE TABLE IF NOT EXISTS violation_type (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL,
    severity VARCHAR(50) NOT NULL
);

-- Table: incident_report
CREATE TABLE IF NOT EXISTS incident_report (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    station_id INT NOT NULL,
    type_id INT NOT NULL,
    reporter_name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    evidence_photo VARCHAR(500) NULL,
    timestamp DATETIME NOT NULL,
    ai_result VARCHAR(100) NULL,
    ai_confidence DECIMAL(5,2) NULL,
    FOREIGN KEY (station_id) REFERENCES polling_station(station_id),
    FOREIGN KEY (type_id) REFERENCES violation_type(type_id)
);

-- Sample data: polling stations
INSERT INTO polling_station (station_id, station_name, zone, province) VALUES
(101, 'โรงเรียนวัดพระมหาธาตุ', 'เขต 1', 'นครศรีธรรมราช'),
(102, 'เต็นท์หน้าตลาดท่าวัง', 'เขต 1', 'นครศรีธรรมราช'),
(103, 'ศาลากลางหมู่บ้านคีรีวง', 'เขต 2', 'นครศรีธรรมราช'),
(104, 'หอประชุมอำเภอทุ่งสง', 'เขต 3', 'นครศรีธรรมราช');

-- Sample data: violation types
INSERT INTO violation_type (type_id, type_name, severity) VALUES
(1, 'ซื้อสิทธิ์ขายเสียง (Buying Votes)', 'High'),
(2, 'ขนคนไปลงคะแนน (Transportation)', 'High'),
(3, 'หาเสียงเกินเวลา (Overtime Campaign)', 'Medium'),
(4, 'ทำลายป้ายหาเสียง (Vandalism)', 'Low'),
(5, 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)', 'High');
