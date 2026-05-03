# 航空部件生命周期与维修管理系统

> 课程项目 - 数据库设计与实现

## 项目概述

本项目实现了一个完整的航空部件生命周期与维修管理系统，以数据库为核心，支持部件的全生命周期管理，包括入库、安装、拆卸、维修、退役等关键业务流程。

## 技术栈

- **数据库：** PostgreSQL
- **设计思想：** 
  - 时间区间表示历史数据
  - 数据库层确保业务规则
  - 软删除而非物理删除
  - 触发器确保状态一致性

## 项目文件说明

| 文件 | 说明 |
|------|------|
| [database_design.md](file:///workspace/database_design.md) | 详细的数据库设计文档（需求分析、ER图、逻辑模式） |
| [schema.sql](file:///workspace/schema.sql) | 数据库建表脚本（表、约束、索引、触发器、视图、存储过程、函数） |
| [init_data.sql](file:///workspace/init_data.sql) | 初始化数据脚本（演示数据） |
| [AI_Audit_Report.md](file:///workspace/AI_Audit_Report.md) | AI 使用审计报告 |
| [.trae/specs/](file:///workspace/.trae/specs/aviation_component_lifecycle/) | 规划文档目录（PRD、任务清单、验证清单） |

## 数据库设计要点

### 核心数据表（8张）

1. **Operator** - 操作人员表
2. **Aircraft** - 飞机表
3. **ComponentModel** - 部件型号表
4. **Component** - 部件实例表
5. **InstallationRecord** - 安装记录表（时间区间表示历史）
6. **MaintenanceRecord** - 维修记录表
7. **FlightLog** - 飞行记录表
8. **ScrapOrRetirementRecord** - 退役记录表

### 关键约束实现

| 业务规则 | 实现方式 |
|---------|---------|
| 安装唯一性 | 部分唯一索引 `idx_unique_active_installation` |
| 时间合理性 | CHECK 约束（end_time >= start_time） |
| 防止物理删除 | 触发器 `trigger_prevent_delete_*` |
| 状态一致性 | 触发器 `trigger_sync_retirement` |
| 退役后拒绝操作 | 触发器 `trigger_prevent_*_on_retired` |

### 事务存储过程

| 存储过程 | 说明 |
|---------|------|
| `sp_install_component` | 部件安装事务 |
| `sp_remove_component` | 部件拆卸事务 |
| `sp_replace_component` | 部件更换事务（原子操作） |
| `sp_retire_component` | 部件退役事务 |

### 视图和查询函数

| 对象 | 说明 |
|------|------|
| `v_component_current_status` | 部件当前状态视图 |
| `v_component_installation_history` | 部件安装历史视图 |
| `v_component_lifecycle_summary` | 部件生命周期汇总视图 |
| `v_model_maintenance_stats` | 型号维修统计视图（加分项） |
| `v_aircraft_component_changes` | 飞机部件更换频率视图（加分项） |
| `v_retirement_reason_distribution` | 退役原因分布视图（加分项） |
| `func_get_component_lifecycle()` | 部件完整生命周期追溯函数（核心功能） |
| `func_get_component_flight_stats()` | 部件飞行统计函数 |

## 快速开始

### 1. 创建数据库

```sql
-- 在 PostgreSQL 中执行
CREATE DATABASE aviation_component_management;
\c aviation_component_management;
```

### 2. 执行建表脚本

```bash
psql -d aviation_component_management -f schema.sql
```

### 3. 插入初始化数据

```bash
psql -d aviation_component_management -f init_data.sql
```

### 4. 演示核心功能

#### 查看部件当前状态
```sql
SELECT * FROM v_component_current_status;
```

#### 查询部件完整生命周期
```sql
SELECT * FROM func_get_component_lifecycle('COMP-001');
```

#### 部件安装（使用事务）
```sql
BEGIN;
CALL sp_install_component(5, 1, 'Wing Leading Edge', 'New installation', 1);
COMMIT;
```

#### 部件拆卸（使用事务）
```sql
BEGIN;
CALL sp_remove_component(1, 'Scheduled removal', 2);
COMMIT;
```

#### 部件更换（使用事务）
```sql
BEGIN;
CALL sp_replace_component(3, 4, 2, 'Left Navigation Bay 1', 'Upgrade', 'New component', 1);
COMMIT;
```

#### 部件退役（使用事务）
```sql
-- 注意：部件必须先拆卸才能退役
BEGIN;
CALL sp_remove_component(5, 'Preparing for retirement', 1);
CALL sp_retire_component(5, 'end_of_life', 4, 'Reached design life');
COMMIT;
```

## 非法操作拦截演示

### 1. 尝试物理删除部件
```sql
DELETE FROM Component WHERE component_id = 1;
-- 结果：报错，触发器阻止物理删除
```

### 2. 尝试安装已退役部件
```sql
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_time)
VALUES (6, 1, 'Test Position', NOW());
-- 结果：报错，触发器检查到部件已退役
```

### 3. 尝试重复安装同一部件
```sql
-- COMP-001 当前已安装，尝试再次安装
INSERT INTO InstallationRecord (component_id, aircraft_id, installation_position, installation_time)
VALUES (1, 1, 'Another Position', NOW());
-- 结果：报错，部分唯一索引阻止
```

## 课程评分标准对照

| 评分项 | 实现情况 | 说明 |
|-------|---------|------|
| **数据模式设计（20分）** | ✅ 完成 | 8张核心表，区分型号/实例，时间区间表示历史 |
| **完整性约束（20分）** | ✅ 完成 | PK/FK/UK/CHECK/触发器，业务规则在数据库层实现 |
| **增删改逻辑（20分）** | ✅ 完成 | 安装/更换/维修/退役逻辑正确，历史保留，软删除 |
| **事务设计（15分）** | ✅ 完成 | 4个存储过程实现事务，边界清晰 |
| **查询分析（15分）** | ✅ 完成 | 生命周期追溯、多个统计查询、视图 |
| **AI使用与反思（10分）** | ✅ 完成 | 完整的审计报告，记录错误和修正过程 |
| **加分项** | ✅ 部分实现 | 区分当前状态/历史事件、数据库层规则、多个统计分析 |

## 业务假设说明

1. **维修模式**：允许拆卸后送修（部件可在非安装状态下维修）
2. **退役前置条件**：部件必须先拆卸才能退役
3. **时间区间**：使用半开区间 [start, end) 表示有效性
4. **状态同步**：主要通过触发器和存储过程自动同步
5. **操作人员**：所有操作应关联操作员，但允许 NULL（简化演示）

## 项目亮点

1. **完整的历史保留**：所有变更都有时间戳记录，从不覆盖
2. **数据库层规则**：所有关键业务规则在数据库层面实现，不依赖应用
3. **强大的追溯功能**：一键查询部件完整生命周期
4. **丰富的统计视图**：提供多个业务视角的数据分析
5. **规范的文档**：完整的设计文档、审计报告和演示用例

## 联系方式

如有问题，请查看详细设计文档 [database_design.md](file:///workspace/database_design.md)。
