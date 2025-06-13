// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LinkedInPostReward is Ownable2Step , ReentrancyGuard {

    address[] private submitters;

    struct Submission {
        address submitter;
        string cid;
    }

    address public winner;

    uint256 immutable POST_SUBMIT_REWARD = 0.001 ether;
    uint256 immutable POST_CONTENT_REWARD = 0.1 ether;

    mapping(address => string) public userToName;
    mapping(address => Submission) private postCid;

    event UserRegistered(address indexed user, uint256 createdAt);
    event PostCidSubmitted(address indexed submitter, string postCid);
    event UserRewarded(
        address indexed user,
        uint256 rewardAmount,
        string rewardFor
    );
    event WinnerAnnounced(address indexed winner);

    constructor() Ownable(msg.sender) {}

    modifier isRegistered(address user) {
        require(
            bytes(userToName[user]).length != 0,
            "User not registered !!"
        );
        _;
    }

    function isPostSubmitted(address user) public view returns (bool) {
        return bytes(postCid[user].cid).length > 0;
    }

    function isUserRegistered() external view returns (bool) {
        return bytes(userToName[msg.sender]).length != 0;
    }

    // filtering of username on python/react from the url
    function register_user(address user, string calldata username)
        external
        onlyOwner
    {
        require(user != address(0), "User address can't be zero!!");
        require(
            bytes(userToName[user]).length == 0,
            "User already registered !!"
        );
        require(bytes(username).length != 0, "Invalid username length !!");

        userToName[user] = username;
        emit UserRegistered(user, block.timestamp);
    }

    function submit_cid(address user, string calldata _postCid)
        external
        isRegistered(user)
        nonReentrant
    {
        address submitter = user;
        require(submitter == _msgSender() || owner() == _msgSender(), "Not authorized !!");
        require(
            bytes(postCid[submitter].cid).length == 0,
            "You have already submitted the post !!"
        );
        require(bytes(_postCid).length != 0, "Cid length can't be zero !!");

        postCid[submitter].cid = _postCid;
        postCid[submitter].submitter = submitter;
        submitters.push(submitter);

        emit PostCidSubmitted(submitter, _postCid);

        _rewardUser(user, POST_SUBMIT_REWARD);
        emit UserRewarded(user, POST_SUBMIT_REWARD, "Post submit reward.");
    }

    function announce_winner(address _winnerAddress) external onlyOwner isRegistered(_winnerAddress) {
        require(winner == address(0), "Winner already announced !!");
        require(isPostSubmitted(_winnerAddress), "Winner not submitted cid !!");
        require(_winnerAddress != address(0), "Invalid winner address !!");

        winner = _winnerAddress;

        emit WinnerAnnounced(_winnerAddress);

        _rewardUser(_winnerAddress, POST_CONTENT_REWARD);

        emit UserRewarded(_winnerAddress, POST_CONTENT_REWARD, "Winner Reward for best content!!");
    }

    function _rewardUser(address user, uint256 rewardAmount) internal {
        require(
            address(this).balance >= rewardAmount,
            "Insufficient contract balance !!"
        );

        (bool success, ) = payable(user).call{value: rewardAmount}("");

        require(success, "Reward amount transfer failed !!");
    }

    function getPostCid(address user)
        external
        view
        isRegistered(user)
        returns (string memory cid)
    {
        address caller = msg.sender;
        require(caller == user || caller == owner(), "Not authorized !!");
        require(
            bytes(postCid[user].cid).length != 0,
            "You don't have submitted the cid !!"
        );

        return postCid[user].cid;
    }

    function getSubmittedCids()
        external
        view
        onlyOwner
        returns (Submission[] memory submits)
    {
        submits = new Submission[](submitters.length);
        for (uint256 i = 0; i < submitters.length; i++) {
            submits[i] = postCid[submitters[i]];
        }

        return submits;
    }

    function getSubmittersCount() external view returns(uint256 submittersCount){
        return submitters.length;
    }

    receive() external payable {
    }
}
