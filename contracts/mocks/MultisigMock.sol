// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract MultisigMock {
    uint public numConfirmationsRequired;
    address[] public owners;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    Transaction[] public transactions;
    mapping(address => mapping (uint => bool)) public confirmations;

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length >= _numConfirmationsRequired, "number of confirmations required must be less than or equal to the number of owners");

        owners = _owners;
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    function submitTransaction(address _to, uint _value, bytes memory _data) public {
        require(isOwner(msg.sender), "only owners can submit transactions");
        uint newTxIndex = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        confirmTransaction(newTxIndex);
    }

    function confirmTransaction(uint _txIndex) public {
        require(isOwner(msg.sender), "only owners can confirm transactions");
        require(!confirmations[msg.sender][_txIndex], "transaction already confirmed");
        require(!transactions[_txIndex].executed, "transaction already executed");

        confirmations[msg.sender][_txIndex] = true;
        transactions[_txIndex].numConfirmations += 1;
    }

    function executeTransaction(uint _txIndex) public {
        require(isOwner(msg.sender), "only owners can execute transactions");
        require(transactions[_txIndex].numConfirmations >= numConfirmationsRequired, "cannot execute transaction without required confirmations");

        Transaction storage transaction = transactions[_txIndex];

        require(!transaction.executed, "transaction already executed");

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "transaction failed");

        transaction.executed = true;
    }

    function isOwner(address _address) private view returns(bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
