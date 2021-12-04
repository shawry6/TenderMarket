pragma solidity >=0.4.22 <0.6.0;

contract TenderAuction {

    // current state of the auction
    address payable public beneficiary;
    address public lowestBidder;
    // address public highestBidder;
    uint public lowestBid;
    // uint public highestBid;

    // allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    bool public ended;

    // events that will be emitted on changes
    event lowestBidDecreased(address bidder, uint amount);
    // event highestBidIncreased(address bidder, uint amount);
    event auctionEnded(address winner, uint amount);

    constructor(
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
    }

    function bid(address payable sender) public payable {
        require(
            // msg.value > highestBid, "There is already a higher bid."
            msg.value > lowestBid, "There is already a lower tender."
        );
        require(!ended, "auctionEND has already been called.");
        
        if (lowestBid !=0) {
        // if (highestBid !=0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
            pendingReturns[lowestBidder] -= lowestBid; 
            // pendingReturns[highestBidder] += highestBid; 
        }
        lowestBidder = sender;
        // highestBidder = sender;
        lowestBid = msg.value;
        // highestBid = msg.value;
        emit lowestBidDecreased(sender, msg.value);
        // emit highestBidIncreased(sender, msg.value);
    }
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `send` returns.
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function pendingReturn(address sender) public view returns (uint) {
        return pendingReturns[sender];
    }

    function auctionEnd() public {
        // 1. Conditions
        require(!ended, "auctionEnd has already been called.");
        require(msg.sender == beneficiary, "You are not the auction beneficiary.");

        // 2. Effects
        ended = true;
        emit auctionEnded(lowestBidder, lowestBid);
        // emit auctionEnded(highestBidder, highestBid);

        // 3. Interaction
        beneficiary.transfer(lowestBid);
        // beneficiary.transfer(highestBid);
    }
}
