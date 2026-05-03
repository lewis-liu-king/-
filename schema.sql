-- =============================================
-- 航空部件生命周期与维修管理系统
-- 数据库建表脚本 (PostgreSQL)
-- =============================================

-- 创建数据库（可选，如需要请取消注释）
-- CREATE DATABASE aviation_component_management;
-- \c aviation_component_management;

-- =============================================
-- 1. 创建基础表
-- =============================================

-- 操作人员表
CREATE TABLE IF NOT EXISTS Operator (
    operator_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('technician', 'inspector', 'manager')),
    contact_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 飞机表
CREATE TABLE IF NOT EXISTS Aircraft (
    aircraft_id SERIAL PRIMARY KEY,
    aircraft_number VARCHAR(50) UNIQUE NOT NULL,
    model VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    commission_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 部件型号表
CREATE TABLE IF NOT EXISTS ComponentModel (
    model_id SERIAL PRIMARY KEY,
    model_code VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    design_life_hours INTEGER CHECK (design_life_hours > 0),
    maintenance_interval_hours INTEGER CHECK (maintenance_interval_hours > 0),
    applicable_aircraft_models TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 部件实例表
CREATE TABLE IF NOT EXISTS Component (
    component_id SERIAL PRIMARY KEY,
    component_serial VARCHAR(50) UNIQUE NOT NULL,
    model_id INTEGER NOT NULL REFERENCES ComponentModel(model_id),
    batch_number VARCHAR(50),
    manufacture_date DATE,
    status VARCHAR(30) NOT NULL CHECK (status IN ('available', 'installed', 'under_maintenance', 'retired')) DEFAULT 'available',
    total_usage_hours NUMERIC(10, 2) DEFAULT 0 CHECK (total_usage_hours >= 0),
    is_retired BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 安装记录表
CREATE TABLE IF NOT EXISTS InstallationRecord (
    installation_id SERIAL PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES Component(component_id),
    aircraft_id INTEGER NOT NULL REFERENCES Aircraft(aircraft_id),
    installation_position VARCHAR(100) NOT NULL,
    installation_reason TEXT,
    installation_operator_id INTEGER REFERENCES Operator(operator_id),
    installation_time TIMESTAMP NOT NULL,
    removal_reason TEXT,
    removal_operator_id INTEGER REFERENCES Operator(operator_id),
    removal_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (removal_time IS NULL OR removal_time >= installation_time)
);

-- 维修记录表
CREATE TABLE IF NOT EXISTS MaintenanceRecord (
    maintenance_id SERIAL PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES Component(component_id),
    work_order_number VARCHAR(50) UNIQUE NOT NULL,
    maintenance_type VARCHAR(50) NOT NULL CHECK (maintenance_type IN ('routine', 'corrective', 'overhaul')),
    description TEXT,
    operator_id INTEGER REFERENCES Operator(operator_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    result VARCHAR(20) CHECK (result IN ('success', 'partial', 'failed')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_time IS NULL OR end_time >= start_time)
);

-- 飞行记录表
CREATE TABLE IF NOT EXISTS FlightLog (
    flight_id SERIAL PRIMARY KEY,
    aircraft_id INTEGER NOT NULL REFERENCES Aircraft(aircraft_id),
    flight_number VARCHAR(50),
    mission_type VARCHAR(50) NOT NULL,
    departure_airport VARCHAR(100),
    arrival_airport VARCHAR(100),
    takeoff_time TIMESTAMP NOT NULL,
    landing_time TIMESTAMP,
    flight_duration_hours NUMERIC(6, 2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (landing_time IS NULL OR landing_time >= takeoff_time)
);

-- 退役记录表
CREATE TABLE IF NOT EXISTS ScrapOrRetirementRecord (
    retirement_id SERIAL PRIMARY KEY,
    component_id INTEGER UNIQUE NOT NULL REFERENCES Component(component_id),
    retirement_reason VARCHAR(100) NOT NULL CHECK (retirement_reason IN ('end_of_life', 'irreparable', 'damage', 'other')),
    approval_operator_id INTEGER REFERENCES Operator(operator_id),
    retirement_time TIMESTAMP NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- 2. 创建索引（优化查询性能）
-- =============================================

-- 安装唯一性约束：同一部件在同一时刻只能有一条有效安装记录
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_active_installation 
ON InstallationRecord(component_id) 
WHERE removal_time IS NULL;

-- Component 表索引
CREATE INDEX IF NOT EXISTS idx_component_model ON Component(model_id);
CREATE INDEX IF NOT EXISTS idx_component_status ON Component(status);
CREATE INDEX IF NOT EXISTS idx_component_retired ON Component(is_retired);

-- InstallationRecord 表索引
CREATE INDEX IF NOT EXISTS idx_installation_component ON InstallationRecord(component_id);
CREATE INDEX IF NOT EXISTS idx_installation_aircraft ON InstallationRecord(aircraft_id);
CREATE INDEX IF NOT EXISTS idx_installation_time ON InstallationRecord(installation_time);

-- MaintenanceRecord 表索引
CREATE INDEX IF NOT EXISTS idx_maintenance_component ON MaintenanceRecord(component_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_start ON MaintenanceRecord(start_time);

-- FlightLog 表索引
CREATE INDEX IF NOT EXISTS idx_flight_aircraft ON FlightLog(aircraft_id);
CREATE INDEX IF NOT EXISTS idx_flight_takeoff ON FlightLog(takeoff_time);

-- =============================================
-- 3. 创建触发器函数和触发器
-- =============================================

-- 触发器函数 1: 防止物理删除核心数据
CREATE OR REPLACE FUNCTION prevent_delete_core_data()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Cannot physically delete %. Use status update instead.', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

-- 触发器：禁止删除 Component
DROP TRIGGER IF EXISTS trigger_prevent_delete_component ON Component;
CREATE TRIGGER trigger_prevent_delete_component
BEFORE DELETE ON Component
FOR EACH ROW EXECUTE FUNCTION prevent_delete_core_data();

-- 触发器：禁止删除 Aircraft
DROP TRIGGER IF EXISTS trigger_prevent_delete_aircraft ON Aircraft;
CREATE TRIGGER trigger_prevent_delete_aircraft
BEFORE DELETE ON Aircraft
FOR EACH ROW EXECUTE FUNCTION prevent_delete_core_data();

-- 触发器：禁止删除 InstallationRecord
DROP TRIGGER IF EXISTS trigger_prevent_delete_installation ON InstallationRecord;
CREATE TRIGGER trigger_prevent_delete_installation
BEFORE DELETE ON InstallationRecord
FOR EACH ROW EXECUTE FUNCTION prevent_delete_core_data();

-- 触发器：禁止删除 MaintenanceRecord
DROP TRIGGER IF EXISTS trigger_prevent_delete_maintenance ON MaintenanceRecord;
CREATE TRIGGER trigger_prevent_delete_maintenance
BEFORE DELETE ON MaintenanceRecord
FOR EACH ROW EXECUTE FUNCTION prevent_delete_core_data();

-- 触发器：禁止删除 FlightLog
DROP TRIGGER IF EXISTS trigger_prevent_delete_flight ON FlightLog;
CREATE TRIGGER trigger_prevent_delete_flight
BEFORE DELETE ON FlightLog
FOR EACH ROW EXECUTE FUNCTION prevent_delete_core_data();

-- 触发器函数 2: 安装前检查部件状态
CREATE OR REPLACE FUNCTION check_component_before_install()
RETURNS TRIGGER AS $$
DECLARE
    v_component_status VARCHAR(30);
    v_is_retired BOOLEAN;
BEGIN
    -- 获取部件状态
    SELECT status, is_retired INTO v_component_status, v_is_retired
    FROM Component WHERE component_id = NEW.component_id;
    
    -- 检查是否已退役
    IF v_is_retired OR v_component_status = 'retired' THEN
        RAISE EXCEPTION 'Component % is retired and cannot be installed.', NEW.component_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 触发器：安装前检查
DROP TRIGGER IF EXISTS trigger_check_before_install ON InstallationRecord;
CREATE TRIGGER trigger_check_before_install
BEFORE INSERT ON InstallationRecord
FOR EACH ROW EXECUTE FUNCTION check_component_before_install();

-- 触发器函数 3: 退役记录插入时同步部件状态
CREATE OR REPLACE FUNCTION sync_component_on_retirement()
RETURNS TRIGGER AS $$
BEGIN
    -- 更新部件状态为退役
    UPDATE Component
    SET status = 'retired',
        is_retired = TRUE
    WHERE component_id = NEW.component_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 触发器：退役后同步状态
DROP TRIGGER IF EXISTS trigger_sync_retirement ON ScrapOrRetirementRecord;
CREATE TRIGGER trigger_sync_retirement
AFTER INSERT ON ScrapOrRetirementRecord
FOR EACH ROW EXECUTE FUNCTION sync_component_on_retirement();

-- 触发器函数 4: 防止对已退役部件创建新记录
CREATE OR REPLACE FUNCTION prevent_operation_on_retired_component()
RETURNS TRIGGER AS $$
DECLARE
    v_is_retired BOOLEAN;
BEGIN
    SELECT is_retired INTO v_is_retired
    FROM Component WHERE component_id = NEW.component_id;
    
    IF v_is_retired THEN
        RAISE EXCEPTION 'Component % is retired, cannot create new %.', NEW.component_id, TG_TABLE_NAME;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 触发器：防止对已退役部件创建安装记录
DROP TRIGGER IF EXISTS trigger_prevent_install_on_retired ON InstallationRecord;
CREATE TRIGGER trigger_prevent_install_on_retired
BEFORE INSERT ON InstallationRecord
FOR EACH ROW EXECUTE FUNCTION prevent_operation_on_retired_component();

-- 触发器：防止对已退役部件创建维修记录
DROP TRIGGER IF EXISTS trigger_prevent_maintenance_on_retired ON MaintenanceRecord;
CREATE TRIGGER trigger_prevent_maintenance_on_retired
BEFORE INSERT ON MaintenanceRecord
FOR EACH ROW EXECUTE FUNCTION prevent_operation_on_retired_component();

-- =============================================
-- 4. 创建视图
-- =============================================

-- 视图 1: 部件当前状态视图（加分项：区分当前状态和历史事件）
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
        EXTRACT(EPOCH FROM (COALESCE(ir.removal_time, NOW()) - ir.installation_time))/3600,
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

-- =============================================
-- 5. 创建存储过程（事务实现）
-- =============================================

-- 存储过程 1: 部件更换事务
CREATE OR REPLACE PROCEDURE sp_replace_component(
    p_old_component_id INTEGER,
    p_new_component_id INTEGER,
    p_aircraft_id INTEGER,
    p_installation_position VARCHAR(100),
    p_removal_reason TEXT,
    p_installation_reason TEXT,
    p_operator_id INTEGER,
    p_removal_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    p_installation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_installation_id INTEGER;
BEGIN
    -- 开始事务（PostgreSQL 存储过程默认在事务中）
    
    -- 1. 查找旧部件的有效安装记录
    SELECT installation_id INTO v_old_installation_id
    FROM InstallationRecord
    WHERE component_id = p_old_component_id
      AND aircraft_id = p_aircraft_id
      AND removal_time IS NULL;
    
    IF v_old_installation_id IS NULL THEN
        RAISE EXCEPTION 'Old component % is not currently installed on aircraft %.', p_old_component_id, p_aircraft_id;
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
    IF EXISTS (SELECT 1 FROM Component WHERE component_id = p_new_component_id AND is_retired) THEN
        RAISE EXCEPTION 'New component % is retired.', p_new_component_id;
    END IF;
    
    IF EXISTS (SELECT 1 FROM InstallationRecord WHERE component_id = p_new_component_id AND removal_time IS NULL) THEN
        RAISE EXCEPTION 'New component % is already installed elsewhere.', p_new_component_id;
    END IF;
    
    -- 5. 插入新部件安装记录
    INSERT INTO InstallationRecord (
        component_id, aircraft_id, installation_position,
        installation_reason, installation_operator_id, installation_time
    ) VALUES (
        p_new_component_id, p_aircraft_id, p_installation_position,
        p_installation_reason, p_operator_id, p_installation_time
    );
    
    -- 6. 更新新部件状态为已安装
    UPDATE Component
    SET status = 'installed'
    WHERE component_id = p_new_component_id;
    
    -- 提交事务（由调用方或存储过程自动处理）
    RAISE NOTICE 'Component replacement completed successfully. Old: %, New: %', p_old_component_id, p_new_component_id;
END;
$$;

-- 存储过程 2: 退役处理事务
CREATE OR REPLACE PROCEDURE sp_retire_component(
    p_component_id INTEGER,
    p_retirement_reason VARCHAR(100),
    p_approval_operator_id INTEGER,
    p_notes TEXT DEFAULT NULL,
    p_retirement_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. 检查部件是否仍在安装中
    IF EXISTS (
        SELECT 1 FROM InstallationRecord 
        WHERE component_id = p_component_id 
          AND removal_time IS NULL
    ) THEN
        RAISE EXCEPTION 'Component % is still installed. Please remove it first.', p_component_id;
    END IF;
    
    -- 2. 检查是否已退役
    IF EXISTS (SELECT 1 FROM ScrapOrRetirementRecord WHERE component_id = p_component_id) THEN
        RAISE EXCEPTION 'Component % is already retired.', p_component_id;
    END IF;
    
    -- 3. 插入退役记录
    INSERT INTO ScrapOrRetirementRecord (
        component_id, retirement_reason, approval_operator_id, retirement_time, notes
    ) VALUES (
        p_component_id, p_retirement_reason, p_approval_operator_id, p_retirement_time, p_notes
    );
    
    -- 注意：部件状态更新由触发器 trigger_sync_retirement 自动处理
    
    RAISE NOTICE 'Component % retired successfully.', p_component_id;
END;
$$;

-- 存储过程 3: 部件拆卸事务
CREATE OR REPLACE PROCEDURE sp_remove_component(
    p_component_id INTEGER,
    p_removal_reason TEXT,
    p_operator_id INTEGER,
    p_removal_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_installation_id INTEGER;
BEGIN
    -- 查找有效安装记录
    SELECT installation_id INTO v_installation_id
    FROM InstallationRecord
    WHERE component_id = p_component_id AND removal_time IS NULL;
    
    IF v_installation_id IS NULL THEN
        RAISE EXCEPTION 'Component % is not currently installed.', p_component_id;
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
    
    RAISE NOTICE 'Component % removed successfully.', p_component_id;
END;
$$;

-- 存储过程 4: 部件安装事务
CREATE OR REPLACE PROCEDURE sp_install_component(
    p_component_id INTEGER,
    p_aircraft_id INTEGER,
    p_installation_position VARCHAR(100),
    p_installation_reason TEXT,
    p_operator_id INTEGER,
    p_installation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 检查飞机状态
    IF NOT EXISTS (SELECT 1 FROM Aircraft WHERE aircraft_id = p_aircraft_id AND status = 'active') THEN
        RAISE EXCEPTION 'Aircraft % is not active.', p_aircraft_id;
    END IF;
    
    -- 插入安装记录
    INSERT INTO InstallationRecord (
        component_id, aircraft_id, installation_position,
        installation_reason, installation_operator_id, installation_time
    ) VALUES (
        p_component_id, p_aircraft_id, p_installation_position,
        p_installation_reason, p_operator_id, p_installation_time
    );
    
    -- 更新部件状态
    UPDATE Component
    SET status = 'installed'
    WHERE component_id = p_component_id;
    
    RAISE NOTICE 'Component % installed on aircraft % successfully.', p_component_id, p_aircraft_id;
END;
$$;

-- =============================================
-- 6. 复杂查询（生命周期追溯等）
-- =============================================

-- 查询 1: 部件完整生命周期追溯（给定部件编号）
-- 用法示例: SELECT * FROM func_get_component_lifecycle('COMP-001');
CREATE OR REPLACE FUNCTION func_get_component_lifecycle(p_component_serial VARCHAR(50))
RETURNS TABLE (
    section VARCHAR(50),
    item_name VARCHAR(100),
    item_value TEXT,
    event_time TIMESTAMP,
    sort_order INTEGER
) AS $$
BEGIN
    -- 返回结果为多部分组成的报表格式
    
    -- 第 1 部分：基本属性
    RETURN QUERY
    SELECT 
        'Basic Info' AS section,
        'Component Serial' AS item_name,
        c.component_serial AS item_value,
        NULL AS event_time,
        1 AS sort_order
    FROM Component c WHERE c.component_serial = p_component_serial
    
    UNION ALL
    
    SELECT 
        'Basic Info' AS section,
        'Model' AS item_name,
        cm.model_code AS item_value,
        NULL AS event_time,
        2 AS sort_order
    FROM Component c JOIN ComponentModel cm ON c.model_id = cm.model_id WHERE c.component_serial = p_component_serial
    
    UNION ALL
    
    SELECT 
        'Basic Info' AS section,
        'Category' AS item_name,
        cm.category AS item_value,
        NULL AS event_time,
        3 AS sort_order
    FROM Component c JOIN ComponentModel cm ON c.model_id = cm.model_id WHERE c.component_serial = p_component_serial
    
    UNION ALL
    
    SELECT 
        'Basic Info' AS section,
        'Current Status' AS item_name,
        c.status AS item_value,
        NULL AS event_time,
        4 AS sort_order
    FROM Component c WHERE c.component_serial = p_component_serial
    
    UNION ALL
    
    -- 第 2 部分：安装历史
    SELECT 
        'Installation History' AS section,
        'Installed on ' || a.aircraft_number || ' at ' || ir.installation_position AS item_name,
        CASE WHEN ir.removal_time IS NULL THEN 'Active' ELSE 'Removed' END AS item_value,
        ir.installation_time AS event_time,
        10 + ROW_NUMBER() OVER (ORDER BY ir.installation_time) AS sort_order
    FROM Component c
    JOIN InstallationRecord ir ON c.component_id = ir.component_id
    JOIN Aircraft a ON ir.aircraft_id = a.aircraft_id
    WHERE c.component_serial = p_component_serial
    ORDER BY ir.installation_time DESC
    
    UNION ALL
    
    -- 第 3 部分：维修历史
    SELECT 
        'Maintenance History' AS section,
        mr.maintenance_type || ' - ' || COALESCE(mr.result, 'Pending') AS item_name,
        mr.description AS item_value,
        mr.start_time AS event_time,
        100 + ROW_NUMBER() OVER (ORDER BY mr.start_time) AS sort_order
    FROM Component c
    JOIN MaintenanceRecord mr ON c.component_id = mr.component_id
    WHERE c.component_serial = p_component_serial
    ORDER BY mr.start_time DESC
    
    UNION ALL
    
    -- 第 4 部分：退役信息
    SELECT 
        'Retirement Info' AS section,
        'Retirement Reason' AS item_name,
        srr.retirement_reason AS item_value,
        srr.retirement_time AS event_time,
        200 AS sort_order
    FROM Component c
    JOIN ScrapOrRetirementRecord srr ON c.component_id = srr.component_id
    WHERE c.component_serial = p_component_serial;
    
END;
$$ LANGUAGE plpgsql;

-- 查询 2: 部件在某时间段内的飞行统计
CREATE OR REPLACE FUNCTION func_get_component_flight_stats(
    p_component_serial VARCHAR(50),
    p_start_time TIMESTAMP,
    p_end_time TIMESTAMP
)
RETURNS TABLE (
    aircraft_number VARCHAR(50),
    total_flights INTEGER,
    total_flight_hours NUMERIC(10, 2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.aircraft_number,
        COUNT(fl.flight_id) AS total_flights,
        COALESCE(SUM(fl.flight_duration_hours), 0) AS total_flight_hours
    FROM Component c
    JOIN InstallationRecord ir ON c.component_id = ir.component_id
    JOIN Aircraft a ON ir.aircraft_id = a.aircraft_id
    LEFT JOIN FlightLog fl ON a.aircraft_id = fl.aircraft_id
        AND fl.takeoff_time >= COALESCE(ir.installation_time, fl.takeoff_time)
        AND (fl.landing_time <= COALESCE(ir.removal_time, NOW()) OR ir.removal_time IS NULL)
        AND fl.takeoff_time >= p_start_time
        AND (fl.landing_time <= p_end_time OR fl.landing_time IS NULL)
    WHERE c.component_serial = p_component_serial
    GROUP BY a.aircraft_number;
END;
$$ LANGUAGE plpgsql;

-- 查询 3: 统计分析 - 某型号部件的平均维修间隔
CREATE OR REPLACE VIEW v_model_maintenance_stats AS
SELECT 
    cm.model_code,
    cm.category,
    COUNT(DISTINCT c.component_id) AS total_components,
    COUNT(mr.maintenance_id) AS total_maintenances,
    CASE 
        WHEN COUNT(mr.maintenance_id) > 1 THEN 
            AVG(maintenance_interval) 
        ELSE NULL 
    END AS avg_maintenance_interval_days
FROM ComponentModel cm
LEFT JOIN Component c ON cm.model_id = c.model_id
LEFT JOIN (
    SELECT 
        mr.component_id,
        mr.start_time,
        mr.start_time - LAG(mr.start_time) OVER (PARTITION BY mr.component_id ORDER BY mr.start_time) AS maintenance_interval
    FROM MaintenanceRecord mr
) mr ON c.component_id = mr.component_id
GROUP BY cm.model_code, cm.category;

-- 查询 4: 统计分析 - 不同飞机的部件更换频率
CREATE OR REPLACE VIEW v_aircraft_component_changes AS
SELECT 
    a.aircraft_number,
    a.model AS aircraft_model,
    COUNT(DISTINCT ir.component_id) AS unique_components_used,
    COUNT(ir.installation_id) AS total_installations,
    CASE 
        WHEN COUNT(ir.installation_id) > 0 THEN 
            COUNT(ir.installation_id)::FLOAT / NULLIF(EXTRACT(DAY FROM NOW() - MIN(ir.installation_time))/30, 0)
        ELSE NULL 
    END AS avg_changes_per_month
FROM Aircraft a
LEFT JOIN InstallationRecord ir ON a.aircraft_id = ir.aircraft_id
GROUP BY a.aircraft_id, a.aircraft_number, a.model;

-- 查询 5: 统计分析 - 退役原因分布
CREATE OR REPLACE VIEW v_retirement_reason_distribution AS
SELECT 
    retirement_reason,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ScrapOrRetirementRecord), 2) AS percentage
FROM ScrapOrRetirementRecord
GROUP BY retirement_reason
ORDER BY count DESC;

-- =============================================
-- 脚本完成
-- =============================================
