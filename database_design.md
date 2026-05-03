# 航空部件生命周期与维修管理系统 - 数据库设计文档

## 一、需求分析

### 1.1 业务目标
- 管理飞机、部件、部件型号信息
- 追踪部件从入库、安装、拆卸、维修到退役的完整生命周期
- 记录安装拆卸记录、维修记录、飞行记录
- 保证数据一致性和历史可追溯性
- 数据库层实现业务规则约束

### 1.2 业务假设
- **维修模式**: 允许拆卸后送修（部件可以在拆卸状态下进行维修）
- **时间表示**: 使用时间区间（start_time + end_time）表示安装记录的有效性，end_time 为 NULL 表示当前仍在安装中
- **软删除**: 核心业务数据不允许物理删除，使用状态字段标记退役
- **状态机**: 
  - 部件状态: available（可用）, installed（已安装）, under_maintenance（维修中）, retired（已退役）
  - 飞机状态: active（活跃）, inactive（停用）

---

## 二、ER 模型设计

### 2.1 实体关系图（ER Diagram）

```
Operator (操作人员)
    ├── 1───*─── InstallationRecord (执行安装/拆卸)
    ├── 1───*─── MaintenanceRecord (执行维修)
    └── 1───*─── ScrapOrRetirementRecord (审批退役)

Aircraft (飞机)
    ├── 1───*─── InstallationRecord (安装历史)
    └── 1───*─── FlightLog (飞行记录)

ComponentModel (部件型号)
    └── 1───*─── Component (型号下的部件实例)

Component (部件实例)
    ├── 1───*─── InstallationRecord (安装历史)
    ├── 1───*─── MaintenanceRecord (维修历史)
    └── 1───0..1─── ScrapOrRetirementRecord (退役记录，每个部件最多一条)
```

### 2.2 实体定义

#### 实体 1: Operator（操作人员/技术员）
- **用途**: 记录安装、维修、审批等责任主体，体现可追责性
- **属性**:
  - operator_id: 主键，操作员ID
  - name: 操作员姓名
  - employee_id: 工号（唯一）
  - role: 角色（如: technician, inspector, manager）
  - contact_info: 联系方式
  - created_at: 创建时间

#### 实体 2: Aircraft（飞机）
- **用途**: 记录飞机基本信息
- **属性**:
  - aircraft_id: 主键，飞机ID
  - aircraft_number: 飞机编号（唯一，如: B-1234）
  - model: 飞机型号
  - status: 状态（active, inactive）
  - commission_date: 启用日期
  - created_at: 创建时间

#### 实体 3: ComponentModel（部件型号）
- **用途**: 记录部件型号信息（一类部件的公共属性）
- **属性**:
  - model_id: 主键，型号ID
  - model_code: 型号代码（唯一）
  - category: 部件类别（如: engine, avionics, structure）
  - design_life_hours: 设计寿命（小时）
  - maintenance_interval_hours: 维修周期（小时）
  - applicable_aircraft_models: 适用机型（JSON或文本）
  - description: 描述
  - created_at: 创建时间

#### 实体 4: Component（部件实例）
- **用途**: 记录具体的部件实例
- **属性**:
  - component_id: 主键，部件ID
  - component_serial: 部件编号（唯一）
  - model_id: 外键，关联 ComponentModel
  - batch_number: 批次号
  - manufacture_date: 生产日期
  - status: 状态（available, installed, under_maintenance, retired）
  - total_usage_hours: 累计使用时长（小时）
  - is_retired: 是否已退役（布尔值，冗余用于快速查询）
  - created_at: 创建时间

#### 实体 5: InstallationRecord（安装记录）
- **用途**: 记录部件的安装和拆卸历史（体现时间区间）
- **属性**:
  - installation_id: 主键，安装记录ID
  - component_id: 外键，关联 Component
  - aircraft_id: 外键，关联 Aircraft
  - installation_position: 安装位置
  - installation_reason: 安装原因
  - installation_operator_id: 外键，安装操作员
  - installation_time: 安装时间（start_time）
  - removal_reason: 拆卸原因
  - removal_operator_id: 外键，拆卸操作员
  - removal_time: 拆卸时间（end_time，NULL表示当前仍在安装）
  - created_at: 创建时间

#### 实体 6: MaintenanceRecord（维修记录）
- **用途**: 记录部件的维修历史
- **属性**:
  - maintenance_id: 主键，维修记录ID
  - component_id: 外键，关联 Component
  - work_order_number: 工单编号（唯一）
  - maintenance_type: 维修类型（如: routine, corrective, overhaul）
  - description: 维修描述
  - operator_id: 外键，维修操作员
  - start_time: 维修开始时间
  - end_time: 维修结束时间
  - result: 维修结果（如: success, partial, failed）
  - notes: 备注
  - created_at: 创建时间

#### 实体 7: FlightLog（飞行记录）
- **用途**: 记录飞机的飞行任务
- **属性**:
  - flight_id: 主键，飞行记录ID
  - aircraft_id: 外键，关联 Aircraft
  - flight_number: 航班号/任务编号
  - mission_type: 任务类型（如: commercial, training, test）
  - departure_airport: 起飞机场
  - arrival_airport: 降落机场
  - takeoff_time: 起飞时间
  - landing_time: 降落时间
  - flight_duration_hours: 飞行时长（小时）
  - notes: 备注
  - created_at: 创建时间

#### 实体 8: ScrapOrRetirementRecord（退役记录）
- **用途**: 记录部件的退役信息，增强可审计性
- **属性**:
  - retirement_id: 主键，退役记录ID
  - component_id: 外键，关联 Component（唯一，一个部件只能退役一次）
  - retirement_reason: 退役原因（如: end_of_life, irreparable, damage）
  - approval_operator_id: 外键，审批操作员
  - retirement_time: 退役时间
  - notes: 备注
  - created_at: 创建时间

---

## 三、逻辑模式设计（表结构）

### 3.1 Operator 表
```sql
Operator (
    operator_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('technician', 'inspector', 'manager')),
    contact_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### 3.2 Aircraft 表
```sql
Aircraft (
    aircraft_id SERIAL PRIMARY KEY,
    aircraft_number VARCHAR(50) UNIQUE NOT NULL,
    model VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
    commission_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### 3.3 ComponentModel 表
```sql
ComponentModel (
    model_id SERIAL PRIMARY KEY,
    model_code VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    design_life_hours INTEGER CHECK (design_life_hours > 0),
    maintenance_interval_hours INTEGER CHECK (maintenance_interval_hours > 0),
    applicable_aircraft_models TEXT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### 3.4 Component 表
```sql
Component (
    component_id SERIAL PRIMARY KEY,
    component_serial VARCHAR(50) UNIQUE NOT NULL,
    model_id INTEGER NOT NULL REFERENCES ComponentModel(model_id),
    batch_number VARCHAR(50),
    manufacture_date DATE,
    status VARCHAR(30) NOT NULL CHECK (status IN ('available', 'installed', 'under_maintenance', 'retired')) DEFAULT 'available',
    total_usage_hours NUMERIC(10, 2) DEFAULT 0 CHECK (total_usage_hours >= 0),
    is_retired BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

### 3.5 InstallationRecord 表
```sql
InstallationRecord (
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
)
```

### 3.6 MaintenanceRecord 表
```sql
MaintenanceRecord (
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
)
```

### 3.7 FlightLog 表
```sql
FlightLog (
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
)
```

### 3.8 ScrapOrRetirementRecord 表
```sql
ScrapOrRetirementRecord (
    retirement_id SERIAL PRIMARY KEY,
    component_id INTEGER UNIQUE NOT NULL REFERENCES Component(component_id),
    retirement_reason VARCHAR(100) NOT NULL CHECK (retirement_reason IN ('end_of_life', 'irreparable', 'damage', 'other')),
    approval_operator_id INTEGER REFERENCES Operator(operator_id),
    retirement_time TIMESTAMP NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

---

## 四、关键约束说明

### 4.1 主键约束
- 所有表都有自增主键（SERIAL）
- 保证每条记录的唯一性

### 4.2 外键约束
- Component.model_id → ComponentModel.model_id
- InstallationRecord.component_id → Component.component_id
- InstallationRecord.aircraft_id → Aircraft.aircraft_id
- MaintenanceRecord.component_id → Component.component_id
- FlightLog.aircraft_id → Aircraft.aircraft_id
- ScrapOrRetirementRecord.component_id → Component.component_id
- 所有 operator_id 外键 → Operator.operator_id

### 4.3 唯一约束
- Operator.employee_id: 工号唯一
- Aircraft.aircraft_number: 飞机编号唯一
- ComponentModel.model_code: 型号代码唯一
- Component.component_serial: 部件编号唯一
- MaintenanceRecord.work_order_number: 工单编号唯一
- ScrapOrRetirementRecord.component_id: 一个部件只能退役一次

### 4.4 检查约束
- Operator.role: 只能是 'technician', 'inspector', 'manager'
- Aircraft.status: 只能是 'active', 'inactive'
- Component.status: 只能是 'available', 'installed', 'under_maintenance', 'retired'
- 时间合理性检查: end_time >= start_time（适用于 InstallationRecord, MaintenanceRecord, FlightLog）
- 数值非负检查: design_life_hours, maintenance_interval_hours, total_usage_hours, flight_duration_hours

### 4.5 部分唯一索引（安装唯一性规则）
```sql
-- 确保同一部件在同一时刻只有一条有效安装记录（removal_time IS NULL）
CREATE UNIQUE INDEX idx_unique_active_installation 
ON InstallationRecord(component_id) 
WHERE removal_time IS NULL;
```

### 4.6 触发器（非法操作拒绝机制）

#### 触发器 1: 防止物理删除核心数据
```sql
-- 禁止直接删除 Component, Aircraft, InstallationRecord, MaintenanceRecord, FlightLog
```

#### 触发器 2: 安装前检查部件状态
```sql
-- 安装部件时检查:
-- 1. 部件未退役 (is_retired = FALSE)
-- 2. 部件不是 retired 状态
-- 3. 部件没有其他有效安装记录
```

#### 触发器 3: 退役后状态同步
```sql
-- 插入退役记录时，自动更新 Component.is_retired = TRUE 和 status = 'retired'
```

#### 触发器 4: 防止退役后操作
```sql
-- 阻止对已退役部件创建新的安装或维修记录
```

---

## 五、事务说明

### 5.1 事务场景一：部件更换事务
```
业务流程:
1. 关闭旧部件当前安装记录（设置 removal_time）
2. 检查新部件是否可安装（未退役、未安装）
3. 插入新部件安装记录
4. 更新旧部件状态为 'available'
5. 更新新部件状态为 'installed'

事务边界: 整个更换过程
失败回滚: 任一步骤失败，整个事务回滚
```

### 5.2 事务场景二：退役处理事务
```
业务流程:
1. 检查部件当前是否仍处于安装状态（有 removal_time IS NULL 的记录）
2. 若仍安装，则拒绝退役或要求先拆卸（根据业务规则）
3. 写入退役记录到 ScrapOrRetirementRecord
4. 更新部件状态为 'retired'，is_retired = TRUE

事务边界: 整个退役过程
失败回滚: 任一步骤失败，整个事务回滚
```

### 5.3 事务场景三：维修完成事务（可选）
```
业务流程:
1. 登记维修工单（start_time）
2. 更新维修结果（end_time, result）
3. 根据维修结果调整部件状态

事务边界: 维修完成更新过程
```

---

## 六、历史保留机制

### 6.1 安装记录历史保留
- InstallationRecord 使用时间区间（installation_time + removal_time）
- 拆卸时只设置 removal_time，不删除或更新旧记录
- removal_time IS NULL 表示当前仍在安装中
- 可查询任意时间点的安装状态

### 6.2 部件状态历史
- Component 表只保存当前状态
- 通过 InstallationRecord 和 MaintenanceRecord 可追溯状态变化历史
- 可通过时间点查询重建历史状态

---

## 七、查询设计

### 7.1 查询 1：部件完整生命周期追溯（核心查询）
```sql
-- 给定部件编号，查询其完整生命周期
-- 包括: 基本属性、安装历史、维修记录、退役情况、当前状态
```

### 7.2 查询 2：部件在某时间段内的飞行统计
```sql
-- 查询某部件在某时间段内的飞行次数、累计飞行时长
-- 通过关联 InstallationRecord 和 FlightLog 实现
```

### 7.3 查询 3：统计分析查询
```sql
-- 某型号部件的平均维修间隔
-- 不同飞机的部件更换频率
-- 退役原因分布
```

---

## 八、业务假设说明

1. **维修模式**: 允许拆卸后送修，部件可以在 'available' 或 'under_maintenance' 状态下创建维修记录
2. **退役前置条件**: 部件必须先拆卸（无有效安装记录）才能退役
3. **时间区间**: 使用半开区间 [start_time, end_time) 表示有效性，end_time 为 NULL 表示当前有效
4. **状态同步**: 部件状态需要在应用层或触发器中与安装/维修记录同步
5. **操作人员**: 所有操作都应关联操作员，但允许 operator_id 为 NULL（简化场景）
