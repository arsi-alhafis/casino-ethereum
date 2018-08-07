pragma solidity ^0.4.23;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(address => Player) public playerInfo;

    constructor(uint256 _minimumBet) public {
        owner = msg.sender;
        if (_minimumBet != 0) minimumBet = _minimumBet;
    }

    function() public payable {}

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner);
    }

    function bet(uint256 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender), "Player not exists.");
        require(numberSelected >= 1 && numberSelected <= 10, "Number selected out of range.");
        require(msg.value >= minimumBet, "Must not lower than minimumBet");

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;
    }

    function checkPlayerExists(address player) public view returns(bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) return true;
        }
        return false;
    }

    function generateNumberWinner() public {
        uint256 numberGenerated = block.number % 10 + 1;
        distributePrizes(numberGenerated);
    }

    function distributePrizes(uint256 numberWinner) public {
        address[100] memory winners;
        uint256 count = 0;

        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if (playerInfo[playerAddress].numberSelected == numberWinner) {
                winners[count] = playerAddress;
                count++;
            }
            delete playerInfo[playerAddress];
        }

        players.length = 0;

        uint256 winnerEtherAmount = totalBet / winners.length;

        for (uint256 i = 0; i < count; i ++) {
            if (winners[i] != address(0)) {
                winners[j].transfer(winnerEtherAmount);
            }
        }
    }
}