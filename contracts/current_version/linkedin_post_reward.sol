// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";


contract LinkedInPostReward is Ownable2Step {

    address[] private submitters;

    struct Submission {
        address submitter;
        string cid;
    }
    
    mapping ( address => string ) public userToName;
    mapping ( address => Submission ) private postCid;

    event UserRegistered(address indexed user, uint createdAt);
    event PostCidSubmitted( address indexed submitter, string postCid );


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

    function submit_cid (string calldata _postCid) external isRegistered(msg.sender) {
        address submitter = msg.sender;
        require( bytes(postCid[submitter].cid).length == 0, "You have already submitted the cid !!");
        require( bytes(_postCid).length != 0, "Cid length can't be zero !!" );

        postCid[submitter].cid = _postCid;
        postCid[submitter].submitter = submitter;
        submitters.push(submitter);
        
        emit PostCidSubmitted( submitter ,_postCid);
    }

}