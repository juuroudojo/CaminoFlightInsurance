// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract FlightObserver is ChainlinkClient {
    address public refundHandler;
    LinkTokenInterface private LINK;

    // FlightAware API URL and API key
    string constant private FA_API_URL = "https://flightaware.com/api/v3/flight/status/";
    string constant private FA_API_KEY = "flightaware_api_key";

    // Event to notify when a flight is delayed
    event FlightDelayed(uint256 flightId, uint256 delayTime);

    constructor(uint256 _flightId, uint256 _delayThreshold, address _refundHandler, address _link) {
        setChainlinkToken(_link);
        LINK = LinkTokenInterface(_link);
        refundHandler = _refundHandler;
    }

    // 
    function createRequest(bytes32 _flightId) external {
        // API URL
        string memory apiUrl = string(abi.encodePacked(FA_API_URL, _flightId));

        // API request
        Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32("1"), address(this), this.fulfill.selector);
        request.add("get", apiUrl);
        request.add("headers", "Authorization", FA_API_KEY);
        // NOTICE: Delay is in minutes
        request.add("path", "flightStatus.delay");
        sendChainlinkRequest(request, 1 * LINK);
    }

    // Receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId, bytes32 _flightId, uint256 _status, uint256 _delay) public recordChainlinkFulfillment(_requestId) {
        // Check if the flight is delayed so that it only calls when needed
        if (_status == 1 || _status == 2) {
            // Trigger the refund function in the RefundHandler contract
            (bool success, ) = refundHandler.call(abi.encodeWithSignature("refund(bytes32,uint256,uint256)", _flightId, _status, _delay));
            require(success, "Refund failed");
        } else if (_status == 3) {
            // Handle the case when flight successfully landed
            (bool success, ) = refundHandler.call(abi.encodeWithSignature("completeFlight(bytes32)", _flightId));
            require(success, "Refund failed");
        } else {
            revert ("Flight status not supported");
        }
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory temp = bytes(source);
        if (temp.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(temp, 32))
        }
    }
}

