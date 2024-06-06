// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract Vault {
    uint256 constant lockTime = 45 seconds;
    mapping(address => uint256) public balance;
    mapping(address => Deposit[]) public userDeposits;
    mapping(address => uint256) public index;

    struct Deposit{
        uint256 amount;
        uint256 depositedAt;
    }

    function deposit() public payable {
        Deposit memory _deposit = Deposit(
            msg.value,
            block.timestamp
        );

        userDeposits[msg.sender].push(_deposit);
        balance[msg.sender] = balance[msg.sender] + msg.value;
    }

    function withdrawFund(uint256 _requestedAmount) public payable {
        require(balance[msg.sender] >= _requestedAmount, "Insufficient balance.");

        uint amountAccumulated;
        uint256 length = userDeposits[msg.sender].length;
        
        for(uint256 i = index[msg.sender]; i < length; i++){
            require(block.timestamp > userDeposits[msg.sender][i].depositedAt + lockTime, "Time has not yet elapsed.");
           
            if(userDeposits[msg.sender][i].amount < _requestedAmount - amountAccumulated){
                amountAccumulated += userDeposits[msg.sender][i].amount;
                userDeposits[msg.sender][i].amount = 0;
            } else if(userDeposits[msg.sender][i].amount == _requestedAmount - amountAccumulated) {
                userDeposits[msg.sender][i].amount = 0;
                index[msg.sender] = i+1;
                break;
            } else {
                amountAccumulated += userDeposits[msg.sender][i].amount;
                userDeposits[msg.sender][i].amount = amountAccumulated - _requestedAmount;
                index[msg.sender] = i; 
                break;
            }
        }
        
        balance[msg.sender] = balance[msg.sender] - _requestedAmount;
        payable(msg.sender).transfer(_requestedAmount);   
    }

    function getNumDeposits(address _user) public view returns(uint256) {
        return userDeposits[_user].length;
    }
}