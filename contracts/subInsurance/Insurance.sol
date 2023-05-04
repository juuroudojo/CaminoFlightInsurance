// SPDX-Licnse-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IObserver.sol";


contract InsuranceDealer is AccessControl {
    address public flightObserver;
    address public token;
    // address of the multisig serving as treasury
    address public multisig; 
    // min/max prices to pay for insurance
    uint256 public minAmount;
    uint256 public maxAmount;
    // fee for insurance cancellation
    uint256 public fee;
    // min time before departure to be eligible for insurance
    uint256 public subThreshold;

    event InsuranceBought (
        address indexed passenger,
        uint256 amount,
        uint256 subTier,
        uint256 indexed flightId
    );

    event InsuranceCancelled (
        address indexed passenger,
        uint256 amount,
        uint256 subTier,
        uint256 indexed flightId
    );

    struct Insurance {
        uint256 amount;
        uint256 subTier;
        uint256 flightId;
        uint256 departureTime;
        uint256 arrivalTime;
        uint256 subscriptionTime;
    }

    struct InsuranceTier {
        uint256 cancellationPayout;
        uint256 delayPayout;
        uint256 pricePct;
    }

    mapping (address => mapping(bytes32 => Insurance)) public insurances;
    mapping (uint256 => InsuranceTier) public insuranceTiers;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
    * @dev Called by user to insure a flight, choosing policy and amount
    * @param _amount amount of the insurance in 18 decimals
    * @param _subTier subscription tier
    * @param _flightId flight id
    */
    function insureFlight(uint256 _amount, uint256 _subTier, bytes32 _flightId) public {
        require(insurances[msg.sender][_flightId].subscriptionTime == 0, "Can't overwrite existing subscription!");
        require(_amount >= minAmount, "Amount too low!");
        require(insuranceTiers[_subTier].pricePct > 0, "Invalid tier!");

        _amount += _amount * insuranceTiers[_subTier].pricePct / 100;
        IERC20(token).transferFrom(msg.sender, multisig, _amount);
        (uint256 depTime, uint256 arrTime) = IObserver(flightObserver).createRequest(_flightId);

        // handles non existing flights besides late subscriptions
        require(block.timestamp + subThreshold < depTime, "Too late!");
        insurances[msg.sender][_flightId] = Insurance(_amount, _subTier, _flightId, depTime, arrTime, block.timestamp);
    }

    /**
    * @dev Cancels an insurance and pays out the amount minus the cancellation fee
    * @param _flightId flight id
    */
    function cancelInsurance(bytes32 _flightId) public {
        Insurance memory insurance = insurances[msg.sender][_flightId];
        require(insurance.subscriptionTime > 0, "No insurance found!");
        require(block.timestamp < insurance.departureTime, "Flight has already departed!");
        require(block.timestamp + subThreshold < insurance.departureTime, "Too late!");

        uint256 payout = insurance.amount - calculateFee(insurance.amount, insurance.departureTime);
        IERC20(token).transferFrom(multisig, msg.sender, payout);
        delete insurances[msg.sender][_flightId];
    }

    /**
    * @dev Calculates the cancellation fee depending on the time left until departure
    * @param _amount amount of the insurance
    * @param _departureTime departure time of the flight
    */
    function calculateFee(uint256 _amount, uint256 _departureTime) public view returns (uint256) {
        uint256 timeLeft = _departureTime - block.timestamp;
        uint256 feePct = fee * timeLeft / (subThreshold * 100);
        return _amount * feePct / 100;
    }

    /**
    * @dev Previews the amount user receives if cancelling the insurance at the current time
    * @param _flightId flight id
    */
    function previewCancellationAmount(bytes32 _flightId) public view returns (uint256) {
        Insurance memory insurance = insurances[msg.sender][_flightId];
        require(insurance.subscriptionTime > 0, "No insurance found!");
        require(block.timestamp + subThreshold < insurance.departureTime, "Too late!");

        return calculateFee(insurance.amount, insurance.departureTime) + insurance.amount;
    }

    function setInsuranceTier(uint256 _subTier, uint256 _cancellationPayout, uint256 _delayPayout) public onlyRole(DEFAULT_ADMIN_ROLE) {
        insuranceTiers[_subTier] = InsuranceTier(_cancellationPayout, _delayPayout, 0);
    }

    function setMultisig(address _multisig) public onlyRole(DEFAULT_ADMIN_ROLE) {
        multisig = _multisig;
    }

    function setToken(address _token) public onlyRole(DEFAULT_ADMIN_ROLE) {
        token = _token;
    }

    function setMinAmount(uint256 _minAmount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        minAmount = _minAmount;
    }

    function setFee(uint256 _fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        fee = _fee;
    }

    function setSubThreshold(uint256 _subThreshold) public onlyRole(DEFAULT_ADMIN_ROLE) {
        subThreshold = _subThreshold;
    }

    function setFlightObserver(address _flightObserver) public onlyRole(DEFAULT_ADMIN_ROLE) {
        flightObserver = _flightObserver;
    }
        
}