# 航空部件生命周期与维修管理系统 - 系统设计计划

> 创建时间：2025年  
> 项目目标：前后端分离的数据库管理可视化系统  
> 数据库：MySQL 8.0+（用户指定）

---

## 一、项目概述

### 1.1 项目目标

基于已有的航空部件生命周期数据库，设计并实现一个**专业仪表盘风格**的 Web 管理系统，提供清晰、直观的界面来管理数据库中的所有业务数据。

### 1.2 技术栈选择

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| **数据库** | MySQL 8.0+ | 用户指定，已创建兼容脚本 |
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
│  │            SQLAlchemy ORM + MySQL 连接池              │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ SQL
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     MySQL 8.0 数据库                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  8 张核心业务表 + 视图 + 函数 + 触发器                │  │
│  │  (使用 mysql_schema.sql 初始化)                       │  │
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
│   │   ├── database.py              # MySQL 数据库连接
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
│   ├── requirements.txt
│   └── .env.example
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
├── mysql_schema.sql                 # MySQL 数据库脚本
├── docker-compose.yml               # Docker 编排（可选）
├── SPEC.md                         # 本文档
└── README.md
```

---

## 三、MySQL 兼容性说明

### 3.1 与 PostgreSQL 版本的差异

| 特性 | PostgreSQL | MySQL |
|------|-----------|-------|
| 主键自增 | `SERIAL` | `INT AUTO_INCREMENT` |
| 文本类型 | `TEXT` | `TEXT` ✅ |
| 时间戳 | `TIMESTAMP` | `DATETIME` (推荐) |
| 布尔值 | `BOOLEAN` | `TINYINT(1)` |
| 数字类型 | `NUMERIC` | `DECIMAL` |
| 部分索引 | `WHERE removal_time IS NULL` | 不支持，需用触发器 |
| 触发器语法 | 略有不同 | 使用 `DELIMITER` |
| 存储过程 | 支持 | 支持 ✅ |
| 视图 | 支持 | 支持 ✅ |

### 3.2 MySQL 特性使用

✅ **已实现的 MySQL 特性：**
- 触发器（防止删除、检查状态、同步退役）
- 存储过程（事务操作）
- 视图（数据聚合、报表）
- 函数（生命周期追溯）
- 检查约束（MySQL 8.0.16+）
- 外键约束
- 索引优化

### 3.3 MySQL 数据库脚本

**文件位置：** `mysql_schema.sql`

**包含内容：**
- 8 张核心业务表
- 6 个触发器
- 4 个存储过程
- 6 个视图
- 1 个生命周期追溯函数

---

## 四、功能模块设计

### 4.1 仪表盘（Dashboard）

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

### 4.2 飞机管理（Aircraft Management）

**功能描述：** 管理和查看所有飞机信息

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

### 4.3 部件管理（Component Management）

**功能描述：** 管理部件实例，包括入库、安装、拆卸等操作

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

### 4.4 维修管理（Maintenance Management）

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

### 4.5 飞行记录管理（Flight Log Management）

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

### 4.6 统计分析（Statistics & Reports）

**功能描述：** 提供数据分析和可视化报表

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

## 五、数据库配置

### 5.1 MySQL 连接配置

```python
# backend/app/config.py
import os

DATABASE_HOST = os.getenv("DATABASE_HOST", "localhost")
DATABASE_PORT = os.getenv("DATABASE_PORT", "3306")
DATABASE_USER = os.getenv("DATABASE_USER", "root")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD", "password")
DATABASE_NAME = os.getenv("DATABASE_NAME", "aviation_component_management")

DATABASE_URL = f"mysql+pymysql://{DATABASE_USER}:{DATABASE_PASSWORD}@{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_NAME}"
```

### 5.2 环境变量示例

```bash
# backend/.env.example
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_USER=root
DATABASE_PASSWORD=your_password
DATABASE_NAME=aviation_component_management

# API 配置
API_HOST=0.0.0.0
API_PORT=8000
```

### 5.3 MySQL 初始化

```bash
# 1. 登录 MySQL
mysql -u root -p

# 2. 执行数据库脚本
source mysql_schema.sql

# 3. 验证表创建
SHOW TABLES;
```

---

## 六、后端实现方案

### 6.1 ORM 模型映射

```python
# backend/app/models/component.py
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, DECIMAL
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime

class Component(Base):
    __tablename__ = "components"
    
    component_id = Column(Integer, primary_key=True, index=True)
    component_serial = Column(String(50), unique=True, nullable=False, index=True)
    model_id = Column(Integer, ForeignKey("component_models.model_id"), nullable=False)
    batch_number = Column(String(50))
    manufacture_date = Column(Date)
    status = Column(String(30), nullable=False, default="available")  # available, installed, under_maintenance, retired
    total_usage_hours = Column(DECIMAL(10, 2), default=0)
    is_retired = Column(Boolean, default=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 关系
    model = relationship("ComponentModel", back_populates="components")
    installations = relationship("InstallationRecord", back_populates="component")
    maintenances = relationship("MaintenanceRecord", back_populates="component")
    retirement = relationship("ScrapOrRetirementRecord", uselist=False)
```

### 6.2 API 响应格式

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

### 6.3 业务逻辑实现

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
    部件安装业务逻辑（MySQL 事务）
    """
    async with async_session() as session:
        async with session.begin():
            # 检查部件状态
            component = await session.get(Component, component_id)
            if component.is_retired:
                raise BusinessException("部件已退役，无法安装")
            if component.status == "installed":
                raise BusinessException("部件已安装在其他飞机上")
            
            # 检查飞机状态
            aircraft = await session.get(Aircraft, aircraft_id)
            if aircraft.status != "active":
                raise BusinessException("飞机状态不活跃")
            
            # 创建安装记录
            installation = InstallationRecord(
                component_id=component_id,
                aircraft_id=aircraft_id,
                installation_position=position,
                installation_reason=reason,
                installation_operator_id=operator_id,
                installation_time=install_time or datetime.now()
            )
            session.add(installation)
            
            # 更新部件状态
            component.status = "installed"
            
            return installation
```

---

## 七、前端实现方案

### 7.1 页面路由

```typescript
// frontend/src/router/index.tsx
import { createBrowserRouter } from "react-router-dom";
import { AppLayout } from "../components/Layout";
import { Dashboard } from "../pages/Dashboard";
import { AircraftList } from "../pages/Aircraft/List";
import { AircraftDetail } from "../pages/Aircraft/Detail";
import { ComponentList } from "../pages/Component/List";
import { ComponentDetail } from "../pages/Component/Detail";
import { ComponentLifecycle } from "../pages/Component/Lifecycle";
import { MaintenanceList } from "../pages/Maintenance/List";
import { FlightList } from "../pages/Flight/List";
import { Reports } from "../pages/Reports";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <AppLayout />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: "aircrafts", element: <AircraftList /> },
      { path: "aircrafts/:id", element: <AircraftDetail /> },
      { path: "components", element: <ComponentList /> },
      { path: "components/:id", element: <ComponentDetail /> },
      { path: "components/:id/lifecycle", element: <ComponentLifecycle /> },
      { path: "maintenances", element: <MaintenanceList /> },
      { path: "flights", element: <FlightList /> },
      { path: "reports", element: <Reports /> },
    ],
  },
]);
```

### 7.2 核心组件

| 组件 | 类型 | 说明 |
|------|------|------|
| `AppLayout` | 布局组件 | 主布局（侧边栏 + 内容区） |
| `DataTable` | 通用组件 | 通用数据表格（分页、排序、搜索） |
| `FormModal` | 通用组件 | 表单弹窗（新增/编辑） |
| `StatusTag` | 展示组件 | 状态标签 |
| `ConfirmModal` | 交互组件 | 确认对话框 |
| `StatisticsCard` | 展示组件 | 统计卡片 |
| `LifecycleTimeline` | 展示组件 | 生命周期时间线 |
| `Charts` | 可视化组件 | ECharts 图表组件 |

### 7.3 API 客户端

```typescript
// frontend/src/api/client.ts
import axios from 'axios';

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// 响应拦截器
apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    const message = error.response?.data?.error?.message || '请求失败';
    message.error(message);
    return Promise.reject(error);
  }
);

export default apiClient;
```

---

## 八、部署方案

### 8.1 开发环境

```bash
# 1. 克隆项目
git clone <repository>
cd aviation-system

# 2. 初始化 MySQL 数据库
mysql -u root -p < mysql_schema.sql

# 3. 启动后端
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env  # 编辑配置
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 4. 启动前端
cd frontend
npm install
npm run dev
```

### 8.2 Docker 部署

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: aviation_component_management
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql_schema.sql:/docker-entrypoint-initdb.d/01-schema.sql

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      DATABASE_HOST: db
      DATABASE_PORT: 3306
      DATABASE_USER: root
      DATABASE_PASSWORD: root_password
      DATABASE_NAME: aviation_component_management
    depends_on:
      - db

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      VITE_API_BASE_URL: http://localhost:8000/api
    depends_on:
      - backend

volumes:
  mysql_data:
```

---

## 九、项目实施计划

### 阶段 1：项目初始化（1天）

- [ ] 初始化后端项目（FastAPI + SQLAlchemy + MySQL）
- [ ] 初始化前端项目（React + Vite + TypeScript + Ant Design）
- [ ] 配置 MySQL 数据库连接
- [ ] 验证数据库脚本执行成功
- [ ] 设置开发环境

### 阶段 2：后端 API 开发（3天）

- [ ] 实现数据库模型映射（8 张表）
- [ ] 实现 CRUD API 端点（飞机、部件、型号等）
- [ ] 实现业务逻辑服务层
- [ ] 实现事务操作（安装、拆卸、更换、退役）
- [ ] 实现统计报表 API（调用 MySQL 视图和函数）
- [ ] 编写 API 测试

### 阶段 3：前端界面开发（3天）

- [ ] 实现基础布局组件（侧边栏、导航）
- [ ] 实现仪表盘页面（统计卡片、图表）
- [ ] 实现飞机管理页面（CRUD）
- [ ] 实现部件管理页面（CRUD + 生命周期追溯）
- [ ] 实现维修管理页面（CRUD）
- [ ] 实现飞行记录页面（CRUD）
- [ ] 实现统计分析页面（图表）

### 阶段 4：集成与测试（1天）

- [ ] 前后端联调
- [ ] 功能测试
- [ ] 性能优化
- [ ] 文档完善

### 总工期：约 8 个工作日

---

## 十、验收标准

### 10.1 功能验收

- ✅ 所有 CRUD 操作正常工作
- ✅ 部件安装、拆卸、更换、退役事务正常工作
- ✅ 生命周期追溯功能完整
- ✅ 统计报表数据准确
- ✅ 非法操作被正确拦截（数据库触发器）

### 10.2 界面验收

- ✅ 仪表盘展示关键指标
- ✅ 数据表格支持分页、排序、搜索
- ✅ 表单验证正常工作
- ✅ 操作反馈清晰
- ✅ 响应式布局适配

### 10.3 数据库验收

- ✅ MySQL 脚本执行成功
- ✅ 8 张表创建正确
- ✅ 触发器正常工作
- ✅ 视图可正常查询
- ✅ 存储过程可正常调用

---

## 十一、文件清单

| 文件路径 | 说明 | 状态 |
|---------|------|------|
| `mysql_schema.sql` | MySQL 数据库脚本 | ✅ 已创建 |
| `.trae/documents/aviation_system_design_plan.md` | 系统设计计划 | ✅ 已创建 |
| `schema.sql` | PostgreSQL 数据库脚本 | 📋 原版本 |
| `init_data.sql` | 初始化数据脚本 | 📋 需适配 |
| `README.md` | 项目说明文档 | 📋 需更新 |
| `database_design.md` | 数据库设计文档 | 📋 需更新 |

---

**文档版本：** 2.0（MySQL 版本）  
**最后更新：** 2025年  
**数据库：** MySQL 8.0+
