pragma solidity ^0.7.0;

contract Decisions {
    
    struct Shareholder {
        bool allowedToVote;
        bool allowedToSeeResult;
        mapping(uint => uint) votePerQuestion;
    }

    struct Question {
        string description;
        uint trueCount;
        uint falseCount;
        bool closed;
    }

    address public director;

    mapping(address => Shareholder) public shareholders;

    Question[] public questions;
    
    uint public numOfQuestions;

    constructor() {
        director = msg.sender;
        shareholders[director].allowedToVote = true;
        shareholders[director].allowedToSeeResult = true;

        numOfQuestions = 0;
    }

    function uploadQuestion(string memory questionDescription) public {
        require(
            msg.sender == director,
            "Only Director can add questions."
        );

        questions.push(Question({
            description: questionDescription,
            trueCount: 0,
            falseCount: 0,
            closed: false
        }));

        numOfQuestions++;
    }

    function vote(uint question, bool answer) public {
        require(question < numOfQuestions,"Invalid question.");
        require(!questions[question].closed, "Question is closed for voting.");

        Shareholder storage voter = shareholders[msg.sender];
        
        require(voter.allowedToVote, "This shareholder is not allowed to vote.");
        require(voter.votePerQuestion[question] == 0, "This shareholder already voted for the specific question.");

        if (answer) {
            questions[question].trueCount += 1;
            voter.votePerQuestion[question] = 1;
        } else {
            questions[question].falseCount += 1;
            voter.votePerQuestion[question] = 2;
        }
    }

    function changeVotePermission(bool abilityToVote, address shareholder) public {
        require(
            msg.sender == director,
            "Only Director can change permissions to vote."
        );
        shareholders[shareholder].allowedToVote = abilityToVote;
    }

    function changeSeePermission(bool abilityToSee, address shareholder) public {
        require(
            msg.sender == director,
            "Only Director can change permissions to see results."
        );
        shareholders[shareholder].allowedToSeeResult = abilityToSee;
    }

    function closeVotingProcess(uint question) public {
        require(
            msg.sender == director,
            "Only Director can close the voting process."
        );

        require(question < numOfQuestions, "Invalid question.");
        require(!questions[question].closed, "Question is already closed for voting.");

        questions[question].closed = true;
    }

    function results(uint question) public view returns (string memory winningAnswer_, uint winningVoteCount_) {
        require(
            shareholders[msg.sender].allowedToSeeResult,
            "This shareholder is not allowed to see the result"
        );

        require(question < numOfQuestions, "Invalid question.");
        require(questions[question].closed, "Question is still open for voting.");

        if (questions[question].trueCount > questions[question].falseCount) {
            winningVoteCount_ = questions[question].trueCount;
            winningAnswer_ = "approved";
        }

        if (questions[question].trueCount < questions[question].falseCount) {
            winningVoteCount_ = questions[question].falseCount;
            winningAnswer_ = "rejected";
        }

        if (questions[question].trueCount == questions[question].falseCount) {
            winningVoteCount_ = 0;
            winningAnswer_ = "neutral";
        }
    }
}
