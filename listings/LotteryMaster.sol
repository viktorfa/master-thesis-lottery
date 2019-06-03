contract LotteryMaster {
    
    address[] public players;
    mapping(address => uint256) public deposits;
    AbstractLotteryMatch public finalMatch;
    uint256 public nPlayers;
    
    address public owner;
    uint256 public price;
    uint256 public N;
    uint256 public tStart;
    
    bool public isInitialized;
    bool public isFull;

    function setFinalMatch(AbstractLotteryMatch _finalMatch) public {
        require(msg.sender == owner);
        require(finalMatch == AbstractLotteryMatch(0));
        finalMatch = _finalMatch;

        isInitialized = true;
    }
    
    function deposit() public payable {
        require(block.number < tStart);
        require(isInitialized == true);
        require(msg.value == price);
        require(isFull == false);
        require(deposits[msg.sender] == 0);
        
        players.push(msg.sender);
        deposits[msg.sender] = msg.value;
        nPlayers++;

        if (nPlayers == N) {
            isFull = true;
        }
    }
    
    function withdraw() public {
        if (block.number >= tStart && !isFull) {
            msg.sender.transfer(deposits[msg.sender]);
        } else {
            address lotteryWinner = finalMatch.getWinner();
            require(msg.sender == lotteryWinner);
            msg.sender.transfer(address(this).balance);
        }
    }
    
    function getPlayer(uint256 index) public view returns (address player) {
        player = players[index];
    }
}