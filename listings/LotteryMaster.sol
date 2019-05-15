contract LotteryMaster {
    uint256 public N;
    uint256 public price;
    uint256 public tStart;
    uint256 public tFinal;
    
    mapping(address => uint256) public deposits;
    address[] public players;

    AbstractLotteryMatch public finalMatch;
    uint256 public nPlayers;
    bool public isInitialized;
    bool public isFull;
    address public owner;
    
    constructor(uint256 _N, uint256 _price, uint256 _tStart, uint256 _tFinal) public {
        require(_tStart < _tFinal, "Time limits invalid. Stop time is before start time.");
        
        N = _N;
        price = _price;
        tStart = _tStart;
        tFinal = _tFinal;

        owner = msg.sender;
    }
    
    function setFinalMatch(AbstractLotteryMatch _finalMatch) public {
        require(msg.sender == owner, "Only owner can set final match.");
        require(finalMatch == AbstractLotteryMatch(0), "Final match is already set.");
        finalMatch = _finalMatch;

        isInitialized = true;
    }
    
    function deposit() public payable {
        require(block.number < tStart, "Too late to deposit.");
        require(finalMatch != AbstractLotteryMatch(0), "Final match not set. Lottery not initialized yet.");
        require(msg.value == price, "Transaction value is not equal to ticket price.");
        require(isFull == false, "Lottery is full");
        require(deposits[msg.sender] == 0, "Player has already deposited to this lottery.");
        
        players.push(msg.sender);
        deposits[msg.sender] = msg.value;
        nPlayers++;

        if (nPlayers == N) {
            isFull = true;
        }
    }
    
    function withdraw() public {
        address lotteryWinner = finalMatch.getWinner();
        if (lotteryWinner != address(0)) {
            require(msg.sender == lotteryWinner, "Player is not winner of lottery.");
            msg.sender.transfer(address(this).balance);
        } else {
            require(block.number > tFinal, "Lottery stop time is not reached.");
            msg.sender.transfer(deposits[msg.sender]);
        }
    }
    
    function getPlayer(uint256 index) public view returns (address player) {
        player = players[index];
    }
}