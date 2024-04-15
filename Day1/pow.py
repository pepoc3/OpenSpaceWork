import hashlib
import time

def calculate_hash(nonce):
    return hashlib.sha256((nickname + str(nonce)).encode()).hexdigest()
nonce1=int(input("请输入nonce:"))
def find_hash(prefix):
    nonce = nonce1
    start_time = time.time()
    while True:
        hash_result = calculate_hash(nonce)
        if hash_result.startswith(prefix):
            end_time = time.time()
            print(f"找到哈希值 '{hash_result}'，用时: {end_time - start_time} 秒")
            break
        nonce += 1

nickname = input("请输入昵称：")

# 找到4个0开头的哈希值
find_hash("0000")

# 找到5个0开头的哈希值
find_hash("00000")
