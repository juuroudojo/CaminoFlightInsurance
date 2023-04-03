// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract FlightObserver is ChainlinkClient {
    uint256 public flightId;
    uint256 public delayThreshold;
    address public ticketManager;
    LinkTokenInterface private LINK;

    // FlightAware API URL and API key
    string constant private FA_API_URL = "https://flightaware.com/api/v3/flight/status/";
    string constant private FA_API_KEY = "flightaware_api_key";

    // Event to notify when a flight is delayed
    event FlightDelayed(uint256 flightId, uint256 delayTime);

    constructor(uint256 _flightId, uint256 _delayThreshold, address _ticketManager, address _link) {
        setChainlinkToken(_link);
        flightId = _flightId;
        delayThreshold = _delayThreshold;
        ticketManager = _ticketManager;
        LINK = LinkTokenInterface(_link);
    }

    // // Function to check for delayed flights
    // function checkFlightStatus() external {
    //     // API URL
    //     string memory apiUrl = string(abi.encodePacked(FA_API_URL, flightId));

    //     // API request
    //     Chainlink.Request memory request = buildChainlinkRequest(stringToBytes32("1"), address(this), this.fulfill.selector);
    //     request.add("get", apiUrl);
    //     request.add("headers", "Authorization", FA_API_KEY);
    //     // NOTICE: Delay is in minutes
    //     request.add("path", "flightStatus.delay");
    //     sendChainlinkRequest(request, 1 * LINK);
    // }

    // Receive the response from the Chainlink oracle
    function fulfill(bytes32 _requestId, uint256 _delay) public recordChainlinkFulfillment(_requestId) {
        // Check if the flight is delayed so that it only calls when needed
        if (_delay > delayThreshold) {
            // Trigger the refund function in the RefundHandler contract
            (bool success, ) = ticketManager.call(abi.encodeWithSignature("handleDelay(uint256)", flightId));
            require(success, "Refund failed");
            // clearRefundInfo(_flightId);
            
            emit FlightDelayed(flightId, _delay);
        }
    }

    // function clearRefundInfo(uint256 _flightId) private {
        // TODO
    // }

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

