# Pre Final66106337 - Election Incident Reporter

ระบบแจ้งเหตุทุจริตเลือกตั้ง — Flutter CRUD + Node.js/Express + MySQL

## Features
- **View Polling Stations**: ดูรายการหน่วยเลือกตั้ง
- **View Violation Types**: ดูประเภทการทุจริตพร้อมระดับความรุนแรง
- **View Reports**: ดูรายการรายงานเหตุการณ์ทั้งหมด
- **Create Report**: สร้างรายงานเหตุการณ์ใหม่
- **AI Classification Demo**: จำลองการวิเคราะห์ด้วย AI
- **Material 3 Design**: UI ทันสมัยด้วย Material 3

## Important: Project Path
> **โปรเจกต์ต้องอยู่ใน path ที่ไม่มีตัวอักษรภาษาไทย** เช่น `C:\Final66106337`
> เนื่องจาก Java Gradle ไม่รองรับ Unicode path ทำให้ build Android ไม่ผ่าน
> หากโปรเจกต์อยู่บน OneDrive (`เดสก์ท็อป`) ให้คัดลอกไปที่ `C:\Final66106337` ก่อนรัน

---

## ขั้นตอนที่ 1: ติดตั้ง Database (MySQL)

### 1.1 ตรวจสอบว่า MySQL Server กำลังทำงาน
- เปิด **MySQL Workbench 8.0 CE** และเชื่อมต่อ MySQL Server (localhost:3306)
- หรือตรวจสอบผ่าน Command Prompt:
```bash
sc query mysql
```

### 1.2 สร้าง Database และข้อมูลจำลอง
**วิธีที่ 1 — ใช้ไฟล์ SQL อัตโนมัติ (แนะนำ):**
```bash
cd server
mysql -u root -pP19098_ppd#02 < setup.sql
```

**วิธีที่ 2 — รันทีละคำสั่งใน MySQL Workbench:**
```sql
CREATE DATABASE IF NOT EXISTS per_fn;
USE per_fn;

CREATE TABLE IF NOT EXISTS polling_station (
    station_id INT AUTO_INCREMENT PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    zone VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS violation_type (
    type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(255) NOT NULL,
    severity VARCHAR(50) NOT NULL
);

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

INSERT INTO polling_station (station_id, station_name, zone, province) VALUES
(101, 'โรงเรียนวัดพระมหาธาตุ', 'เขต 1', 'นครศรีธรรมราช'),
(102, 'เต็นท์หน้าตลาดท่าวัง', 'เขต 1', 'นครศรีธรรมราช'),
(103, 'ศาลากลางหมู่บ้านคีรีวง', 'เขต 2', 'นครศรีธรรมราช'),
(104, 'หอประชุมอำเภอทุ่งสง', 'เขต 3', 'นครศรีธรรมราช');

INSERT INTO violation_type (type_id, type_name, severity) VALUES
(1, 'ซื้อสิทธิ์ขายเสียง (Buying Votes)', 'High'),
(2, 'ขนคนไปลงคะแนน (Transportation)', 'High'),
(3, 'หาเสียงเกินเวลา (Overtime Campaign)', 'Medium'),
(4, 'ทำลายป้ายหาเสียง (Vandalism)', 'Low'),
(5, 'เจ้าหน้าที่วางตัวไม่เป็นกลาง (Bias Official)', 'High');
```

---

## ขั้นตอนที่ 2: ตั้งค่า API Server (Node.js/Express)

Backend อยู่ในโฟลเดอร์ `server/` ค่า connection ตั้งอยู่ในไฟล์ `server/.env`:
```
DB_HOST=localhost
DB_USER=root
DB_PASS=P19098_ppd#02
DB_NAME=per_fn
PORT=3000
```
หากต้องการเปลี่ยนค่า ให้แก้ไขที่ไฟล์ `server/.env`

### วิธีรัน API Server
```bash
cd server
npm install
node index.js
```
เมื่อสำเร็จจะแสดง:
```
Server running on http://localhost:3000
Database connected successfully
```
> หากเห็น `Database connection failed:` แสดงว่า MySQL มีปัญหา — ให้ตรวจสอบขั้นตอนที่ 1

### ทดสอบ API
- Health check: `http://localhost:3000/api/health`
- ดู stations: `http://localhost:3000/api/stations`
- ดู violation types: `http://localhost:3000/api/violation_types`
- ดู reports: `http://localhost:3000/api/reports`

---

## ขั้นตอนที่ 3: ตั้งค่า Flutter App

ค่า API URL ตั้งอยู่ที่ `lib/constants/api.dart`:
- **Android Emulator:** เปลี่ยนเป็น `http://10.0.2.2:3000/api`
- **iOS Simulator / Web:** `http://127.0.0.1:3000/api` (ค่าเริ่มต้น)
- **Physical Device:** เปลี่ยนเป็น IP ของเครื่องคอมพิวเตอร์ เช่น `http://192.168.x.x:3000/api`

---

## ขั้นตอนที่ 4: รัน Flutter App

### รันบน Web (Chrome)
```bash
flutter pub get
flutter run -d chrome
```

### รันบน Android Emulator
1. เปิด Android Emulator ผ่าน Android Studio
2. แก้ `lib/constants/api.dart` เป็น `http://10.0.2.2:3000/api`
3. รัน:
```bash
flutter pub get
flutter run
```

### รันบน Physical Device (USB)
1. เปิด Developer Options + USB Debugging บนมือถือ
2. ต่อสาย USB แล้วอนุญาต USB Debugging
3. แก้ `lib/constants/api.dart` เป็น IP ของคอมพิวเตอร์ เช่น `http://192.168.x.x:3000/api`
4. รัน:
```bash
flutter pub get
flutter run
```

---

## ขั้นตอนที่ 5: Build APK (สำหรับติดตั้งบนมือถือ Android)

### 5.1 Build APK แบบ Release
```bash
flutter pub get
flutter build apk --release
```
ไฟล์ APK จะอยู่ที่:
```
build\app\outputs\flutter-apk\app-release.apk
```

### 5.2 Build APK แบบแยกตาม CPU Architecture (ไฟล์เล็กกว่า)
```bash
flutter build apk --split-per-abi
```
ไฟล์ APK จะอยู่ที่ `build\app\outputs\flutter-apk\`:
- `app-armeabi-v7a-release.apk` — สำหรับมือถือ 32-bit (เก่า)
- `app-arm64-v8a-release.apk` — สำหรับมือถือ 64-bit (ส่วนใหญ่)
- `app-x86_64-release.apk` — สำหรับ Emulator

> **แนะนำ:** ใช้ `app-arm64-v8a-release.apk` สำหรับมือถือทั่วไป

### 5.3 ติดตั้ง APK บนมือถือ
**วิธีที่ 1 — ติดตั้งผ่าน ADB:**
```bash
adb install build\app\outputs\flutter-apk\app-release.apk
```

**วิธีที่ 2 — ติดตั้งด้วยมือ:**
1. คัดลอกไฟล์ `.apk` ไปยังมือถือ (ผ่าน USB หรือ Google Drive)
2. เปิดไฟล์ `.apk` บนมือถือ
3. อนุญาต "ติดตั้งจากแหล่งที่ไม่รู้จัก" (Install from Unknown Sources)
4. กด ติดตั้ง

### 5.4 ข้อควรระวังสำหรับ APK
- **API Server ต้องรันอยู่** — มือถือต้องเข้าถึง API Server ได้
- **แก้ API URL ก่อน build** — ใน `lib/constants/api.dart` ต้องใส่ IP ของเครื่อง server เช่น `http://192.168.x.x:3000/api` (ห้ามใช้ `localhost` หรือ `127.0.0.1`)
- **มือถือและคอมพิวเตอร์ต้องอยู่ WiFi เดียวกัน**
- หาก build ไม่ผ่าน ให้ลอง:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check (ไม่ต้องใช้ DB) |
| GET | `/api/stations` | ดูหน่วยเลือกตั้งทั้งหมด |
| GET | `/api/violation_types` | ดูประเภทการทุจริตทั้งหมด |
| GET | `/api/reports` | ดูรายงานทั้งหมด (พร้อม JOIN) |
| POST | `/api/create_report` | สร้างรายงานใหม่ |
| POST | `/api/update_ai` | อัปเดตผล AI |

---

## Project Structure
```
Final66106337/
├── lib/
│   ├── constants/
│   │   └── api.dart              # API URL configuration
│   ├── models/
│   │   ├── station.dart          # Station model
│   │   ├── violation_type.dart   # ViolationType model
│   │   └── incident_report.dart  # IncidentReport model
│   ├── screens/
│   │   ├── home_screen.dart      # หน้าแรก
│   │   ├── stations_screen.dart  # หน้าดูหน่วยเลือกตั้ง
│   │   ├── violation_types_screen.dart  # หน้าดูประเภทการทุจริต
│   │   ├── reports_screen.dart   # หน้าดูรายงาน
│   │   ├── report_form_screen.dart     # หน้าสร้างรายงาน
│   │   └── report_detail_screen.dart   # หน้ารายละเอียด + AI
│   ├── services/
│   │   └── api_service.dart      # API service (HTTP calls)
│   └── main.dart
├── server/
│   ├── index.js                  # Express server + routes
│   ├── db.js                     # MySQL connection pool
│   ├── .env                      # Database config
│   ├── setup.sql                 # Database setup script
│   └── package.json
├── pubspec.yaml
└── README.md
