set -v
rm -rf /workspace

curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh | bash -s -- \
	--source mirrors.ustc.edu.cn \
	--protocol https \
	--use-intranet-source false \
	--install-epel true \
	--backup true \
	--upgrade-software false \
	--clean-cache false \
	--ignore-backup-tips

apt install iftop htop net-tools -y

export RUSTUP_UPDATE_ROOT='https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup'
export RUSTUP_DIST_SERVER='https://mirrors.tuna.tsinghua.edu.cn/rustup'

mkdir -p ~/.cargo
echo '
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

replace-with = aliyun

[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"

[net]
git-fetch-with-cli=true

' >~/.cargo/config.toml

apt install openssh-server -y
mkdir -p /var/run/sshd
sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config

# ssh-add -D
echo 'root:f2uKSWNzV5RhTyxpe0o1' | chpasswd
touch ~/.hushlogin
ls -al ~/.hushlogin

echo '. /dynamo/env.txt' >>/etc/profile
source /etc/profile
rustup default stable

echo "
rm -rf ~/.ssh/known_hosts
sshpass -p 'f2uKSWNzV5RhTyxpe0o1' ssh-copy-id -o StrictHostKeyChecking=no -f -p 2222 root@wcni-kind && ssh -p 2222 root@wcni-kind
"
cd /dynamo
rm -rf .idea
git config --global --add safe.directory /dynamo
cargo clean

/usr/sbin/sshd -D
