// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface IMyVotingToken{
    function getPastVotes(address,uint256) external view returns(uint256);
    function grantRole(address) external;
}

/// @title Voting with delegation.
contract TokenizedBallot {
    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    IMyVotingToken public tokenContract;
    uint256 public targetBlockNumber;

    mapping(address => uint256 ) public votingPowerSpent;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor(bytes32[] memory proposalNames, address _tokenContract, uint256 _targetBlockNumber) {
        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.

        // TODO INITIALIZE VOTING POWER
        tokenContract = IMyVotingToken(_tokenContract);
        targetBlockNumber = _targetBlockNumber;
        tokenContract.grantRole(address(this));

        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }





    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal,uint256 amount) external {

        //TODO: Compute voting power
        uint numVotes = votingPower(msg.sender); 

        //TODO: Update the voting power in that ballot
        require(numVotes >= amount,"not enough votes");
        votingPowerSpent[msg.sender] += amount;
        proposals[proposal].voteCount += amount;

    }

    function votingPower(address account) public view returns (uint256 numVotes){
        numVotes = tokenContract.getPastVotes(account,targetBlockNumber) - votingPowerSpent[account];
    }

    function updateBlock() public{
        targetBlockNumber = block.number;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }
}