contract FirstLevelMatch is AbstractLotteryMatch {
    address public alice;
    address public bob;
    
    mapping(address => bytes32) public commitments;
    mapping(address => uint256) public secrets;
    
    LotteryMaster public lottery;
    uint256 public index;
    
    uint256 public tCommit;
    uint256 public tReveal;
    uint256 public tPlay;
    
    function commit(bytes32 _c) public {
        require(tCommit < block.number, "Too early to commit.");
        require(tReveal > block.number, "Too late to commit.");
        
        alice = lottery.getPlayer(index * 2);
        bob = lottery.getPlayer(index * 2 + 1);
        require(msg.sender == alice || msg.sender == bob, "Wrong player for this match.");
        require(commitments[msg.sender] == 0, "Player has already commited to this match.");
        
        commitments[msg.sender] = _c;
    }
}