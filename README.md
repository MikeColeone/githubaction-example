# github工作流
## Introduce
自动化任务（如 CI/CD 流程），用于自动化构建、测试、部署，自动集成（CI）、自动构建、自动部署（CD） 就是让 代码变成线上应用的过程 自动化，不用每次手动操作
自动集成实现代码自动检测测试，自动构建实现代码自动的打包成镜像，交付，自动部署就是将代码通过前面的步骤打包部署到服务器成为可运行的程序
优势：
- 快速交付
- 自动化流程减少了手动部署时的错误
- 自动测试
- 频繁上线容易回滚 适合快速迭代 甚至镜像都不需要备份 直接回滚代码 上线即可
- 
- 

## Step

在指定目录下创建yml文件 注意编写是的缩进级别

> .github/workflows/

```yaml
name: Java CI with Maven

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven
      - name: Build with Maven
        run: mvn -B package --file pom.xml
      - name: Docker login and push
        run: |
          echo "${{ secrets.ALIYUN_PASSWORD }}" | docker login --username="${{ secrets.ALIYUN_USER }}" crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com --password-stdin
          docker build -t crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }} .
          docker push crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }}

  deploy:
    needs: [ build ]
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.10
        with:
          host: ${{ secrets.ALIYUN_HOST }}
          username: ${{ secrets.ALIYUN_USERNAME }}
          password: ${{ secrets.ALIYUN_PASSWORD_HOST }}
          script: |
            echo "${{ secrets.ALIYUN_PASSWORD }}" | docker login --username="${{ secrets.ALIYUN_USER }}" crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com --password-stdin
            docker ps --filter "ancestor=crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }}" -q | xargs -r docker stop
            docker ps --filter "ancestor=crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }}" -q | xargs -r docker rm -v
            docker images "crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }}" -q | xargs -r docker rmi -f
            docker pull crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }}
            docker run -p 8080:8080 -d crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/${{ secrets.ALIYUN_REPOSITORY }}
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
- 原因： 本地配置的java环境和workflows配置的环境不同 导致构建打包的时候出错 本地是21 但是yml文件中配置的是17
- 解决方法： 同步环境即可



```
Error: Cannot perform an interactive login from a non TTY device
```

- 原因：尝试在没有 TTY 虚拟终端的环境中运行 docker login 命令。这种情况通常出现在自动化脚本、持续集成 / 持续部署（CI/CD）流水线或者非交互式的 shell 会话中。
docker login 命令通常期望以交互式方式与用户进行交互，提示用户输入用户名和密码，但在非 TTY 环境中无法实现这一点。
- 解决方法：更换login命令 确保没有直接的login交互 >  run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

```
Error response from daemon: Get "https://crpi-hh3oln0n7v6obuy2.cn-beijing.personal.cr.aliyuncs.com/v2/": unauthorized: authentication required
Error: Process completed with exit code 1.
```
- 原因： 密钥配错了 主机密码和登录仓库的密码混淆
- 解决方法：更换密钥配置


```
Error: Unable to resolve action `appleboy/ssh-action@main`, unable to find version `main`
```

- 原因：github无法找到appleboy/ssh-action 作用是自动登录服务器 执行shell命令 刮玻璃CL/CD流程的action
- 解决方法： 返回官网查询有效版本更新workflows

```
java.lang.UnsupportedClassVersionError: org/springframework/boot/loader/launch/JarLauncher
has been compiled by a more recent version of the Java Runtime (class file version 61.0),
this version of the Java Runtime only recognizes class file versions up to 55.0
```

- 原因： deploy任务完成但是启动镜像失败 查看日志发现 构建打包时 dockerfile的基础镜像和本地pom配置的不同 导致失败
- 修改基础镜像

```
本地测试没问题 容器运行正常 同时端口暴露正常 但是服务器ip加端口和url测试响应404
```

- 排查操作：
  - 进入容器 docker exec -it <容器ID或容器名称> /bin/bash
  - 执行测试 curl -v 
  - 正常推出容器： ctrl+p+q 
  - 宿主机测试
  - 外部测试
    - 测试结果： 安全组规则中的入站规则没有允许0.0.0.0/访问8080端口 
- 解决方法: 手动通过其可
  
## Update

- 25-02-14
  - 测试部署
- 25-02-12
  - 初始化项目结构
- 25-02-13
  - 测试持续集成，持续交付


## Notes

- 直接执行docker search不能在搜索私有仓库的镜像 默认搜索位置是dockerhub