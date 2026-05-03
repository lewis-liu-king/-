# 航空部件生命周期与维修管理系统 - 系统设计计划

> 创建时间：2025年  
> 项目目标：前后端分离的数据库管理可视化系统

---

## 一、项目概述

### 1.1 项目目标

基于已有的航空部件生命周期数据库，设计并实现一个**专业仪表盘风格**的 Web 管理系统，提供清晰、直观的界面来管理数据库中的所有业务数据。

### 1.2 技术栈选择

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| **数据库** | PostgreSQL/MySQL | 保持原有设计，适配目标数据库 |
| **后端** | FastAPI + SQLAlchemy | Python 高性能 API 框架 |
| **前端** | React + TypeScript | 组件化现代前端框架 |
| **UI 组件库** | Ant Design | 专业仪表盘组件库 |
| **状态管理** | React Query | 服务端状态管理 |
| **路由** | React Router | 单页应用路由 |
| **HTTP 客户端** | Axios | API 请求封装 |

### 1.3 项目约束

- ✅ **无需用户认证** - 简化系统复杂度
- ✅ **后端 API 模式** - 前后端分离架构
- ✅ **专业仪表盘风格** - 数据可视化丰富
- ✅ **数据管理为主** - 突出 CRUD 操作便捷性

---

## 二、系统架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     客户端浏览器                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    React 前端应用                        │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │  │
│  │  │ 仪表盘  │ │ 数据管理 │ │生命周期 │ │ 统计分析 │ │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └───────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP REST API
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    FastAPI 后端服务                          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    API 路由层                          │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │  │
│  │  │ /aircraft│ │/component│ │/install │ │/maintain │ │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └───────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   业务逻辑层                           │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │  │
│  │  │CRUD服务 │ │事务服务 │ │查询服务 │ │报表服务  │ │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └───────────┘ │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   数据访问层                           │  │
│  │            SQLAlchemy ORM + Alembic 迁移              │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ SQL
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     PostgreSQL 数据库                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  8 张核心业务表 + 视图 + 函数 + 触发器                │  │
│  │  (保持原有设计)                                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 项目目录结构

```
aviation-system/
├── backend/                          # 后端项目目录
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                  # FastAPI 应用入口
│   │   ├── config.py                # 配置管理
│   │   ├── database.py              # 数据库连接
│   │   ├── models/                  # SQLAlchemy 模型
│   │   │   ├── __init__.py
│   │   │   ├── operator.py
│   │   │   ├── aircraft.py
│   │   │   ├── component_model.py
│   │   │   ├── component.py
│   │   │   ├── installation.py
│   │   │   ├── maintenance.py
│   │   │   ├── flight.py
│   │   │   └── retirement.py
│   │   ├── schemas/                 # Pydantic 模式
│   │   │   ├── __init__.py
│   │   │   ├── operator.py
│   │   │   ├── aircraft.py
│   │   │   ├── component.py
│   │   │   └── ...
│   │   ├── api/                     # API 路由
│   │   │   ├── __init__.py
│   │   │   ├── operators.py
│   │   │   ├── aircrafts.py
│   │   │   ├── components.py
│   │   │   ├── installations.py
│   │   │   ├── maintenances.py
│   │   │   ├── flights.py
│   │   │   └── retirements.py
│   │   ├── services/                # 业务逻辑服务
│   │   │   ├── __init__.py
│   │   │   ├── component_service.py
│   │   │   ├── installation_service.py
│   │   │   ├── maintenance_service.py
│   │   │   └── report_service.py
│   │   └── utils/                   # 工具函数
│   │       └── exceptions.py
│   ├── tests/                       # 测试目录
│   │   ├── __init__.py
│   │   ├── test_api/
│   │   └── test_services/
│   ├── alembic/                     # 数据库迁移
│   │   ├── env.py
│   │   └── versions/
│   ├── requirements.txt
│   └── alembic.ini
│
├── frontend/                        # 前端项目目录
│   ├── src/
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   ├── index.css
│   │   ├── api/                    # API 请求封装
│   │   │   ├── client.ts           # Axios 配置
│   │   │   ├── aircraft.ts
│   │   │   ├── component.ts
│   │   │   └── ...
│   │   ├── components/              # 公共组件
│   │   │   ├── Layout/
│   │   │   ├── DataTable/
│   │   │   └── FormModal/
│   │   ├── pages/                   # 页面组件
│   │   │   ├── Dashboard/
│   │   │   ├── Aircraft/
│   │   │   ├── Component/
│   │   │   ├── Installation/
│   │   │   ├── Maintenance/
│   │   │   ├── Flight/
│   │   │   └── Retirement/
│   │   ├── hooks/                   # 自定义 Hooks
│   │   ├── types/                  # TypeScript 类型
│   │   └── utils/                  # 工具函数
│   ├── public/
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── .env
│
├── docker-compose.yml               # Docker 编排（可选）
├── SPEC.md                         # 本文档
└── README.md
```

---

## 三、功能模块设计

### 3.1 仪表盘（Dashboard）

**功能描述：** 系统首页，展示关键业务指标和数据概览

**界面布局：**
```
┌────────────────────────────────────────────────────────────┐
│  航空部件生命周期管理系统                          [用户] │
├────────────────────────────────────────────────────────────┤
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│ │ 总飞机数  │ │ 活跃部件  │ │ 维修中   │ │ 已退役   │    │
│ │    3     │ │    5     │ │    1     │ │    1     │    │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘    │
│                                                            │
│ ┌─────────────────────────────┐ ┌──────────────────────┐  │
│ │     部件状态分布（饼图）    │ │   近30天安装趋势     │  │
│ │                             │ │      (折线图)        │  │
│ └─────────────────────────────┘ └──────────────────────┘  │
│                                                            │
│ ┌──────────────────────────────────────────────────────┐  │
│ │              最近安装记录                              │  │
│ │  部件编号 | 飞机 | 位置 | 时间 | 操作员              │  │
│ │  ────────────────────────────────────────────────────│  │
│ │  COMP-003 | B-5678 | Left Nav | 2024-01-15 | 张三  │  │
│ └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

**API 接口：**
- `GET /api/dashboard/stats` - 获取统计数据
- `GET /api/dashboard/recent-installations` - 最近安装记录
- `GET /api/dashboard/component-status-distribution` - 部件状态分布

### 3.2 飞机管理（Aircraft Management）

**功能描述：** 管理和查看所有飞机信息

**界面布局：**
```
┌────────────────────────────────────────────────────────────┐
│  飞机管理                                        [添加]  │
├────────────────────────────────────────────────────────────┤
│  搜索: [__________] 状态: [全部 ▼]              [搜索]  │
├────────────────────────────────────────────────────────────┤
│ ┌────┬───────────┬────────┬────────┬──────────┬────────┐ │
│ │ ID │ 飞机编号  │ 型号   │ 状态   │ 启用日期  │ 操作  │ │
│ ├────┼───────────┼────────┼────────┼──────────┼────────┤ │
│ │ 1  │ B-1234   │ B737-8 │ 活跃   │ 2020-01-15│编辑删除│ │
│ │ 2  │ B-5678   │ A320neo│ 活跃   │ 2021-06-20│编辑删除│ │
│ │ 3  │ B-9012   │ B787-9 │ 停用   │ 2019-03-10│编辑删除│ │
│ └────┴───────────┴────────┴────────┴──────────┴────────┘ │
│                                                            │
│                    < 1 2 3 >     显示 10 条/页            │
└────────────────────────────────────────────────────────────┘
```

**功能点：**
- ✅ 列表展示（分页、排序、搜索）
- ✅ 添加飞机
- ✅ 编辑飞机信息
- ✅ 查看飞机详情（关联的安装记录、飞行记录）

**API 接口：**
- `GET /api/aircrafts` - 获取飞机列表（分页、搜索）
- `GET /api/aircrafts/{id}` - 获取飞机详情
- `POST /api/aircrafts` - 创建飞机
- `PUT /api/aircrafts/{id}` - 更新飞机
- `DELETE /api/aircrafts/{id}` - 删除飞机（软删除）
- `GET /api/aircrafts/{id}/installations` - 获取飞机的安装记录
- `GET /api/aircrafts/{id}/flights` - 获取飞机的飞行记录

### 3.3 部件管理（Component Management）

**功能描述：** 管理部件实例，包括入库、安装、拆卸等操作

**界面布局：**
```
┌────────────────────────────────────────────────────────────┐
│  部件管理                            [部件入库] [更换部件] │
├────────────────────────────────────────────────────────────┤
│ 搜索: [__________] 型号: [全部 ▼] 状态: [全部 ▼]  [搜索] │
├────────────────────────────────────────────────────────────┤
│ ┌────┬────────────┬──────────┬────────┬────────┬─────────┐│
│ │编号│ 部件型号   │ 批次     │ 状态   │使用时长│ 操作   ││
│ ├────┼────────────┼──────────┼────────┼────────┼─────────┤│
│ │ C1 │ CFM56-7B  │ BATCH-01 │ 已安装 │ 5000h  │详情拆卸││
│ │ C2 │ GTN-750   │ BATCH-02 │ 可用   │ 0h     │详情安装││
│ │ C3 │ WRN-01    │ BATCH-03 │ 维修中 │ 3000h  │详情   ││
│ └────┴────────────┴──────────┴────────┴────────┴─────────┘│
└────────────────────────────────────────────────────────────┘
```

**功能点：**
- ✅ 列表展示（分页、排序、多条件搜索）
- ✅ 部件入库（创建新部件）
- ✅ 部件安装（触发事务）
- ✅ 部件拆卸（触发事务）
- ✅ 部件更换（触发事务）
- ✅ 部件退役（触发事务）
- ✅ 查看部件生命周期追溯

**API 接口：**
- `GET /api/components` - 获取部件列表
- `GET /api/components/{id}` - 获取部件详情
- `POST /api/components` - 创建部件（入库）
- `PUT /api/components/{id}` - 更新部件
- `DELETE /api/components/{id}` - 删除部件
- `POST /api/components/{id}/install` - 部件安装
- `POST /api/components/{id}/remove` - 部件拆卸
- `POST /api/components/replace` - 部件更换
- `POST /api/components/{id}/retire` - 部件退役
- `GET /api/components/{id}/lifecycle` - 部件生命周期追溯

### 3.4 维修管理（Maintenance Management）

**功能描述：** 管理和记录部件维修信息

**功能点：**
- ✅ 维修记录列表
- ✅ 创建维修工单
- ✅ 更新维修结果
- ✅ 查看部件维修历史

**API 接口：**
- `GET /api/maintenances` - 获取维修记录列表
- `GET /api/maintenances/{id}` - 获取维修详情
- `POST /api/maintenances` - 创建维修记录
- `PUT /api/maintenances/{id}` - 更新维修记录
- `GET /api/components/{id}/maintenances` - 获取部件维修历史

### 3.5 飞行记录管理（Flight Log Management）

**功能描述：** 记录和查看飞机飞行任务

**功能点：**
- ✅ 飞行记录列表
- ✅ 登记飞行任务
- ✅ 飞行数据统计

**API 接口：**
- `GET /api/flights` - 获取飞行记录列表
- `GET /api/flights/{id}` - 获取飞行详情
- `POST /api/flights` - 创建飞行记录
- `PUT /api/flights/{id}` - 更新飞行记录
- `GET /api/aircrafts/{id}/flights` - 获取飞机的飞行记录

### 3.6 统计分析（Statistics & Reports）

**功能描述：** 提供数据分析和可视化报表

**界面布局：**
```
┌────────────────────────────────────────────────────────────┐
│  统计分析                                                   │
├────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────┐ ┌──────────────────────┐│
│ │  部件状态分布                │ │  退役原因分布         ││
│ │      [饼图]                  │ │      [饼图]           ││
│ └──────────────────────────────┘ └──────────────────────┘│
│                                                            │
│ ┌──────────────────────────────────────────────────────┐  │
│ │  部件更换频率排行                                      │  │
│ │  飞机编号 | 更换次数 | 最后更换时间                    │  │
│ │  ────────────────────────────────────────────────────│  │
│ │  B-1234  |    5     |   2024-01-20                 │  │
│ │  B-5678  |    3     |   2024-01-18                 │  │
│ └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

**功能点：**
- ✅ 部件状态分布统计
- ✅ 退役原因分布统计
- ✅ 飞机部件更换频率统计
- ✅ 型号维修间隔统计
- ✅ 飞行时长统计

**API 接口：**
- `GET /api/reports/component-status` - 部件状态分布
- `GET /api/reports/retirement-distribution` - 退役原因分布
- `GET /api/reports/replacement-frequency` - 更换频率统计
- `GET /api/reports/maintenance-interval` - 维修间隔统计

---

## 四、数据库设计调整

### 4.1 数据库选型建议

**推荐使用 PostgreSQL**，原因：
- ✅ 完整支持原有设计（触发器、存储过程、视图、函数）
- ✅ 支持部分唯一索引（安装唯一性约束）
- ✅ 更好的事务支持
- ✅ JSON/JSONB 支持
- ✅ 丰富的分析函数

### 4.2 数据库配置

```python
# backend/app/config.py
DATABASE_URL = "postgresql://user:password@localhost:5432/aviation_db"
```

### 4.3 ORM 模型映射

```python
# backend/app/models/component.py
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.database import Base

class Component(Base):
    __tablename__ = "components"
    
    component_id = Column(Integer, primary_key=True, index=True)
    component_serial = Column(String(50), unique=True, nullable=False)
    model_id = Column(Integer, ForeignKey("component_models.model_id"))
    batch_number = Column(String(50))
    manufacture_date = Column(Date)
    status = Column(String(30), nullable=False)  # available, installed, under_maintenance, retired
    total_usage_hours = Column(Numeric(10, 2), default=0)
    is_retired = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 关系
    model = relationship("ComponentModel", back_populates="components")
    installations = relationship("InstallationRecord", back_populates="component")
    maintenances = relationship("MaintenanceRecord", back_populates="component")
    retirement = relationship("ScrapOrRetirementRecord", uselist=False)
```

---

## 五、API 接口设计

### 5.1 统一响应格式

```typescript
// 成功响应
{
  "success": true,
  "data": { ... },
  "message": "操作成功"
}

// 错误响应
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "数据验证失败",
    "details": [...]
  }
}
```

### 5.2 分页响应格式

```typescript
{
  "success": true,
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "pageSize": 10,
    "totalPages": 10
  }
}
```

### 5.3 核心 API 端点

| 模块 | 方法 | 端点 | 说明 |
|------|------|------|------|
| **仪表盘** | GET | `/api/dashboard/stats` | 获取统计数据 |
| **飞机** | GET | `/api/aircrafts` | 飞机列表 |
| **飞机** | POST | `/api/aircrafts` | 创建飞机 |
| **飞机** | PUT | `/api/aircrafts/{id}` | 更新飞机 |
| **飞机** | DELETE | `/api/aircrafts/{id}` | 删除飞机 |
| **部件** | GET | `/api/components` | 部件列表 |
| **部件** | POST | `/api/components` | 部件入库 |
| **部件** | POST | `/api/components/{id}/install` | 部件安装 |
| **部件** | POST | `/api/components/{id}/remove` | 部件拆卸 |
| **部件** | POST | `/api/components/replace` | 部件更换 |
| **部件** | POST | `/api/components/{id}/retire` | 部件退役 |
| **部件** | GET | `/api/components/{id}/lifecycle` | 生命周期追溯 |
| **维修** | GET | `/api/maintenances` | 维修记录列表 |
| **维修** | POST | `/api/maintenances` | 创建维修记录 |
| **飞行** | GET | `/api/flights` | 飞行记录列表 |
| **飞行** | POST | `/api/flights` | 创建飞行记录 |
| **统计** | GET | `/api/reports/*` | 各类统计报表 |

---

## 六、前端组件设计

### 6.1 页面路由

```typescript
// frontend/src/router/index.tsx
const routes = [
  { path: '/', element: <Dashboard /> },
  { path: '/aircrafts', element: <AircraftList /> },
  { path: '/aircrafts/:id', element: <AircraftDetail /> },
  { path: '/components', element: <ComponentList /> },
  { path: '/components/:id', element: <ComponentDetail /> },
  { path: '/components/:id/lifecycle', element: <ComponentLifecycle /> },
  { path: '/maintenances', element: <MaintenanceList /> },
  { path: '/flights', element: <FlightList /> },
  { path: '/reports', element: <Reports /> },
]
```

### 6.2 核心组件列表

| 组件 | 类型 | 说明 |
|------|------|------|
| `AppLayout` | 布局组件 | 主布局（侧边栏 + 内容区） |
| `DataTable` | 通用组件 | 通用数据表格（分页、排序、搜索） |
| `FormModal` | 通用组件 | 表单弹窗（新增/编辑） |
| `StatusTag` | 展示组件 | 状态标签（可用、已安装、维修中、已退役） |
| `ConfirmModal` | 交互组件 | 确认对话框（删除、退役等危险操作） |
| `StatisticsCard` | 展示组件 | 统计卡片（数字 + 趋势） |
| `LifecycleTimeline` | 展示组件 | 生命周期时间线 |

### 6.3 Hooks 设计

```typescript
// 数据获取 Hooks
useAircrafts(params)      // 飞机列表
useAircraft(id)           // 飞机详情
useComponents(params)     // 部件列表
useComponent(id)         // 部件详情
useComponentLifecycle(id) // 部件生命周期

// 操作 Hooks
useCreateAircraft()      // 创建飞机
useUpdateAircraft()      // 更新飞机
useInstallComponent()    // 安装部件
useRemoveComponent()     // 拆卸部件
useReplaceComponent()    // 更换部件
useRetireComponent()     // 退役部件
```

---

## 七、业务逻辑实现

### 7.1 部件安装事务

```python
# backend/app/services/component_service.py
async def install_component(
    component_id: int,
    aircraft_id: int,
    position: str,
    operator_id: int,
    reason: str = None,
    install_time: datetime = None
):
    """
    部件安装业务逻辑
    
    步骤：
    1. 检查部件是否存在且未退役
    2. 检查部件当前是否已安装
    3. 检查飞机是否存在且活跃
    4. 创建安装记录
    5. 更新部件状态
    """
    async with get_db_transaction():
        # 检查部件状态
        component = await get_component(component_id)
        if component.is_retired:
            raise BusinessException("部件已退役，无法安装")
        if component.status == "installed":
            raise BusinessException("部件已安装在其他飞机上")
        
        # 检查飞机状态
        aircraft = await get_aircraft(aircraft_id)
        if aircraft.status != "active":
            raise BusinessException("飞机状态不活跃")
        
        # 创建安装记录
        installation = await create_installation_record(
            component_id=component_id,
            aircraft_id=aircraft_id,
            position=position,
            operator_id=operator_id,
            reason=reason,
            install_time=install_time
        )
        
        # 更新部件状态
        await update_component_status(component_id, "installed")
        
        return installation
```

### 7.2 部件更换事务

```python
async def replace_component(
    old_component_id: int,
    new_component_id: int,
    aircraft_id: int,
    position: str,
    operator_id: int,
    removal_reason: str,
    install_reason: str
):
    """
    部件更换业务逻辑（原子操作）
    
    步骤：
    1. 关闭旧部件的当前安装记录
    2. 更新旧部件状态为 available
    3. 检查新部件是否可用
    4. 创建新部件的安装记录
    5. 更新新部件状态为 installed
    """
    async with get_db_transaction():
        # 1. 关闭旧部件安装记录
        await close_installation(old_component_id, operator_id, removal_reason)
        
        # 2. 更新旧部件状态
        await update_component_status(old_component_id, "available")
        
        # 3. 检查新部件可用性
        new_component = await get_component(new_component_id)
        if new_component.is_retired or new_component.status == "installed":
            raise BusinessException("新部件不可用")
        
        # 4. 创建新安装记录
        await create_installation_record(
            component_id=new_component_id,
            aircraft_id=aircraft_id,
            position=position,
            operator_id=operator_id,
            reason=install_reason
        )
        
        # 5. 更新新部件状态
        await update_component_status(new_component_id, "installed")
```

### 7.3 部件退役事务

```python
async def retire_component(
    component_id: int,
    reason: str,
    operator_id: int,
    notes: str = None
):
    """
    部件退役业务逻辑
    
    步骤：
    1. 检查部件是否仍处于安装状态
    2. 如果安装中，先要求拆卸
    3. 检查是否已退役
    4. 创建退役记录
    5. 更新部件状态（触发器也会更新）
    """
    async with get_db_transaction():
        # 1. 检查是否有有效安装记录
        active_installation = await get_active_installation(component_id)
        if active_installation:
            raise BusinessException("部件仍在安装中，请先拆卸")
        
        # 2. 检查是否已退役
        existing_retirement = await get_retirement(component_id)
        if existing_retirement:
            raise BusinessException("部件已退役")
        
        # 3. 创建退役记录
        retirement = await create_retirement_record(
            component_id=component_id,
            reason=reason,
            operator_id=operator_id,
            notes=notes
        )
        
        # 4. 状态由数据库触发器自动更新
        return retirement
```

---

## 八、错误处理设计

### 8.1 自定义异常类

```python
# backend/app/utils/exceptions.py
class BusinessException(Exception):
    """业务异常"""
    def __init__(self, message: str, code: str = "BUSINESS_ERROR"):
        self.message = message
        self.code = code
        super().__init__(message)

class ValidationException(Exception):
    """验证异常"""
    def __init__(self, message: str, details: list = None):
        self.message = message
        self.details = details or []
        super().__init__(message)

class NotFoundException(Exception):
    """资源不存在异常"""
    def __init__(self, resource: str):
        self.message = f"{resource} 不存在"
        self.code = "NOT_FOUND"
        super().__init__(self.message)
```

### 8.2 全局异常处理器

```python
# backend/app/main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

@app.exception_handler(BusinessException)
async def business_exception_handler(request: Request, exc: BusinessException):
    return JSONResponse(
        status_code=400,
        content={
            "success": False,
            "error": {
                "code": exc.code,
                "message": exc.message
            }
        }
    )

@app.exception_handler(NotFoundException)
async def not_found_exception_handler(request: Request, exc: NotFoundException):
    return JSONResponse(
        status_code=404,
        content={
            "success": False,
            "error": {
                "code": exc.code,
                "message": exc.message
            }
        }
    )
```

---

## 九、数据库触发器兼容性

### 9.1 PostgreSQL 触发器（原有设计）

原有设计使用 PostgreSQL 的以下特性：
- ✅ 触发器函数 `prevent_delete_core_data()`
- ✅ 触发器函数 `check_component_before_install()`
- ✅ 触发器函数 `sync_component_on_retirement()`
- ✅ 部分唯一索引 `idx_unique_active_installation`

### 9.2 MySQL 转换建议（如需使用 MySQL）

如果必须使用 MySQL，需要进行以下转换：

| PostgreSQL 特性 | MySQL 等价实现 |
|----------------|----------------|
| 触发器 | MySQL 触发器（语法略有不同） |
| 部分唯一索引 | `WHERE` 条件需要移除，使用应用层约束 |
| SERIAL 主键 | AUTO_INCREMENT |
| `NOW()` | `CURRENT_TIMESTAMP` |
| `EXTRACT(EPOCH FROM ...)` | `TIMESTAMPDIFF(SECOND, ...)` |
| 存储过程 | 应用层事务 + 普通 SQL |

**建议：继续使用 PostgreSQL**，兼容性更好，功能更完整。

---

## 十、部署方案

### 10.1 开发环境

```bash
# 1. 克隆项目
git clone <repository>
cd aviation-system

# 2. 启动后端
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload

# 3. 启动前端
cd frontend
npm install
npm run dev
```

### 10.2 Docker 部署（可选）

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: aviation_db
      POSTGRES_USER: aviation_user
      POSTGRES_PASSWORD: aviation_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
      - ./init_data.sql:/docker-entrypoint-initdb.d/02-data.sql

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://aviation_user:aviation_password@db:5432/aviation_db
    depends_on:
      - db

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

volumes:
  postgres_data:
```

---

## 十一、测试策略

### 11.1 后端测试

```python
# backend/tests/test_api/test_components.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_install_component_success():
    """测试成功安装部件"""
    response = client.post(
        "/api/components/1/install",
        json={
            "aircraft_id": 1,
            "position": "Left Engine",
            "operator_id": 1,
            "reason": "New installation"
        }
    )
    assert response.status_code == 200
    assert response.json()["success"] == True

def test_install_retired_component_fail():
    """测试安装已退役部件失败"""
    response = client.post(
        "/api/components/6/install",  # 假设 ID=6 是已退役部件
        json={
            "aircraft_id": 1,
            "position": "Test",
            "operator_id": 1
        }
    )
    assert response.status_code == 400
    assert response.json()["success"] == False
```

### 11.2 前端测试

```typescript
// frontend/src/__tests__/components/DataTable.test.tsx
import { render, screen } from '@testing-library/react';
import { DataTable } from '../components/DataTable';

test('renders data table with correct columns', () => {
  render(<DataTable columns={columns} data={mockData} />);
  expect(screen.getByText('部件编号')).toBeInTheDocument();
});
```

---

## 十二、项目实施计划

### 阶段 1：项目初始化（1天）

- [ ] 初始化后端项目（FastAPI + SQLAlchemy）
- [ ] 初始化前端项目（React + Vite + TypeScript）
- [ ] 配置数据库连接
- [ ] 设置开发环境

### 阶段 2：后端 API 开发（3天）

- [ ] 实现数据库模型映射
- [ ] 实现 CRUD API 端点
- [ ] 实现业务逻辑服务层
- [ ] 实现事务操作（安装、拆卸、更换、退役）
- [ ] 实现统计报表 API
- [ ] 编写 API 测试

### 阶段 3：前端界面开发（3天）

- [ ] 实现基础布局组件（侧边栏、导航）
- [ ] 实现仪表盘页面
- [ ] 实现飞机管理页面
- [ ] 实现部件管理页面（含生命周期追溯）
- [ ] 实现维修管理页面
- [ ] 实现飞行记录页面
- [ ] 实现统计分析页面

### 阶段 4：集成与测试（1天）

- [ ] 前后端联调
- [ ] 功能测试
- [ ] 性能优化
- [ ] 文档完善

### 总工期：约 8 个工作日

---

## 十三、验收标准

### 13.1 功能验收

- ✅ 所有 CRUD 操作正常工作
- ✅ 部件安装、拆卸、更换、退役事务正常工作
- ✅ 生命周期追溯功能完整
- ✅ 统计报表数据准确
- ✅ 非法操作被正确拦截

### 13.2 界面验收

- ✅ 仪表盘展示关键指标
- ✅ 数据表格支持分页、排序、搜索
- ✅ 表单验证正常工作
- ✅ 操作反馈清晰（成功/失败提示）
- ✅ 响应式布局适配不同屏幕

### 13.3 性能验收

- ✅ 页面加载时间 < 2秒
- ✅ API 响应时间 < 500ms
- ✅ 支持 100+ 并发用户

---

## 十四、后续扩展建议

### 14.1 可选功能（课程加分项）

- [ ] 用户认证与权限管理
- [ ] 数据导出功能（Excel、PDF）
- [ ] 实时通知（WebSocket）
- [ ] 移动端适配
- [ ] 数据备份与恢复

### 14.2 架构优化

- [ ] 引入 Redis 缓存
- [ ] 添加 API 限流
- [ ] 实现操作日志审计
- [ ] 添加单元测试覆盖率

---

**文档版本：** 1.0  
**最后更新：** 2025年  
**作者：** AI Assistant
