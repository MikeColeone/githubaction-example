FROM openjdk:21

# 将当前项目 target 目录下的所有 JAR 文件复制到镜像中的 /home 目录下，并命名为 githubaction.jar
COPY ./target/*.jar /home/githubaction.jar

# 设置容器启动时执行的命令，即运行指定的 JAR 文件
ENTRYPOINT ["java", "-jar", "/home/githubaction.jar"]