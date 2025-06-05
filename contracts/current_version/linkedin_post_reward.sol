// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";


contract LinkedInPostReward is Ownable2Step {

    // error NotRegistered();

    address[] private submitters;

    struct Submission {
        address submitter;
        string cid;
    }
    
    mapping (address => string) public userToName;
    mapping (address => Submission) private postCid;

    event UserRegistered(address indexed user, uint createdAt);
    event PostCidSubmitted(address indexed submitter, string postCid);

    constructor() Ownable(msg.sender) {

    }

    modifier isRegistered(address user) {
        require(bytes(userToName[user]).length != 0,"You are not registered !!");
        _;
    }

    function isPostSubmitted(address user) public view returns (bool) {
    return bytes(userToName[user]).length > 0;
    }

    function isUserRegistered() external view returns(bool) {
        return bytes(userToName[msg.sender]).length == 0;
    } 

    // filtering of username on python/react from the url
    function register_user(address user, string calldata username) external onlyOwner {
        require(user != address(0), "User address can't be zero!!");
        require(bytes(userToName[user]).length == 0,"User already registered !!");
        require(bytes(username).length != 0, "Invalid username lenght !!");

        userToName[user] = username;

        emit UserRegistered(user, block.timestamp);
    }

    function submit_cid(address user, string calldata _postCid) external isRegistered(msg.sender) {
        address submitter = user;
        require( bytes(postCid[submitter].cid).length == 0, "You have already submitted the post !!");
        require( bytes(_postCid).length != 0, "Cid length can't be zero !!" );

        postCid[submitter].cid = _postCid;
        postCid[submitter].submitter = submitter;
        submitters.push(submitter);
        
        emit PostCidSubmitted( submitter ,_postCid);
    }

    function getPostCid(address user) external isRegistered(user) view returns( string memory cid){
        address caller = msg.sender;
        require( caller == user || caller == owner(),"Not authorized !!");
        require( bytes(postCid[user].cid).length != 0, "You don't have submitted the cid !!");

        return postCid[user].cid;
    }

    function getSubmittedCids() external view onlyOwner returns(Submission[] memory submits){
        submits = new Submission[](submitters.length);  
        for (uint i=0; i<submitters.length; i++) 
        {
            submits[i] =  postCid[submitters[i]] ;
        }

        return submits;
    }

}