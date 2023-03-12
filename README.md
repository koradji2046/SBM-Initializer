# Spring boot框架下如何优雅的构建自己的多项目框架

> 在`Spring boot`(以下简称SB)如此流行的今天，我们开发一个产品时，通常都会使用SB框架编程，一般从[Spring Initializr](https://start.spring.io/)开始着手构建项目，简单快捷。但如果你需要将产品中的部分代码抽取出来形成公共依赖库供其他新产品使用时，新产品开发会受到SB版本的严格限制，而SB的版本每月都会升级，最终你只有这么几种方案：
>
> 1)  所有产品代码全部跟着SB升级，对于已发布的产品来说难度太大，几乎是不可能做到的；
>
> 2)  新产品不再跟着SB升级，不能享受SB技术进步带来的好处；
>
> 3)  把源码复制到新产品里面！结果是同样一份代码满天飞，维护麻烦不说，最坏的情形是BUG可能得不到及时修复，被客户投诉。
>
> 如果你有过这样的经历，一定会感同身受，如果你没经历过，照着本文的方法去组织多项目项目结构，恭喜你已经自然避坑了。

## 什么是优雅的多项目框架

其实，SB本身的项目框架是很优雅的，直接继承`spring-boot-starter-parent`构建产品项目, 如果是单一项目结构无所谓，如果是多项目结构，那你的麻烦可能从这里就开始了。

那么，如何优雅的构建自己的多项目框架呢？目睹为快，我们先看一下产品prod01的源代码目录结构：

```
xflib-prod01
|--xflib-prod01-init
|--xflib-prod01-docs
|--xflib-prod01-dependencies
|--xflib-prod01-parent
|--xflib-prod01-common
|--xflib-prod01-utils
|--xflib-prod01-bisness1..n
|--xflib-prod01-service
|--readme.md
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

| No.  | project                         | purpose  | remark                                                       |
| ---- | ------------------------------- | -------- | ------------------------------------------------------------ |
| 1    | **`xflib-prod01`**              | 产品管理 | 用于将产品prod0的所有项目组织在一起                          |
| 2    | **`xflib-prod01-dependencies`** | 依赖管理 | 为本产品的输出包进行定义和版本管理，~~这是产品的父项目~~     |
| 3    | **`xflib-prod01-parent`**       | 父项目   | ~~**继承`xflib-prod01-dependencies`**~~, 为本产品引用的的第三方依赖包<br/>进行定义和版本管理，以及一些其他例如构建插件、属性等设置 |
| 4    | `xflib-prod01-common`           | 基础项目 | **继承`xflib-prod01-parent`**，存储一些最基本的公共类        |
| 5    | `xflib-prod01-utils`            | 工具项目 | **继承`xflib-prod01-parent`**                                |
| 6    | `xflib-prod01-bisness1..N`      | 业务项目 | **继承`xflib-prod01-parent`**                                |
| 7    | `xflib-prod01-init`             | 初始化   | 各种脚本如数据库初始化脚本等                                 |
| 8    | `xflib-prod01-docs`             | 文档     | 各种产品文档如设计说明、需求说明、测试报告、安装维护说明等   |
| 9    | `readme.md`                     |          | 一般描述的是产品简介、版本记录、构建与运行说明等             |

重点关注的是**`xflib-prod01`**、**`xflib-prod01-dependencies`**、**`xflib-prod01-parent`**，这三哥俩是构建优雅多项目框架的源头：

- **`xflib-prod01`**的作用有限，与业务无关，仅仅是为了为了更好的管理产品源码而建立；
- **`xflib-prod01-dependencies`**
- **`xflib-prod01-parent`**

## 从这里开始

下面我们来看一下这三个项目的pom.xml的详细说明：

### xflib-prod01/pom.xml

#### 说明

- 用途：
  - 用于管理`<moules/>`
- 注意事项：
  - [强制]需要自行定义`<properties/>`

#### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.qzdatasoft.prod01</groupId>
    <artifactId>qzdatasoft-prod01</artifactId>
    <version>1.0.0</version>

    <packaging>pom</packaging>
    <name>qzdatasoft-prod01</name>
    <url>http://www.qzdatasoft.com</url>

    <modules>
        <module>qzdatasoft-prod01-parent</module>
        <module>qzdatasoft-prod01-dependencies</module>
        <module>qzdatasoft-prod01-common</module>
        <module>qzdatasoft-prod01-utils</module>
        <module>qzdatasoft-prod01-business</module>
        <module>qzdatasoft-prod01-service</module>
        <!-- Other Module more -->
    </modules>

    <properties>
        <java.version>1.8</java.version>
        <maven.compiler.source>${java.version}</maven.compiler.source>
        <maven.compiler.target>${java.version}</maven.compiler.target>
        <maven.build.timestamp.format>yyyyMMdd-HHmmss</maven.build.timestamp.format>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    </properties>

</project>
```

### xflib-prod01/xflib-prod01-dependencies/pom.xml

#### 说明

- 用途：
  - 作为产品的基础父类，用于规范依赖的版本
  - 供其他产品聚合本产品的部分或全部功能
- 注意事项
  - [强制]需要自行定义`<properties/>`
  - [建议]定义`<dependencyManagement/>`, 子项目可以直接沿用并可改进
  - [建议]定义`<pluginManagement/>`,但因为不会影响聚合，因此不是必须的，可以在子项目中定义;`<plugin/>`中的通用设置写在这里可以简化子项目的编写，但不是必须的，子项目中的设置项具有优先权
  - [强烈建议]所有`<dependency/>`中的`<version/>`都应该使用通过`<properties/>`定义的版本变量而不应该硬写，子项目可以按照需要重新设置版本号即可使用新版本
  - [强烈建议]不要定义`<dependencies/>`，避免造成重复引用，维护麻烦不说，还容易造成一些不可知的编译或运行错误

#### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.qzdatasoft.prod01</groupId>
    <artifactId>qzdatasoft-prod01-dependencies</artifactId>
    <version>1.0.0</version>

    <packaging>pom</packaging>
    <name>qzdatasoft-prod01-dependencies</name>
    <url>http://www.qzdatasoft.com</url>

    <properties>
        <java.version>1.8</java.version>
        <maven.compiler.source>${java.version}</maven.compiler.source>
        <maven.compiler.target>${java.version}</maven.compiler.target>
        <maven.build.timestamp.format>yyyyMMdd-HHmmss</maven.build.timestamp.format>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

        <!-- Maven plugin -->
        <maven-jar-plugin.version>3.2.2</maven-jar-plugin.version>
        <maven-dependency-plugin.version>3.5.0</maven-dependency-plugin.version>
        <maven-resources-plugin.version>3.3.0</maven-resources-plugin.version>
        <maven-source-plugin.version>3.2.0</maven-source-plugin.version>
        <maven-deploy-plugin.version>3.1.0</maven-deploy-plugin.version>

        <!-- Spring boot-->
        <spring-boot.veresion>2.3.4.RELEASE</spring-boot.veresion>
        <!-- prod01-->
        <qzdatasoft-prod01.version>${project.version}</qzdatasoft-prod01.version>

        <!-- Others -->
		<log4j.version>2.17.0</log4j.version>
        <log4jdbc.version>1.16</log4jdbc.version>
        <swagger-springfox.version>2.9.2</swagger-springfox.version>
        <swagger.version>1.5.21</swagger.version>
        
        <!-- Others more -->
    </properties>

    <dependencyManagement>
        <dependencies>

            <!-- prod01 -->
            <dependency>
                <groupId>com.qzdatasoft.prod01</groupId>
                <artifactId>qzdatasoft-prod01-business</artifactId>
                <version>${qzdatasoft-prod01.version}</version>
            </dependency>
            <dependency>
                <groupId>com.qzdatasoft.prod01</groupId>
                <artifactId>qzdatasoft-prod01-utils</artifactId>
                <version>${qzdatasoft-prod01.version}</version>
            </dependency>

            <dependency>
                <groupId>com.qzdatasoft.prod01</groupId>
                <artifactId>qzdatasoft-prod01-common</artifactId>
                <version>${qzdatasoft-prod01.version}</version>
            </dependency>

            <!-- log4j -->
            <dependency>
                <groupId>org.apache.logging.log4j</groupId>
                <artifactId>log4j-to-slf4j</artifactId>
                <version>${log4j.version}</version>
            </dependency>
            <dependency>
                <groupId>org.apache.logging.log4j</groupId>
                <artifactId>log4j-api</artifactId>
                <version>${log4j.version}</version>
            </dependency>
            <dependency>
                <groupId>org.apache.logging.log4j</groupId>
                <artifactId>log4j-core</artifactId>
                <version>${log4j.version}</version>
            </dependency>
            <dependency>
                <groupId>org.apache.logging.log4j</groupId>
                <artifactId>log4j-jul</artifactId>
                <version>${log4j.version}</version>
            </dependency>

            <!-- spring boot -->
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-parent</artifactId>
                <version>${spring-boot.veresion}</version>
                <scope>import</scope>
                <type>pom</type>
            </dependency>

            <!-- swagger -->
            <dependency>
                <groupId>io.springfox</groupId>
                <artifactId>springfox-swagger2</artifactId>
                <version>${swagger-springfox.version}</version>
                <exclusions>
                    <exclusion>
                        <artifactId>swagger-annotations</artifactId>
                        <groupId>io.swagger</groupId>
                    </exclusion>
                    <exclusion>
                        <artifactId>swagger-models</artifactId>
                        <groupId>io.swagger</groupId>
                    </exclusion>
                </exclusions>
            </dependency>
            <dependency>
                <groupId>io.springfox</groupId>
                <artifactId>springfox-swagger-ui</artifactId>
                <version>${swagger-springfox.version}</version>
            </dependency>
            <dependency>
                <groupId>io.swagger</groupId>
                <artifactId>swagger-annotations</artifactId>
                <version>${swagger.version}</version>
            </dependency>
            <dependency>
                <groupId>io.swagger</groupId>
                <artifactId>swagger-models</artifactId>
                <version>${swagger.version}</version>
            </dependency>

            <!-- Other dependencies more -->

        </dependencies>
    </dependencyManagement>

    <build>

        <pluginManagement>
            <plugins>
                
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <version>${spring-boot.veresion}</version>
                    <configuration>
                        <layers>
                            <enabled>false</enabled>
                        </layers>
                        <addResources>false</addResources>
                        <layout>ZIP</layout>
                        <includes>
                            <include>
                                <groupId>nothing</groupId>
                                <artifactId>nothing</artifactId>
                            </include>
                        </includes>
                    </configuration>
                    <executions>
                        <execution>
                            <goals>
                                <goal>repackage</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>

                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-jar-plugin</artifactId>
                    <version>${maven-jar-plugin.version}</version>
                    <configuration>
                        <archive>
                            <manifest>
                                <addClasspath>true</addClasspath>
                                <classpathPrefix>lib/</classpathPrefix>
                            </manifest>
                        </archive>
                    </configuration>
                </plugin>

				<plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-dependency-plugin.version</artifactId>
                    <version>${maven-dependency-plugin.version}</version>
                </plugin>

                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-resources-plugin</artifactId>
                    <version>${maven-resources-plugin.version}</version>
                </plugin>

                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-source-plugin</artifactId>
                    <version>${maven-source-plugin.version}</version>
                    <executions>
                        <execution>
                            <id>attach-sources</id>
                            <goals>
                                <goal>jar</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>

				<plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-deploy-plugin</artifactId>
                    <version>${maven-deploy-plugin.version}</version>
                </plugin>
                
                <!-- Others more -->
                
            </plugins>
        </pluginManagement>

    </build>

</project>
```

### xflib-prod01/xflib-prod01-parent/pom.xml

#### 说明

- 用途：
  - 产品所有其他项目的父项目，继承自`xflib-prod01/xflib-prod01-dependencies/pom.xml`
- 注意事项
  - [强烈建议]在parent项目中已经定义的版本属性要重复定义，除非需要使用不同的版本，相对于parent项目, 子项目定义的版本属性的优先级更高
  - [强烈建议]不要再定义`<dependencyManagement/>`和`<pluginManagement/>`，如果需要，应补充到prent项目中去
  - [强烈建议]不要定义`<dependencies/>`，避免造成重复引用，维护麻烦不说，还容易造成一些不可知的编译或运行错误

#### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.qzdatasoft.prod01</groupId>
        <artifactId>qzdatasoft-prod01-dependencies</artifactId>
        <version>1.0.0</version>
        <relativePath>../qzdatasoft-prod01-dependencies</relativePath>
    </parent>

    <artifactId>qzdatasoft-prod01-parent</artifactId>
    <packaging>pom</packaging>
    <name>qzdatasoft-prod01-parent</name>
    <url>http://www.qzdatasoft.com</url>

    <properties/>

</project>
```

## 编写其他子业务项目的POM

业务项目的POM中，`<dependency/>`不要指定版本号，这样就直接使用到了parent项目的`<dependency/>`指定的版本号，可以更好的保持依赖的版本一致性

## 为什么上述多项目框架结构会是优雅的？

先总结一下编写pom.xml的要点

- **POM项目被其他项目继承后，`<properties/>`、`<pluginManagement/>`和`<dependencyManagement/>`这3个段的定义通过即使多次继承仍然可以使用**

- **POM项目被其他项目聚合后，这个POM项目里面`<dependencyManagement/>`段的定义可以被新项目使用，但`<properties/>`、`<pluginManagement/>`这两个段里面定义的内容不可以被新项目使用**

- **`<dependencies>`段无论是继承还是聚合都会生效**，因此，一般不要在dependencies项目中定义`<dependencies>`，容易引起重复引用导致候选管理麻烦。

- POM被聚合后，`<properties/>`定义的版本属性段在该POM的`<dependencies>`段中的使用不受影响在，并且会自动优先使用新项目中重新设置的新的版本属性值。
- 业务项目的POM中，`<dependency/>`不要指定版本号，这样就直接使用到了parent项目的`<dependency/>`指定的版本号，可以更好的保持依赖的版本一致性

以上这几点其实就是多项目优雅框架的原因：例如新产品要升级SB，只要在新产品里面重新声明如下：

```xml
<properties>
    <!-- 新产品中SB使用性能版本-->
    <spring-boot.veresion>2.7.5.RELEASE</spring-boot.veresion>
</properties>
```

综上所述，难道不是很优雅吗？

## 解惑

问1：这个项目结构比较复杂，能不能将xflib-prod01、xflib-prod01-dependencies、xflib-prod01-parent合并？

答：不考虑给其他产品聚合POM的情况下完全可以，但为什么不直接继承`spring-boot-starter-parent`，非要多此一举呢？

问2：是不是可以将xflib-prod01-dependencies和parent合并呢？

答：简单来说，可以，而且显得更简单, 附件《B.简化版多项目优雅框架自动生成器》就是适应这种需求的！但需要考虑这样一种情况：如果你的产品由几个综合性项目组成，可能需要不同的基于dependencies的parent来规范一些更多的行为或属性，更常见的适应改变`<group/>`和`<artifact/>`或`<version/>`的要求，这时候好处就凸显出来了，例如框架项目、服务端项目、客户端项目需要通过parent项目分组隔离。有兴趣的可以去了解一下，SB本身就是这样一个综合性的项目结构。

## 附件

[A.多项目优雅框架自动生成器](cInitializer/readme.md)  [B.简化版多项目优雅框架自动生成器](sInitializer/readme.md) 

注意：

1. 生成器只是一个模板生成器，更多的还需在融会贯通原理的前提下自行按需完善。
2. 使用方法：**create-project.cmd <产品简称> <公司简称>**
3. 供其他产品聚合的POM
   - A.多项目优雅框架自动生成器：`<corp>-<project>-dependencies/pom.xml`
   - B.简化版多项目优雅框架自动生成器：`<corp>-<project>-parent/pom.xml`
