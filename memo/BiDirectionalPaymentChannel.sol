pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/cryptography/ECDSA.sol";

contract BiDirectionalPaymentChannel {
    using SafeMath for uint;
    using ECDSA for bytes32;

    // TODO events

    address payable[2] users;
    mapping(address => bool) public isUser;

    uint challengePeriod;
    uint challengeExpiresAt = 2 ** 256 - 1;
    uint nonce;
    mapping(address => uint) public balances;

    // NOTE: deposit from multi-sig wallet
    // TODO: griefing

    modifier checkBalances(uint[2] _balances) {
        require(
            address(this).balance >= _balances[0].add(_balances[1]),
            "balance of contract must be >= to the total balance of users"
        );
        _;
    }

    // expiresAt
    constructor(
        address payable[2] memory _users,
        uint _challengePeriod,
        uint[2] _balances
    )
        public
        payable
        checkBalances(_balances)
    {
        require(_challengePeriod > 0, "Challenge period must be > 0");

        for (uint i = 0; i < _users.length; i++) {
            address user = _users[i];

            require(!isUser[user], "User address must be unique");
            users[i] = user;
            isUser[user] = true;

            balances[user] = _balances[i]
        }

        challengePeriod = _challengePeriod;
    }

    function verify(
        bytes[2] memory _signatures,
        address _contract,
        address[2] memory _signers,
        uint[2] memory _balances,
        uint _nonce
    )
        public pure returns (bool)
    {
        for (uint i = 0; i < _signatures.length; i++) {
            /*
            NOTE: sign with address of this contract to protect
                  agains replay attack on other contracts
            */
            bool valid = _signers[i] == keccak256(
                    abi.encodePacked(_contract, _balances, _nonce)
                )
                .toEthSignedMessageHash()
                .recover(_signatures[i]);

            if (!valid) {
                return false;
            }
        }

        return true;
    }

    modifier onlyUser() {
        require(isUser[msg.sender], "Not user");
        _;
    }

    modifier checkSignatures(
        bytes[2] memory _signatures, uint[2] memory _balances, uint _nonce
    ) {
        // NOTE: need to cast payable address to address type (not necessary in 0.6)
        address[2] memory signers;
        for (uint i = 0; i < users.length; i++) {
            signers[i] = address(users[i]);
        }

        require(
            verify(_signatures, address(this), signers, _balances, _nonce),
            "Invalid signature"
        );

        _;
    }

    function challengeExit(
        uint[2] memory _balances, uint _nonce, bytes[2] memory _signatures
    )
        public
        onlyUser
        checkSignatures(_signatures, _balances, _nonce)
        checkBalances(_balances)
    {
        require(
            block.timestamp < challengeExpiresAt,
            "Expired challenge period"
        );
        require(
            _nonce > nonce,
            "Nonce must be greater than the current nonce"
        );

        nonce = _nonce;

        for (uint i = 0; i < users.length; i++) {
            balances[users[i]] = _balances[i];
        }

        challengeExpiresAt = block.timestamp.add(challengePeriod);
    }

    // TODO? exit without challenge if both users agree

    // NOTE: use withdraw to avoid DOS
    function withdraw() public onlyUser {
        require(
            block.timestamp >= challengeExpiresAt,
            "Challenge period has not expired yet"
        );

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0

        (bool sent,) = msg.sender.call.value(amount)("");
        require(sent, "Failed to send Ether");
    }
}
