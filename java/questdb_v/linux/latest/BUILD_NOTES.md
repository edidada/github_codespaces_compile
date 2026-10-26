# QuestDB 高频时序数据库源码编译说明

上游仓库：<https://github.com/questdb/questdb>（主体 Java，边界性能代码含少量
C / C++（黄瓜 SIMD）/ Rust 目标，Maven 全部一收）

脚本：`get_questdb.sh`
分支：`java/questdb_v/linux/latest`（本目录），对应 workflow `java_questdb_v_linux_latest.yml`

## 官方构建命令

README（Building QuestDB）给的就是 Maven：

```
mvn clean package -DskipTests
```

本脚本用仓库自带的 wrapper：`./mvnw --batch-mode --no-transfer-progress -DskipTests package`
（`javac` 编译目标 Java 17+，workflow 用 JDK 21 稳兼容）。

## 数据/事实

| 事实 | 出处 |
|---|---|
| 构建入口是 Maven（有 mvnw） | README |
| 产物 `core/target/questdb-<ver>.jar`，可 `java -jar` 直接当一个内嵌服务端启动 | README/docs |
| 测试跳过（CI 里跑全量测试是另一套），这里只验编译产物 | 官方 CI 拆分方式 |

## 硬门槛（任一不过就 FATAL）

- `./mvnw package` 退出码 0；
- 产出非 sources/javadoc/tests 的 `core/target/questdb-*.jar`；
- `jar tf` 里含 `io/questdb` 条目。

产物落到 `_questdb_build/artifacts/`（questdb-*.jar + jar-list.txt + revision.txt +
mvn-package.log + sha256sums.txt），由 workflow 上传 artifact `questdb-ubuntu-22.04`。
