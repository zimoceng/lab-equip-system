USE lab_equip_db;

-- 1) 用户表：专门人员/领导
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN','LEADER') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2) 类别计数器：生成“类别+顺序号”
DROP TABLE IF EXISTS category_counter;
CREATE TABLE category_counter (
  category_code VARCHAR(20) PRIMARY KEY,
  current_no INT NOT NULL DEFAULT 0
);

-- 3) 设备表
DROP TABLE IF EXISTS equipment;
CREATE TABLE equipment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  equip_no VARCHAR(30) NOT NULL UNIQUE,             -- ELE-0001
  category_code VARCHAR(20) NOT NULL,
  category_name VARCHAR(50) NOT NULL,
  name VARCHAR(100) NOT NULL,
  model VARCHAR(100),
  spec VARCHAR(200),
  unit_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  qty INT NOT NULL DEFAULT 1,
  purchase_date DATE NOT NULL,
  manufacturer VARCHAR(100),
  warranty_months INT DEFAULT 0,
  operator VARCHAR(50) NOT NULL,
  status ENUM('NORMAL','REPAIR','SCRAP') NOT NULL DEFAULT 'NORMAL',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_category (category_code),
  INDEX idx_purchase_date (purchase_date)
);

-- 4) 维修记录表（多条对应一台设备）
DROP TABLE IF EXISTS repair_record;
CREATE TABLE repair_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  equip_no VARCHAR(30) NOT NULL,
  repair_date DATE NOT NULL,
  vendor VARCHAR(100) NOT NULL,
  fee DECIMAL(10,2) NOT NULL DEFAULT 0,
  responsible VARCHAR(50) NOT NULL,
  note VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_repair_date (repair_date),
  CONSTRAINT fk_repair_equip FOREIGN KEY (equip_no) REFERENCES equipment(equip_no)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5) 报废记录表（一台设备通常最多 1 条）
DROP TABLE IF EXISTS scrap_record;
CREATE TABLE scrap_record (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  equip_no VARCHAR(30) NOT NULL UNIQUE,
  scrap_date DATE NOT NULL,
  reason VARCHAR(255) NOT NULL,
  handler VARCHAR(50) NOT NULL,
  leader VARCHAR(50) NOT NULL,
  approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_scrap_date (scrap_date),
  CONSTRAINT fk_scrap_equip FOREIGN KEY (equip_no) REFERENCES equipment(equip_no)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 6) 采购申请表
DROP TABLE IF EXISTS purchase_apply;
CREATE TABLE purchase_apply (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  category_code VARCHAR(20) NOT NULL,
  category_name VARCHAR(50) NOT NULL,
  equip_name VARCHAR(100) NOT NULL,
  qty INT NOT NULL DEFAULT 1,
  reason VARCHAR(255) NOT NULL,
  applicant VARCHAR(50) NOT NULL,
  apply_date DATE NOT NULL,
  status ENUM('PENDING','APPROVED','REJECTED','COMPLETED') NOT NULL DEFAULT 'PENDING',
  approver VARCHAR(50),
  approve_date DATE,
  completed_date DATE,
  remark VARCHAR(255),
  INDEX idx_apply_date (apply_date),
  INDEX idx_status (status)
);

-- 初始化类别计数器（示例）
INSERT INTO category_counter(category_code, current_no)
VALUES ('ELE', 0), ('CHEM', 0), ('PHY', 0)
ON DUPLICATE KEY UPDATE current_no = current_no;
