-- =============================================
-- 航空部件生命周期与维修管理系统
-- 初始化数据脚本
-- =============================================

-- =============================================
-- 1. 插入操作人员数据
-- =============================================
INSERT INTO Operator (name, employee_id, role, contact_info) VALUES
('张三', 'OP-001', 'technician', 'zhangsan@example.com'),
('李四', 'OP-002', 'technician', 'lisi@example.com'),
('王五', 'OP-003', 'inspector', 'wangwu@example.com'),
('赵六', 'OP-004', 'manager', 'zhaoliu@example.com');

-- =============================================
-- 2. 插入飞机数据
-- =============================================
INSERT INTO Aircraft (aircraft_number, model, status, commission_date) VALUES
('B-1234', 'Boeing 737-800', 'active', '2020-01-15'),
('B-5678', 'Airbus A320neo', 'active', '2021-06-20'),
('B-9012', 'Boeing 787-9', 'inactive', '2019-03-10');

-- =============================================
-- 3. 插入部件型号数据
-- =============================================
INSERT INTO ComponentModel (model_code, category, design_life_hours, maintenance_interval_hours, applicable_aircraft_models, description) VALUES
('ENG-CFM56-7B', 'Engine', 40000, 5000, 'Boeing 737-800, Boeing 737 MAX', 'CFM56-7B 涡轮风扇发动机'),
('AVI-GTN-750', 'Avionics', 60000, 8000, 'Boeing 737-800, Airbus A320neo', 'GTN 750 导航系统'),
('STR-WRN-01', 'Structure', 80000, 12000, 'Boeing 737-800, Boeing 787-9, Airbus A320neo', '机翼前缘结构组件');

-- =============================================
-- 4. 插入部件实例数据（部件入库）
-- =============================================
INSERT INTO Component (component_serial, model_id, batch_number, manufacture_date, status, total_usage_hours) VALUES
('COMP-001', 1, 'BATCH-2020-001', '2020-02-01', 'available', 0),
('COMP-002', 1, 'BATCH-2020-002', '2020-02-15', 'available', 0),
('COMP-003', 2, 'BATCH-2020-003', '2020-03-20', 'available', 0),
('COMP-004', 2, 'BATCH-2021-001', '2021-01-10', 'available', 0),
('COMP-005', 3, 'BATCH-2019-001', '2019-11-05', 'available', 0),
('COMP-006', 3, 'BATCH-2019-002', '2019-12-01', 'available', 0);

-- =============================================
-- 5. 插入安装记录（历史数据）
-- =============================================

-- COMP-001 的安装记录（已拆卸）
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_reason, installation_operator_id, installation_time, removal_reason, removal_operator_id, removal_time) VALUES
(1, 1, 'Left Engine Pylon', 'Initial installation during production', 1, '2020-03-01 10:00:00', 'Scheduled maintenance removal for inspection', 2, '2020-09-01 14:30:00');

-- COMP-001 再次安装（当前状态：已安装
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_reason, installation_operator_id, installation_time) VALUES
(1, 1, 'Left Engine Pylon', 'Reinstallation after inspection', 1, '2020-09-15 09:00:00');

-- COMP-002 安装到另一架飞机（已拆卸）
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_reason, installation_operator_id, installation_time, removal_reason, removal_operator_id, removal_time) VALUES
(2, 2, 'Left Navigation Bay 1', 'Regular installation', 2, '2021-07-01 11:00:00', 'Upgrade to newer model', 1, '2022-01-01 16:00:00');

-- COMP-003 当前安装在 B-5678
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_reason, installation_operator_id, installation_time) VALUES
(3, 2, 'Left Navigation Bay 1', 'Upgrade replacement', 2, '2022-01-02 10:00:00');

-- COMP-004 已安装在 B-9012
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_reason, installation_operator_id, installation_time) VALUES
(4, 3, 'Right Navigation Bay', 'Initial installation', 1, '2021-08-01 09:00:00');

-- =============================================
-- 6. 插入维修记录
-- =============================================
INSERT INTO MaintenanceRecord (component_id, work_order_number, maintenance_type, description, operator_id, start_time, end_time, result, notes) VALUES
(1, 'WO-2020-001', 'routine', 'Routine engine inspection', 2, '2020-09-01 14:30:00', '2020-09-10 16:00:00', 'success', 'Completed routine inspection, no issues found'),
(1, 'WO-2021-001', 'routine', '6-month routine check', 1, '2021-03-15 09:00:00', '2021-03-18 17:00:00', 'success', 'Routine check completed'),
(2, 'WO-2021-002', 'corrective', 'Repair navigation system error', 2, '2021-11-01 10:00:00', '2021-11-05 15:00:00', 'success', 'Replaced faulty sensor module'),
(3, 'WO-2022-001', 'routine', 'Annual avionics check', 1, '2022-07-01 09:00:00', '2022-07-03 16:00:00', 'success', 'System calibration completed');

-- =============================================
-- 7. 插入飞行记录
-- =============================================
INSERT INTO FlightLog (aircraft_id, flight_number, mission_type, departure_airport, arrival_airport, takeoff_time, landing_time, flight_duration_hours, notes) VALUES
(1, 'CA1234', 'commercial', 'PEK', 'SHA', '2020-03-02 08:00:00', '2020-03-02 10:30:00', 2.5, 'Regular passenger flight'),
(1, 'CA1235', 'commercial', 'SHA', 'PEK', '2020-03-03 14:00:00', '2020-03-03 16:20:00', 2.33, 'Return flight'),
(1, 'CA1236', 'commercial', 'PEK', 'CAN', '2020-06-15 09:00:00', '2020-06-15 12:30:00', 3.5, 'Southbound flight'),
(2, 'MU5678', 'commercial', 'PVG', 'CTU', '2021-07-05 07:30:00', '2021-07-05 10:45:00', 3.25, 'Flight to Chengdu'),
(2, 'MU5679', 'commercial', 'CTU', 'PVG', '2021-07-06 11:00:00', '2021-07-06 14:15:00', 3.25, 'Return flight'),
(2, 'MU5680', 'training', 'PVG', 'NKG', '2021-08-10 06:00:00', '2021-08-10 08:00:00', 2.0, 'Crew training flight'),
(3, 'CA9876', 'test', 'PEK', 'PEK', '2021-08-15 10:00:00', '2021-08-15 12:00:00', 2.0, 'Test flight after maintenance');

-- =============================================
-- 8. 插入退役记录（退役一个部件用于演示）
-- =============================================

-- 先把 COMP-006 设置为已退役（通过存储过程需要先确保没有安装记录
INSERT INTO ScrapOrRetirementRecord (component_id, retirement_reason, approval_operator_id, retirement_time, notes) VALUES
(6, 'end_of_life', 4, '2023-01-01 10:00:00', '部件达到设计寿命上限，正常退役');

-- =============================================
-- 9. 更新一些部件状态以匹配安装记录
-- =============================================

-- COMP-001, COMP-003, COMP-004 当前已安装
UPDATE Component SET status = 'installed' WHERE component_id IN (1, 3, 4);

-- COMP-006 已退役（触发器已由触发器自动更新）

-- =============================================
-- 初始化数据完成
-- =============================================
-- 现在可以运行演示了！
-- =============================================

-- =============================================
-- 演示用例1: 查询部件生命周期的完整生命周期追溯
-- SELECT * FROM func_get_component_lifecycle('COMP-001');
-- =============================================

-- =============================================
-- 演示用例2: 查看当前部件状态
-- SELECT * FROM v_component_current_status;
-- =============================================

-- =============================================
-- 演示用例3: 尝试非法操作拦截 - 尝试删除部件
-- DELETE FROM Component WHERE component_id = 1;  -- 应该失败
-- =============================================

-- =============================================
-- 演示用例4: 部件更换事务（使用存储过程
-- BEGIN;
-- CALL sp_replace_component(1, 2, 1, 'Left Engine Pylon', 'Scheduled replacement', 'New component installation', 1);
-- COMMIT;  -- 或 ROLLBACK;
-- =============================================
