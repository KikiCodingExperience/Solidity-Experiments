// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract Errors {

error NotAdmin();
error ZeroAmount();
error AddressZero();
error SameAdmin();
error SameToken();
error AlreadyStaker();
error LockTimeNotFinished();
error WrongStakedAmount();
error TransferFailed();
error NotOwner();
error SameOwner();

}
