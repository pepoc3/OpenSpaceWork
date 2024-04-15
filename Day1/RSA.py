import hashlib
import time
import os
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP
from Crypto.Signature import PKCS1_v1_5
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA


def calculate_hash(nonce, nickname):
    data = nickname + str(nonce)
    return hashlib.sha256(data.encode()).hexdigest()
nickname1=input("请输入昵称:")
def find_nonce(prefix_zeros):
    nickname = nickname1  
    nonce = 0
    start_time = time.time()
    while True:
        hash_result = calculate_hash(nonce, nickname)
        if hash_result.startswith('0' * prefix_zeros):
            end_time = time.time()
            print(f"Found hash with {prefix_zeros} leading zeros: {hash_result}")
            print(f"Hash内容 {nickname + str(nonce)}")
            return (nickname + str(nonce))
            print(f"Time taken: {end_time - start_time:.6f} seconds")
            break
        nonce += 1

# 寻找4个0开头的哈希值
message= find_nonce(4)

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048,
    backend=default_backend()
)
public_key = private_key.public_key()

# 将密钥对序列化为PEM格式
private_key_pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption()
)
public_key_pem = public_key.public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
)

# 打印密钥对
print("私钥:")
print(private_key_pem.decode())
print("\n公钥:")
print(public_key_pem.decode())

# 对消息进行哈希
digest = SHA256.new()
digest.update(message.encode())

# 加载PEM格式的私钥
private_key_obj = RSA.import_key(private_key_pem)

# 使用私钥进行签名
signer = PKCS1_v1_5.new(private_key_obj)
signature = signer.sign(digest)
print("Signature:", signature.hex())
# 使用公钥进行验签
public_key_obj = RSA.import_key(public_key_pem)

verifier = PKCS1_v1_5.new(public_key_obj)
verified = verifier.verify(digest, signature)

if verified:
    print("公钥验签成功.")
else:
    print("公钥验签失败.")
