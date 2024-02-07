const MicroLending = artifacts.require("MicroLending");

contract('Micro lending', (accounts) => {
    let microLeningInstance;

    const owner = accounts[0];
    const borrower = accounts[1];

    beforeEach(async () => {
        microLeningInstance = await MicroLending.new({ from: owner });

    });

    it("Should allow users to request a loan", async () => {
        const amount = Web3.utils.toWei("1", "ether");
        const interestRate = 5;
        const daysToRepay = 7;

        await microLeningInstance.requestLoan(amount, interestRate, daysToRepay, { from: borrower });

        const loan = await microLendingInstance.loans(i);

        assert.equal(loan.borrower, borrower);
        assert.equal(loan.amount.toString(), amount);
        assert.equal(loan.interestRate.toString(), interestRate());
        assert.equal(loan.dueDate > 0, true);
        assert.equal(loan.reapaid, false);
    })

    it("Should allow owner to repay a loan", async () => {
        const amount = Web3.utils.toWei("1", "ether");
        const interestRate = 5;
        const daysToRepay = 7;


        await microLeningInstance.requestLoan(amount, interestRate, daysToRepay, {from: borrower});

        const initialBalance = await Web3.eth.getBalance(owner);
        const loan = await microLendingInstance.loans(i);

        await microLeningInstance.repaidLoan(i, { value: loan.amount * (100 + loan.interestRate)/ 100 });

        const finalBalance = await Web3.eth.getBalance(owner);
        const repaidLoan = await microLendingInstance.loans(i);

        assert.equal(repaidLoan.repaid, true);
        assert.equal(finalBalance > initialBalance, true);
    })
})