#!/bin/bash

# 用户信息, 格式为 "用户名:端口:密码"
users=(
    "user1:2221:password1"
    "user2:2222:password2"
    "user3:2223:password3"
)

# 遍历用户信息
for user_info in "${users[@]}"; do
    IFS=':' read -r username port password <<< "$user_info"

    # 创建并运行 Alpine 容器
    sudo docker run -d \
        --name "$username" \
        -p "$port:22" \
        alpine /bin/sh -c "\
            apk add --no-cache openssh tini && \
            adduser -D $username && \
            echo '$username:$password' | chpasswd && \
            ssh-keygen -A && \
            exec tini -- /usr/sbin/sshd -D"
done
