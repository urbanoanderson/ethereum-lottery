pragma solidity ^0.4.9;

import "./utils.sol";

contract Lottery
{
    struct Ticket
    {
        address buyer;
        uint8[6] luckyLumbers;
    }
    
    uint MIN_TICKET_COST = 30000;
    uint8 MAX_LUCKY_NUMBER_VALUE = 60;
    
    address _owner;
    uint _drawDate;
    uint _ticketCost;
    bool _ended;
    Ticket[] _tickets;
    uint8[6] _drawnNumbers;
    
    event TicketBought(address buyer, uint ticketCost, uint8[6] luckyNumbers);
    event OverpayedTicket(address buyer, uint valuePayed, uint ticketCost);
    
    constructor(uint ticketCost, uint drawDate) public
    {
        require(drawDate > block.timestamp, "Draw date must be in the future");
        require(ticketCost >= MIN_TICKET_COST, 
            Utils.strConcat("Ticket cost must be of at least ", Utils.toString(MIN_TICKET_COST), " weis"));
        
        _owner = msg.sender;
        _drawDate = drawDate;
        _ticketCost = ticketCost;
        _ended = false;
        
        //TODO: randomly choose numbers
        for(uint8 i = 0; i < _drawnNumbers.length; i++)
        {
            _drawnNumbers[i] = 0; //choose random number
        }
        
        //TODO: set event to certain time and date
    }
    
    function cancelGame() public
    {
        require(msg.sender == _owner, "Only the lottery creator can cancel it");
        
        for(uint i = 0; i < _tickets.length; i++)
        {
            _tickets[i].buyer.transfer(_ticketCost);
        }
        
        selfdestruct(_owner);
    }
    
    function buyTicket(uint8[6] luckyNumbers) public payable
    {
        require(now < _drawDate, "This lottery has already ended");
        
        require(msg.sender != _owner, "Lottery owner cannot buy tickets");
        
        require(msg.value >= MIN_TICKET_COST, 
            Utils.strConcat("A Ticket costs ", Utils.toString(_ticketCost), " weis"));
            
        if(msg.value > _ticketCost)
        {
            msg.sender.transfer(msg.value - _ticketCost);
            emit OverpayedTicket(msg.sender, msg.value, _ticketCost);
        }
        
        for(uint8 i = 0; i < luckyNumbers.length; i++)
        {
            require(luckyNumbers[i] <= MAX_LUCKY_NUMBER_VALUE, 
                Utils.strConcat("Lucky numbers must be from 0 to ", Utils.toString(MAX_LUCKY_NUMBER_VALUE)));
        }
        
        _tickets.push(Ticket(msg.sender, luckyNumbers));
        emit TicketBought(msg.sender, _ticketCost, luckyNumbers);
    }
    
    function gameInfo() public view 
    returns(bool ended, uint drawDate, uint numberOfPlayers, uint prizePool)
    {
        return (
            _ended,
            _drawDate,
            _tickets.length,
            address(this).balance
        );
    }
}