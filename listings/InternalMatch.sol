contract InternalMatch is AbstractLotteryMatch {
    
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
        require(tCommit < block.number);
        require(tReveal > block.number);
        
        alice = left.getWinner();
        bob = right.getWinner();
        require(msg.sender == alice || msg.sender == bob);
        require(commitments[msg.sender] == 0);
        
        commitments[msg.sender] = _c;
    }
    
    function reveal(uint256 _s) public {
        require(tReveal < block.number);
        require(tPlay > block.number);
        
        require(keccak256(abi.encodePacked(msg.sender, _s)) == commitments[msg.sender]);
        
        secrets[msg.sender] = _s;
    }
    
    function getWinner() public view returns (address winner) {
        require(tPlay < block.number);

        if (alice != address(0) && bob == address(0)) {
            return alice;
        } else if (alice == address(0) && bob != address(0)) {
            return bob;
        } else if (alice == address(0) && bob == address(0)) {
            return left.getWinner();
        }

        if (commitments[alice] != 0 && commitments[bob] == 0) {
            return alice;
        } else if (commitments[alice] == 0 && commitments[bob] != 0) {
            return bob;
        } else if (commitments[alice] == 0 && commitments[bob] == 0) {
            return left.getWinner();
        }

        if (secrets[alice] != 0 && secrets[bob] == 0) {
            return alice;
        } else if (secrets[alice] == 0 && secrets[bob] != 0) {
            return bob;
        } else if (secrets[alice] == 0 && secrets[bob] == 0) {
            return left.getWinner();
        }

        if ((secrets[alice] ^ secrets[bob]) % 2 == 0) {
            return alice;
        } else {
            return bob;
        }
    }
}