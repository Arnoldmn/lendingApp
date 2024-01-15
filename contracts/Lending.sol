// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MicrolendingSystem {
    address public owner;
    uint256 public interestRate;

    struct Loan {
        address borrower;
        uint256 amount;
        uint256 interest;
        uint256 dueDate;
        bool repaid;
    }

    mapping(address => uint256) public balances;
    Loan[] public loans;

    event LoanRequested(address indexed borrower, uint256 amount, uint256 interest, uint256 dueDate);
    event LoanRepaid(address indexed borrower, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(uint256 _interestRate) {
        owner = msg.sender;
        interestRate = _interestRate;
    }

    function lend(address _borrower, uint256 _amount, uint256 _durationInDays) external payable {
        require(msg.value == _amount, "Amount sent must be equal to the loan amount");

        uint256 interest = (_amount * interestRate * _durationInDays) / (365 days);
        uint256 totalRepayment = _amount + interest;

        loans.push(Loan({
            borrower: _borrower,
            amount: _amount,
            interest: interest,
            dueDate: block.timestamp + (_durationInDays * 1 days),
            repaid: false
        }));

        balances[msg.sender] += totalRepayment;
        
        emit LoanRequested(_borrower, _amount, interest, block.timestamp + (_durationInDays * 1 days));
    }

    function repayLoan(uint256 _loanIndex) external payable {
        Loan storage loan = loans[_loanIndex];
        require(loan.borrower == msg.sender, "You are not the borrower of this loan");
        require(!loan.repaid, "Loan has already been repaid");
        require(msg.value == loan.amount + loan.interest, "Incorrect repayment amount");

        loan.repaid = true;
        balances[msg.sender] -= loan.amount + loan.interest;

        emit LoanRepaid(msg.sender, loan.amount);
    }

    function withdraw() external onlyOwner {
        require(balances[msg.sender] > 0, "No balance to withdraw");
        
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        
        payable(msg.sender).transfer(amountToWithdraw);
    }

    function getLoanCount() external view returns (uint256) {
        return loans.length;
    }

    function getLoanDetails(uint256 _loanIndex) external view returns (address, uint256, uint256, uint256, bool) {
        Loan storage loan = loans[_loanIndex];
        return (loan.borrower, loan.amount, loan.interest, loan.dueDate, loan.repaid);
    }
}
