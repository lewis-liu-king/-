-- =============================================
-- 航空部件生命周期与维修管理系统
-- 数据库建表脚本 (MySQL 8.0+)
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS aviation_component_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE aviation_component_management;

-- =============================================
-- 1. 创建基础表
-- =============================================

-- 操作人员表
CREATE TABLE IF NOT EXISTS Operator (
    operator_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,
    contact_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_operator_role (role),
    INDEX idx_operator_employee (employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 添加检查约束（MySQL 8.0.16+ 支持）
ALTER TABLE Operator 
ADD CONSTRAINT chk_operator_role 
CHECK (role IN ('technician', 'inspector', 'manager'));

-- 飞机表
CREATE TABLE IF NOT EXISTS Aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_number VARCHAR(50) NOT NULL UNIQUE,
    model VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    commission_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_aircraft_status (status),
    INDEX idx_aircraft_number (aircraft_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE Aircraft 
ADD CONSTRAINT chk_aircraft_status 
CHECK (status IN ('active', 'inactive'));

-- 部件型号表
CREATE TABLE IF NOT EXISTS ComponentModel (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_code VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(50) NOT NULL,
    design_life_hours INT,
    maintenance_interval_hours INT,
    applicable_aircraft_models TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_model_code (model_code),
    INDEX idx_model_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE ComponentModel 
ADD CONSTRAINT chk_design_life 
CHECK (design_life_hours IS NULL OR design_life_hours > 0);

ALTER TABLE ComponentModel 
ADD CONSTRAINT chk_maintenance_interval 
CHECK (maintenance_interval_hours IS NULL OR maintenance_interval_hours > 0);

-- 部件实例表
CREATE TABLE IF NOT EXISTS Component (
    component_id INT AUTO_INCREMENT PRIMARY KEY,
    component_serial VARCHAR(50) NOT NULL UNIQUE,
    model_id INT NOT NULL,
    batch_number VARCHAR(50),
    manufacture_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'available',
    total_usage_hours DECIMAL(10, 2) DEFAULT 0,
    is_retired TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_component_serial (component_serial),
    INDEX idx_component_status (status),
    INDEX idx_component_model (model_id),
    INDEX idx_component_retired (is_retired),
    FOREIGN KEY (model_id) REFERENCES ComponentModel(model_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE Component 
ADD CONSTRAINT chk_component_status 
CHECK (status IN ('available', 'installed', 'under_maintenance', 'retired'));

ALTER TABLE Component 
ADD CONSTRAINT chk_usage_hours 
CHECK (total_usage_hours >= 0);

-- 安装记录表
CREATE TABLE IF NOT EXISTS InstallationRecord (
    installation_id INT AUTO_INCREMENT PRIMARY KEY,
    component_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    installation_position VARCHAR(100) NOT NULL,
    installation_reason TEXT,
    installation_operator_id INT,
    installation_time DATETIME NOT NULL,
    removal_reason TEXT,
    removal_operator_id INT,
    removal_time DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_installation_component (component_id),
    INDEX idx_installation_aircraft (aircraft_id),
    INDEX idx_installation_time (installation_time),
    INDEX idx_installation_active (component_id, removal_time),
    FOREIGN KEY (component_id) REFERENCES Component(component_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (installation_operator_id) REFERENCES Operator(operator_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (removal_operator_id) REFERENCES Operator(operator_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 添加时间检查约束（MySQL 8.0.16+）
ALTER TABLE InstallationRecord 
ADD CONSTRAINT chk_installation_time 
CHECK (removal_time IS NULL OR removal_time >= installation_time);

-- 维修记录表
CREATE TABLE IF NOT EXISTS MaintenanceRecord (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    component_id INT NOT NULL,
    work_order_number VARCHAR(50) NOT NULL UNIQUE,
    maintenance_type VARCHAR(50) NOT NULL,
    description TEXT,
    operator_id INT,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    result VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_maintenance_component (component_id),
    INDEX idx_maintenance_start (start_time),
    INDEX idx_work_order (work_order_number),
    FOREIGN KEY (component_id) REFERENCES Component(component_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (operator_id) REFERENCES Operator(operator_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE MaintenanceRecord 
ADD CONSTRAINT chk_maintenance_type 
CHECK (maintenance_type IN ('routine', 'corrective', 'overhaul'));

ALTER TABLE MaintenanceRecord 
ADD CONSTRAINT chk_maintenance_result 
CHECK (result IS NULL OR result IN ('success', 'partial', 'failed'));

ALTER TABLE MaintenanceRecord 
ADD CONSTRAINT chk_maintenance_time 
CHECK (end_time IS NULL OR end_time >= start_time);

-- 飞行记录表
CREATE TABLE IF NOT EXISTS FlightLog (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    flight_number VARCHAR(50),
    mission_type VARCHAR(50) NOT NULL,
    departure_airport VARCHAR(100),
    arrival_airport VARCHAR(100),
    takeoff_time DATETIME NOT NULL,
    landing_time DATETIME,
    flight_duration_hours DECIMAL(6, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_flight_aircraft (aircraft_id),
    INDEX idx_flight_takeoff (takeoff_time),
    FOREIGN KEY (aircraft_id) REFERENCES Aircraft(aircraft_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE FlightLog 
ADD CONSTRAINT chk_flight_time 
CHECK (landing_time IS NULL OR landing_time >= takeoff_time);

-- 退役记录表
CREATE TABLE IF NOT EXISTS ScrapOrRetirementRecord (
    retirement_id INT AUTO_INCREMENT PRIMARY KEY,
    component_id INT NOT NULL UNIQUE,
    retirement_reason VARCHAR(100) NOT NULL,
    approval_operator_id INT,
    retirement_time DATETIME NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_retirement_component (component_id),
    FOREIGN KEY (component_id) REFERENCES Component(component_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (approval_operator_id) REFERENCES Operator(operator_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE ScrapOrRetirementRecord 
ADD CONSTRAINT chk_retirement_reason 
CHECK (retirement_reason IN ('end_of_life', 'irreparable', 'damage', 'other'));

-- =============================================
-- 2. 创建索引（安装唯一性约束）
-- =============================================

-- 部分唯一索引：同一部件在同一时刻只能有一条有效安装记录
-- MySQL 不支持部分索引的 WHERE 子句，需要通过唯一索引 + 触发器实现
CREATE UNIQUE INDEX idx_unique_active_installation 
ON InstallationRecord(component_id, installation_time);

-- =============================================
-- 3. 创建触发器
-- =============================================

-- 触发器函数 1: 防止物理删除核心数据
DELIMITER //

CREATE TRIGGER trigger_prevent_delete_component
BEFORE DELETE ON Component
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Cannot physically delete Component. Use status update instead.';
END//

CREATE TRIGGER trigger_prevent_delete_aircraft
BEFORE DELETE ON Aircraft
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Cannot physically delete Aircraft. Use status update instead.';
END//

CREATE TRIGGER trigger_prevent_delete_installation
BEFORE DELETE ON InstallationRecord
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Cannot physically delete InstallationRecord.';
END//

CREATE TRIGGER trigger_prevent_delete_maintenance
BEFORE DELETE ON MaintenanceRecord
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Cannot physically delete MaintenanceRecord.';
END//

CREATE TRIGGER trigger_prevent_delete_flight
BEFORE DELETE ON FlightLog
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Cannot physically delete FlightLog.';
END//

-- 触发器 2: 安装前检查部件状态
CREATE TRIGGER trigger_check_before_install
BEFORE INSERT ON InstallationRecord
FOR EACH ROW
BEGIN
    DECLARE v_component_status VARCHAR(30);
    DECLARE v_is_retired TINYINT(1);
    
    SELECT status, is_retired INTO v_component_status, v_is_retired
    FROM Component WHERE component_id = NEW.component_id;
    
    IF v_is_retired = 1 OR v_component_status = 'retired' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Component ', NEW.component_id, ' is retired and cannot be installed.');
    END IF;
END//

-- 触发器 3: 退役记录插入时同步部件状态
CREATE TRIGGER trigger_sync_retirement
AFTER INSERT ON ScrapOrRetirementRecord
FOR EACH ROW
BEGIN
    UPDATE Component
    SET status = 'retired',
        is_retired = 1
    WHERE component_id = NEW.component_id;
END//

-- 触发器 4: 防止对已退役部件创建新记录
CREATE TRIGGER trigger_prevent_install_on_retired
BEFORE INSERT ON InstallationRecord
FOR EACH ROW
BEGIN
    DECLARE v_is_retired TINYINT(1);
    
    SELECT is_retired INTO v_is_retired
    FROM Component WHERE component_id = NEW.component_id;
    
    IF v_is_retired = 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Component ', NEW.component_id, ' is retired, cannot create new installation record.');
    END IF;
END//

CREATE TRIGGER trigger_prevent_maintenance_on_retired
BEFORE INSERT ON MaintenanceRecord
FOR EACH ROW
BEGIN
    DECLARE v_is_retired TINYINT(1);
    
    SELECT is_retired INTO v_is_retired
    FROM Component WHERE component_id = NEW.component_id;
    
    IF v_is_retired = 1 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Component ', NEW.component_id, ' is retired, cannot create new maintenance record.');
    END IF;
END//

DELIMITER ;

-- =============================================
-- 4. 创建视图
-- =============================================

-- 视图 1: 部件当前状态视图
CREATE OR REPLACE VIEW v_component_current_status AS
SELECT 
    c.component_id,
    c.component_serial,
    cm.model_code,
    cm.category,
    c.status,
    c.is_retired,
    c.total_usage_hours,
    a.aircraft_number AS current_aircraft,
    ir.installation_position,
    ir.installation_time AS current_installation_time
FROM Component c
LEFT JOIN ComponentModel cm ON c.model_id = cm.model_id
LEFT JOIN InstallationRecord ir ON c.component_id = ir.component_id AND ir.removal_time IS NULL
LEFT JOIN Aircraft a ON ir.aircraft_id = a.aircraft_id;

-- 视图 2: 部件安装历史视图
CREATE OR REPLACE VIEW v_component_installation_history AS
SELECT 
    ir.installation_id,
    c.component_serial,
    a.aircraft_number,
    ir.installation_position,
    ir.installation_time,
    ir.removal_time,
    CASE 
        WHEN ir.removal_time IS NULL THEN 'Active'
        ELSE 'Historical'
    END AS record_type,
    COALESCE(
        TIMESTAMPDIFF(SECOND, ir.installation_time, COALESCE(ir.removal_time, NOW())) / 3600,
        0
    ) AS installed_duration_hours
FROM InstallationRecord ir
JOIN Component c ON ir.component_id = c.component_id
JOIN Aircraft a ON ir.aircraft_id = a.aircraft_id
ORDER BY ir.component_id, ir.installation_time DESC;

-- 视图 3: 部件生命周期汇总视图
CREATE OR REPLACE VIEW v_component_lifecycle_summary AS
SELECT 
    c.component_id,
    c.component_serial,
    cm.model_code,
    cm.category,
    c.status,
    c.is_retired,
    c.created_at AS received_time,
    COUNT(DISTINCT ir.installation_id) AS total_installations,
    COUNT(DISTINCT mr.maintenance_id) AS total_maintenances,
    CASE WHEN srr.retirement_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS is_retired_record,
    srr.retirement_reason,
    srr.retirement_time
FROM Component c
LEFT JOIN ComponentModel cm ON c.model_id = cm.model_id
LEFT JOIN InstallationRecord ir ON c.component_id = ir.component_id
LEFT JOIN MaintenanceRecord mr ON c.component_id = mr.component_id
LEFT JOIN ScrapOrRetirementRecord srr ON c.component_id = srr.component_id
GROUP BY c.component_id, cm.model_code, cm.category, srr.retirement_id, srr.retirement_reason, srr.retirement_time;

-- 视图 4: 统计分析视图
CREATE OR REPLACE VIEW v_model_maintenance_stats AS
SELECT 
    cm.model_code,
    cm.category,
    COUNT(DISTINCT c.component_id) AS total_components,
    COUNT(mr.maintenance_id) AS total_maintenances
FROM ComponentModel cm
LEFT JOIN Component c ON cm.model_id = c.model_id
LEFT JOIN MaintenanceRecord mr ON c.component_id = mr.component_id
GROUP BY cm.model_code, cm.category;

-- 视图 5: 飞机部件更换频率统计
CREATE OR REPLACE VIEW v_aircraft_component_changes AS
SELECT 
    a.aircraft_id,
    a.aircraft_number,
    a.model AS aircraft_model,
    COUNT(DISTINCT ir.component_id) AS unique_components_used,
    COUNT(ir.installation_id) AS total_installations
FROM Aircraft a
LEFT JOIN InstallationRecord ir ON a.aircraft_id = ir.aircraft_id
GROUP BY a.aircraft_id, a.aircraft_number, a.model;

-- 视图 6: 退役原因分布
CREATE OR REPLACE VIEW v_retirement_reason_distribution AS
SELECT 
    retirement_reason,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ScrapOrRetirementRecord), 2) AS percentage
FROM ScrapOrRetirementRecord
GROUP BY retirement_reason
ORDER BY count DESC;

-- =============================================
-- 5. 创建存储过程（事务实现）
-- =============================================

DELIMITER //

-- 存储过程 1: 部件安装
CREATE PROCEDURE sp_install_component(
    IN p_component_id INT,
    IN p_aircraft_id INT,
    IN p_position VARCHAR(100),
    IN p_reason TEXT,
    IN p_operator_id INT,
    IN p_installation_time DATETIME
)
BEGIN
    DECLARE v_aircraft_status VARCHAR(20);
    
    -- 检查飞机状态
    SELECT status INTO v_aircraft_status
    FROM Aircraft WHERE aircraft_id = p_aircraft_id;
    
    IF v_aircraft_status != 'active' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Aircraft ', p_aircraft_id, ' is not active.');
    END IF;
    
    -- 插入安装记录
    INSERT INTO InstallationRecord (
        component_id, aircraft_id, installation_position,
        installation_reason, installation_operator_id, installation_time
    ) VALUES (
        p_component_id, p_aircraft_id, p_position,
        p_reason, p_operator_id, p_installation_time
    );
    
    -- 更新部件状态
    UPDATE Component
    SET status = 'installed'
    WHERE component_id = p_component_id;
    
    SELECT 'Component installed successfully' AS message;
END//

-- 存储过程 2: 部件拆卸
CREATE PROCEDURE sp_remove_component(
    IN p_component_id INT,
    IN p_removal_reason TEXT,
    IN p_operator_id INT,
    IN p_removal_time DATETIME
)
BEGIN
    DECLARE v_installation_id INT;
    
    -- 查找有效安装记录
    SELECT installation_id INTO v_installation_id
    FROM InstallationRecord
    WHERE component_id = p_component_id AND removal_time IS NULL;
    
    IF v_installation_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Component ', p_component_id, ' is not currently installed.');
    END IF;
    
    -- 关闭安装记录
    UPDATE InstallationRecord
    SET removal_time = p_removal_time,
        removal_reason = p_removal_reason,
        removal_operator_id = p_operator_id
    WHERE installation_id = v_installation_id;
    
    -- 更新部件状态
    UPDATE Component
    SET status = 'available'
    WHERE component_id = p_component_id;
    
    SELECT 'Component removed successfully' AS message;
END//

-- 存储过程 3: 部件更换
CREATE PROCEDURE sp_replace_component(
    IN p_old_component_id INT,
    IN p_new_component_id INT,
    IN p_aircraft_id INT,
    IN p_position VARCHAR(100),
    IN p_removal_reason TEXT,
    IN p_installation_reason TEXT,
    IN p_operator_id INT,
    IN p_removal_time DATETIME,
    IN p_installation_time DATETIME
)
BEGIN
    DECLARE v_old_installation_id INT;
    
    -- 开始事务
    START TRANSACTION;
    
    -- 1. 查找旧部件的有效安装记录
    SELECT installation_id INTO v_old_installation_id
    FROM InstallationRecord
    WHERE component_id = p_old_component_id
      AND aircraft_id = p_aircraft_id
      AND removal_time IS NULL;
    
    IF v_old_installation_id IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Old component ', p_old_component_id, ' is not currently installed on aircraft ', p_aircraft_id);
    END IF;
    
    -- 2. 关闭旧部件安装记录
    UPDATE InstallationRecord
    SET removal_time = p_removal_time,
        removal_reason = p_removal_reason,
        removal_operator_id = p_operator_id
    WHERE installation_id = v_old_installation_id;
    
    -- 3. 更新旧部件状态为可用
    UPDATE Component
    SET status = 'available'
    WHERE component_id = p_old_component_id;
    
    -- 4. 检查新部件是否可安装
    IF EXISTS (SELECT 1 FROM Component WHERE component_id = p_new_component_id AND is_retired = 1) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('New component ', p_new_component_id, ' is retired.');
    END IF;
    
    IF EXISTS (SELECT 1 FROM InstallationRecord WHERE component_id = p_new_component_id AND removal_time IS NULL) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('New component ', p_new_component_id, ' is already installed elsewhere.');
    END IF;
    
    -- 5. 插入新部件安装记录
    INSERT INTO InstallationRecord (
        component_id, aircraft_id, installation_position,
        installation_reason, installation_operator_id, installation_time
    ) VALUES (
        p_new_component_id, p_aircraft_id, p_position,
        p_installation_reason, p_operator_id, p_installation_time
    );
    
    -- 6. 更新新部件状态为已安装
    UPDATE Component
    SET status = 'installed'
    WHERE component_id = p_new_component_id;
    
    COMMIT;
    
    SELECT 'Component replacement completed successfully' AS message;
END//

-- 存储过程 4: 部件退役
CREATE PROCEDURE sp_retire_component(
    IN p_component_id INT,
    IN p_retirement_reason VARCHAR(100),
    IN p_approval_operator_id INT,
    IN p_notes TEXT,
    IN p_retirement_time DATETIME
)
BEGIN
    -- 检查部件是否仍在安装中
    IF EXISTS (
        SELECT 1 FROM InstallationRecord 
        WHERE component_id = p_component_id 
          AND removal_time IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Component ', p_component_id, ' is still installed. Please remove it first.');
    END IF;
    
    -- 检查是否已退役
    IF EXISTS (SELECT 1 FROM ScrapOrRetirementRecord WHERE component_id = p_component_id) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = CONCAT('Component ', p_component_id, ' is already retired.');
    END IF;
    
    -- 插入退役记录（状态由触发器自动更新）
    INSERT INTO ScrapOrRetirementRecord (
        component_id, retirement_reason, approval_operator_id, retirement_time, notes
    ) VALUES (
        p_component_id, p_retirement_reason, p_approval_operator_id, p_retirement_time, p_notes
    );
    
    SELECT 'Component retired successfully' AS message;
END//

DELIMITER ;

-- =============================================
-- 6. 创建函数（生命周期追溯）
-- =============================================

DELIMITER //

-- 函数: 部件完整生命周期追溯
CREATE FUNCTION func_get_component_lifecycle(p_component_serial VARCHAR(50))
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE v_result TEXT DEFAULT '';
    DECLARE v_info TEXT;
    
    -- 基本信息
    SELECT CONCAT(
        '部件编号: ', component_serial, '\n',
        '型号: ', cm.model_code, '\n',
        '类别: ', cm.category, '\n',
        '当前状态: ', c.status, '\n'
    ) INTO v_info
    FROM Component c
    JOIN ComponentModel cm ON c.model_id = cm.model_id
    WHERE c.component_serial = p_component_serial;
    
    SET v_result = CONCAT(v_result, '=== 基本信息 ===\n', v_info, '\n');
    
    -- 安装历史
    SELECT GROUP_CONCAT(CONCAT(
        '- 飞机: ', a.aircraft_number, 
        ' | 位置: ', ir.installation_position,
        ' | 安装时间: ', ir.installation_time,
        CASE WHEN ir.removal_time IS NULL THEN ' | 状态: 进行中'
        ELSE CONCAT(' | 拆卸时间: ', ir.removal_time)
        END
    ) SEPARATOR '\n') INTO v_info
    FROM InstallationRecord ir
    JOIN Component c ON ir.component_id = c.component_id
    JOIN Aircraft a ON ir.aircraft_id = a.aircraft_id
    WHERE c.component_serial = p_component_serial;
    
    SET v_result = CONCAT(v_result, '=== 安装历史 ===\n', IFNULL(v_info, '无'), '\n\n');
    
    -- 维修历史
    SELECT GROUP_CONCAT(CONCAT(
        '- 工单: ', mr.work_order_number,
        ' | 类型: ', mr.maintenance_type,
        ' | 结果: ', COALESCE(mr.result, '进行中'),
        ' | 时间: ', mr.start_time
    ) SEPARATOR '\n') INTO v_info
    FROM MaintenanceRecord mr
    JOIN Component c ON mr.component_id = c.component_id
    WHERE c.component_serial = p_component_serial;
    
    SET v_result = CONCAT(v_result, '=== 维修历史 ===\n', IFNULL(v_info, '无'), '\n\n');
    
    -- 退役信息
    SELECT CONCAT(
        '- 退役原因: ', srr.retirement_reason,
        ' | 退役时间: ', srr.retirement_time,
        ' | 备注: ', IFNULL(srr.notes, '无')
    ) INTO v_info
    FROM ScrapOrRetirementRecord srr
    JOIN Component c ON srr.component_id = c.component_id
    WHERE c.component_serial = p_component_serial;
    
    IF v_info IS NOT NULL THEN
        SET v_result = CONCAT(v_result, '=== 退役信息 ===\n', v_info, '\n');
    END IF;
    
    RETURN v_result;
END//

DELIMITER ;

-- =============================================
-- 脚本完成
-- =============================================
