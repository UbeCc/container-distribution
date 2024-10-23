# docker stop $(docker ps -aq)
# docker rm -f $(docker ps -aq)

#!/bin/bash

declare -A users
output_file="user_credentials.txt"

CONTAINER_COUNT=80

> "$output_file"

for i in $(seq 1 ${CONTAINER_COUNT}); do
    username="user$i"
    port=$((2200 + i))
    password=$(openssl rand -base64 12)

    users[$i]="$username:$port:$password"

    if sudo docker run -d \
        --name "$username" \
        --rm \
        -p "$port:22" \
        alpine /bin/sh -c "\
            apk add --no-cache openssh tini && \
            adduser -D $username && \
            echo '$username:$password' | chpasswd && \
            ssh-keygen -A && \
            exec tini -- /usr/sbin/sshd -D"; then
        echo "Container $username created on port $port"
        # 将用户信息写入文件
        echo "$username:$port:$password" >> "$output_file"
    else
        echo "Failed to create container $username"
    fi
done

echo "Created users:"
cat "$output_file"