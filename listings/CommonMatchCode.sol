function reveal(uint256 _s) public {
    require(tReveal < block.number, "Too early to reveal.");
    require(tPlay > block.number, "Too late to reveal.");
    
    require(keccak256(abi.encodePacked(msg.sender, _s)) == commitments[msg.sender], "Secret not preimage of commitment.");
    
    secrets[msg.sender] = _s;
}

function getWinner() public view returns (address winner) {
    require(tPlay < block.number, "Too early to decide winner.");

    if (alice != address(0) && bob == address(0)) {
        return alice;
    } else if (alice == address(0) && bob != address(0)) {
        return bob;
    } else if (alice == address(0) && bob == address(0)) {
        return address(0);
    }
    
    if (commitments[alice] != 0 && commitments[bob] == 0) {
        return alice;
    } else if (commitments[alice] == 0 && commitments[bob] != 0) {
        return bob;
    } else if (commitments[alice] == 0 && commitments[bob] == 0) {
        return address(0);
    }

    if (secrets[alice] != 0 && secrets[bob] == 0) {
        return alice;
    } else if (secrets[alice] == 0 && secrets[bob] != 0) {
        return bob;
    } else if (secrets[alice] == 0 && secrets[bob] == 0) {
        return address(0);
    }
    
    if ((secrets[alice] ^ secrets[bob]) % 2 == 0) {
        return alice;
    } else {
        return bob;
    }
}