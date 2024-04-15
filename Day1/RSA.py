import hashlib
from Crypto.PublicKey import RSA
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256

def calculate_hash(nickname, nonce):
    return hashlib.sha256((nickname + str(nonce)).encode()).hexdigest()
nonce1=int(input("请输入nonce:"))
def find_hash(prefix, nickname):
    nonce = nonce1
    while True:
        hash_result = calculate_hash(nickname, nonce)
        if hash_result.startswith(prefix):
            
            print(f"找到符合 POW 4个开头的哈希值 '{hash_result}'")
            return nickname + str(nonce)
        nonce += 1

def generate_key_pair():
    key = RSA.generate(2048)
    
    private_key = key.export_key()
    print(f"生成私钥{private_key}")
    public_key = key.publickey().export_key()
    print(f"生成公钥{public_key}")
    return private_key, public_key

def sign_message(message, private_key):
    key = RSA.import_key(private_key)
    h = SHA256.new(message.encode())
    signature = pkcs1_15.new(key).sign(h)
    print(f"私钥签名{signature}")
    return signature

def verify_signature(message, signature, public_key):
    key = RSA.import_key(public_key)
    h = SHA256.new(message.encode())
    try:
        pkcs1_15.new(key).verify(h, signature)
        print("公钥验证签名，验证成功")
    except (ValueError, TypeError):
        print("公钥验证签名，验证失败")

nickname = input("请输入昵称：")

# 找到符合POW条件的消息
message = find_hash("0000", nickname)

# 生成公私钥对
private_key, public_key = generate_key_pair()

# 使用私钥对消息进行签名
signature = sign_message(message, private_key)

# 使用公钥验证签名
verify_signature(message, signature, public_key)
