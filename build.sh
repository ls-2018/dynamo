while true; do
	./container/build.sh --framework vllm --target local-dev &&
		docker-save-images.sh
	#		&&
	#		./container/build.sh --framework sglang --platform linux/arm64 --target local-dev &&
	#		docker-save-images.sh &&
	#		./container/build.sh --framework trtllm --platform linux/arm64 --target local-dev &&
	#		./container/build.sh --framework vllm --platform linux/arm64 --target local-dev &&
	#		docker-save-images.sh
	date
	sleep 10
done

# std::env::var   运行时读取
# env!            编译时读取

#tokio::sync::oneshot::channel::<Result<u16>>(); 只能发送一次消息的一对通道

channel 特点 适用场景
oneshot 只发送一次 初始化结果 / 返回值
mpsc 多次发送 事件流
watch 始终保存最新值 状态广播

#[tracing::instrument(skip_all)]
