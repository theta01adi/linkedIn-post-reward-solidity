// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";


contract LinkedInPostReward is Ownable2Step {
    
    mapping ( address => string ) public userToName;

    event UserRegistered(address indexed user, uint createdAt);


    constructor() Ownable(msg.sender) {

    }

    modifier isUserRegistered() {
        require(bytes(userToName[msg.sender]).length != 0,"User is not registered !!");
        _;
    }
    

    // filtering of username on python/react from the url
    function register_user(string calldata username) external {
        address user = msg.sender;
        require(user != address(0), "User address can't be zero!!");
        require(bytes(userToName[msg.sender]).length == 0,"User already registered !!");
        require(bytes(username).length != 0, "Invalid username lenght !!");

        userToName[user] = username;

        emit UserRegistered(user, block.timestamp);
    }

}