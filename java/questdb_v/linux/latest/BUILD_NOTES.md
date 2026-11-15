# QuestDB 高频时序数据库源码编译说明

上游仓库：<https://github.com/questdb/questdb>（主体 Java，边界性能代码含少量
C / C++（黄瓜 SIMD）/ Rust 目标，Maven 全部一收）

脚本：`get_questdb.sh`
分支：`java/questdb_v/linux/latest`（本目录），对应 workflow `java_questdb_v_linux_latest.yml`

## 官方构建命令

README（Building QuestDB）给的是 Maven。仓库根有 `pom.xml`（**没有 mvnw**），所以
直接用 runner 自带的 `mvn`：

```
mvn --batch-mode --no-transfer-progress -DskipTests package
```

（脚本启动前校验 `pom.xml` 与 `mvn` 都在，并打印 mvn 版本。）

**必须 JDK 25**（2026-10-26 实测 master @ 0151d5e）：core/pom.xml 顶层属性
`javac.target=25`（Java 8 字头是 javac target），而 enforcer 的 `java.enforce.version`
只在 `java25+` profile（activation `<jdk>(24,)`）里定义。JDK <25 时该 profile 不激活，
`${java.enforce.version}` 解析为空，enforcer 直接报
`RequireJavaVersion failed: JDK version can't be empty.`——所以 workflow 里钉死 JDK 25。

## 数据/事实

| 事实 | 出处 |
|---|---|
| `mvn package -DskipTests` 为构建入口（仓库根 pom.xml，无 mvnw） | README |
| 产物 `core/target/questdb-<ver>.jar`，可 `java -jar` 直接当一个内嵌服务端启动 | README/docs |
| 测试跳过（CI 里跑全量测试是另一套），这里只验编译产物 | 官方 CI 拆分方式 |

## 硬门槛（任一不过就 FATAL）

- `mvn package` 退出码 0；
- 产出非 sources/javadoc/tests 的 `core/target/questdb-*.jar`；
- `jar tf` 里含 `io/questdb` 条目。

产物落到 `_questdb_build/artifacts/`（questdb-*.jar + jar-list.txt + revision.txt +
mvn-package.log + sha256sums.txt），由 workflow 上传 artifact `questdb-ubuntu-22.04`。
