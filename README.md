# github工作流
## Introduce
自动化任务（如 CI/CD 流程），用于自动化构建、测试、部署，自动集成（CI）、自动构建、自动部署（CD） 就是让 代码变成线上应用的过程 自动化，不用每次手动操作
自动集成实现代码自动检测测试，自动构建实现代码自动的打包成镜像，交付，自动部署就是将代码通过前面的步骤打包部署到服务器成为可运行的程序


## Step

在指定目录下创建yml文件 注意编写是的缩进级别

> .github/workflows/

```yaml
name: CI Workflow

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: 检出代码
        uses: actions/checkout@v3

      - name: 设置 JDK
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: 编译项目
        run: mvn clean package

      - name: 运行单元测试
        run: mvn test

```
按道理来说job之下的一级是并行执行的，但是可以通过needs关键字指定只能够顺序
每一个yml文件代表一个工作流


## 常见问题
```
Error:  Failed to execute goal org.apache.maven.plugins:maven-compiler-plugin:3.13.0:compile (default-compile) on project githubaction-examples: Fatal error compiling: error: release version 21 not supported -> [Help 1]
Error:  
Error:  To see the full stack trace of the errors, re-run Maven with the -e switch.
Error:  Re-run Maven using the -X switch to enable full debug logging.
Error:  
Error:  For more information about the errors and possible solutions, please read the following articles:
Error:  [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoExecutionException
Error: Process completed with exit code 1.执行持续部署的时候出现
```
原因： 本地配置的java环境和workflows配置的环境不同 导致构建打包的时候出错 本地是21 但是yml文件中配置的是17




```
Run docker login ***
Error: Cannot perform an interactive login from a non TTY device
Error: Process completed with exit code 1.
```

“Cannot perform an interactive login from a non - TTY device” 表明，你正尝试在没有 TTY（电传打字机，即虚拟终端）的环境中运行 docker login 命令。这种情况通常出现在自动化脚本、持续集成 / 持续部署（CI/CD）流水线或者非交互式的 shell 会话中。docker login 命令通常期望以交互式方式与用户进行交互，提示用户输入用户名和密码，但在非 TTY 环境中无法实现这一点。

```
Error response from daemon: Get "https://crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/v2/": unauthorized: authentication required
Error: Process completed with exit code 1.

```

解决方法：

## Update

- 25-02-12
  - 初始化项目结构
- 25-02-13
  - 测试持续集成，持续交付
