pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
import "./project3_TenderAuction.sol";

contract TenderMarket is ERC721Full, Ownable {

    constructor() ERC721Full("TenderMarket", "TEND") public {}

    using Counters for Counters.Counter;

    Counters.Counter token_ids;

    address payable foundation_address = msg.sender;

    mapping(uint => TenderAuction) public auctions;

    modifier landRegistered(uint token_id) {
        require(_exists(token_id), "Tender not registered!");
        _;
    }

    function registerLand(string memory uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(foundation_address, token_id);
        _setTokenURI(token_id, uri);
        createAuction(token_id);
    }

    function createAuction(uint token_id) public onlyOwner {
        auctions[token_id] = new TenderAuction(foundation_address);
    }

    function endAuction(uint token_id) public onlyOwner landRegistered(token_id) {
        TenderAuction auction = auctions[token_id];
        auction.auctionEnd();
        // safeTransferFrom(owner(), auction.highestBidder(), token_id);
        safeTransferFrom(owner(), auction.lowestBidder(), token_id);
    }

    function auctionEnded(uint token_id) public view returns(bool) {
        TenderAuction auction = auctions[token_id];
        return auction.ended();
    }
    function lowestBid(uint token_id) public view landRegistered(token_id) returns(uint) {
    // function highestBid(uint token_id) public view landRegistered(token_id) returns(uint) {
        TenderAuction auction = auctions[token_id];
        return auction.lowestBid();
        // return auction.highestBid();
    }

    function pendingReturn(uint token_id, address sender) public view landRegistered(token_id) returns(uint) {
        TenderAuction auction = auctions[token_id];
        return auction.pendingReturn(sender);
    }

    function bid(uint token_id) public payable landRegistered(token_id) {
        TenderAuction auction = auctions[token_id];
        auction.bid.value(msg.value)(msg.sender);
    }

}
