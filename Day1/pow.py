import hashlib
import time

def calculate_hash(nonce, nickname):
    data = nickname + str(nonce)
    return hashlib.sha256(data.encode()).hexdigest()
nickname1=input("请输入昵称:")
def find_nonce(prefix_zeros):
    nickname = nickname1  # 请将YourNickname替换为你的昵称
    nonce = 0
    start_time = time.time()
    while True:
        hash_result = calculate_hash(nonce, nickname)
        if hash_result.startswith('0' * prefix_zeros):
            end_time = time.time()
            print(f"Found hash with {prefix_zeros} leading zeros: {hash_result}")
            print(f"Found nonce {nonce}")
            print(f"Time taken: {end_time - start_time:.6f} seconds")
            break
        nonce += 1

# 寻找4个0开头的哈希值
find_nonce(4)
# 寻找5个0开头的哈希值
find_nonce(5)
