# Simple SBM Initializer



## 开始使用

DOS命令行输入:

```shell
create-project.cmd <产品简称> <公司简称>
```

## 使用案例

### 输入

```sh
D:/> create-project.cmd prod01 xflib
```

### 输出成果

产品prod01的源代码目录结构：

```
xflib-prod01
|--xflib-prod01-parent
|--xflib-prod01-common
|--xflib-prod01-utils
|--xflib-prod01-bisness
|--xflib-prod01-service
```

其中，xflib-prod01-service是可启动的工程，我们看一下依赖树：

```
$ cd xflib-prod01/xflib-prod01-service
$ mvn clean dependency:tree
...(此处省略了其他无关信息)
[INFO] com.xflib.prod03:xflib-prod03-service:jar:1.0.0
[INFO] ...(此处省略了第三方依赖)
[INFO] \- com.xflib.prod03:xflib-prod03-business:jar:1.0.0:compile
[INFO]    \- com.xflib.prod03:xflib-prod03-utils:jar:1.0.0:compile
[INFO]       \- com.xflib.prod03:xflib-prod03-common:jar:1.0.0:compile
...(此处省略了其他无关信息)
```

下面用表格来进行说明各个项目的作用：

| No.  | project                   | purpose    | remark                                                       |
| ---- | ------------------------- | ---------- | ------------------------------------------------------------ |
| 1    | **`xflib-prod01`**        | 产品管理   | 用于将产品prod01的所有项目组织在一起                         |
| 2    | **`xflib-prod01-parent`** | 父项目     | 1. 为本产品父项目, 也是第三方聚合的引用包<br>2. 为本产品的输出包进行定义和版本管理<br>3. 为本产品引用的的第三方依赖包进行定义和版本管理，<br/>4. 为本产品统一定义一些其他例如构建插件、属性等设置 |
| 3    | `xflib-prod01-common`     | 基础项目   | **继承`xflib-prod01-parent`**，存储一些最基本的公共类        |
| 4    | `xflib-prod01-utils`      | 工具项目   | **继承`xflib-prod01-parent`**                                |
| 5    | `xflib-prod01-bisness`    | 业务项目   | **继承`xflib-prod01-parent`**                                |
| 6    | `xflib-prod01-service`    | 可执行项目 |                                                              |

## 可供聚合的POM文件

`xflib-prod01/xflib-prod01-parent/pom.xml`