// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.1.0/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts@1.1.0/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract DeepChat is ERC20, VRFConsumerBaseV2Plus {
    uint256 public constant INITIAL_TOKENS = 15 * 10**18;
    uint256 public constant MAX_REWARD = 5 * 10**18;
    uint256 public constant CHAT_BIND_TIME = 6 hours;
    uint256 public constant WORD_THRESHOLD = 100;
    uint256 private constant ROLL_IN_PROGRESS = 42;

    struct User {
        string introduction;
        uint256 chatPrice;
        uint256 totalRewards;
        uint256 lastChatTime;
        address activeChat;
    }

    mapping(address => User) public users;
    address[] public registeredUsers;

    // map rollers to requestIds
    mapping(uint256 => address) private s_rollers;
    // map vrf results to rollers
    mapping(address => uint256) private s_results;

    address public vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 public s_keyHash =0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint256 public s_subscriptionId;
    uint32 public callbackGasLimit = 40000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    event UserRegistered(address indexed user, string introduction);
    event ChatRequested(address indexed from, address indexed to, uint256 price);
    event ChatAccepted(address indexed from, address indexed to);
    event RandomnessRequested(uint256 requestId);
    event RewardGranted(address indexed user, uint256 amount);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);


    constructor(uint256 subscriptionId) VRFConsumerBaseV2Plus(vrfCoordinator) ERC20("DeepChatToken", "DCT") {
        s_subscriptionId = subscriptionId;
    }


    function registerUser(string memory introduction) external {
        require(balanceOf(msg.sender) == 0, "User already registered");

        _mint(msg.sender, INITIAL_TOKENS);

        users[msg.sender] = User({
            introduction: introduction,
            chatPrice: 1 * 10**18,
            totalRewards: 0,
            lastChatTime: 0,
            activeChat: address(0)
        });

        registeredUsers.push(msg.sender);

        emit UserRegistered(msg.sender, introduction);
    }

    function getAllUsers() external view returns (address[] memory) {
        return registeredUsers;
    }

    function requestChat(address to) external {
        User storage recipient = users[to];
        require(balanceOf(msg.sender) >= recipient.chatPrice, "Not enough tokens");
        require(users[msg.sender].activeChat == address(0), "Already in an active chat");
        require(recipient.activeChat == address(0), "Recipient is already in an active chat");

        _transfer(msg.sender, to, recipient.chatPrice);

        recipient.chatPrice += 1 * 10**18;
        users[msg.sender].activeChat = to;
        recipient.activeChat = msg.sender;
        users[msg.sender].lastChatTime = block.timestamp;
        recipient.lastChatTime = block.timestamp;

        emit ChatRequested(msg.sender, to, recipient.chatPrice);
    }

    function endChat() external {
        User storage user = users[msg.sender];
        require(block.timestamp >= user.lastChatTime + CHAT_BIND_TIME, "Chat binding time not over");

        address partner = user.activeChat;
        user.activeChat = address(0);
        users[partner].activeChat = address(0);

        emit ChatAccepted(msg.sender, partner);
    }

   
    function rollDice(address roller) public onlyOwner returns (uint256 requestId) {
        require(s_results[roller] == 0, "Already rolled");
        // Will revert if subscription is not set and funded.
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        s_rollers[requestId] = roller;
        s_results[roller] = ROLL_IN_PROGRESS;
        emit RandomnessRequested(requestId);
    }

  
     function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 reward = (randomWords[0] % 6)* 10**18;
        s_results[s_rollers[requestId]] = reward;
        emit DiceLanded(requestId, reward);
    }

    function Reward(address player) public  {
        require(s_results[player] != 0, "Dice not rolled");
        require(s_results[player] != ROLL_IN_PROGRESS, "Roll in progress");
        _Reward(player);
    } 

    function _Reward(address Player) public  {
        address user = Player;
        address userParner = users[user].activeChat;
        uint256 reward = s_results[user];
        if (users[user].totalRewards + reward <= MAX_REWARD) {
            _mint(user, reward);
            users[user].totalRewards += reward;

            emit RewardGranted(user, reward);
        }
        if (users[userParner].totalRewards + reward <= MAX_REWARD) {
            _mint(userParner, reward);
            users[userParner].totalRewards += reward;

            emit RewardGranted(userParner, reward);
        }
    }
}
