contract InternalMatch is AbstractLotteryMatch{
    address public alice;
    address public bob;
    
    mapping(address => bytes32) public commitments;
    mapping(address => uint256) public secrets;
    
    AbstractLotteryMatch public left;
    AbstractLotteryMatch public right;
    
    uint256 public tCommit;
    uint256 public tReveal;
    uint256 public tPlay;
    
    function commit(bytes32 _c) public {
        require(tCommit < block.number, "Too early to commit.");
        require(tReveal > block.number, "Too late to commit.");
        
        alice = left.getWinner();
        bob = right.getWinner();
        require(msg.sender == alice || msg.sender == bob, "Wrong player for this match.");
        require(commitments[msg.sender] == 0, "Player has already commited to this match.");
        
        commitments[msg.sender] = _c;
    }
}