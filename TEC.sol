pragma solidity ^0.4.13;

contract ERC20Interface {
    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
contract Techcoin is ERC20Interface {
    
    string public constant name = 'Techcoin';
    string public constant symbol = 'TEC';
    
    uint256 public rate;
    uint256 public total;
    address public owner;
    
    mapping ( address => uint256 ) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    
    event OwnerUpdate(address indexed oldOwner, address indexed newOwner);
    event RateUpdate(uint256 oldRate, uint256 newRate);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Burn(address _from, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Sell(address indexed _from, uint256 _value, uint256 _rate);
    event Buy(address indexed _from, uint256 _value, uint256 _rate);
    
    function Techcoin(uint256 _initial, uint256 _rate) {
        owner = msg.sender;
        rate = _rate;
        balances[msg.sender] = _initial;
        total = _initial;
    }
    
    function configOwner(address _owner) returns (bool success) {
        if(msg.sender != owner) revert();
        if(_owner == 0x0) revert();
        var oldOwner = owner;
        var ownerBalance = balances[oldOwner];
        balances[oldOwner] -= ownerBalance;
        balances[_owner] += ownerBalance;
        owner = _owner;
        OwnerUpdate(oldOwner, _owner);
        
        return true;
    }
    
    function configRate(uint256 _rate) returns (bool success) {
        if(msg.sender != owner) revert();
        var oldRate = rate;
        rate = _rate;
        RateUpdate(oldRate, _rate);
        
        return true;
    }
    
    function mint(address _to, uint256 _value) returns (bool success) {
        if(msg.sender != owner) revert();
        if(_to == 0x0) revert();
        balances[_to] += _value;
        total += _value;
        
        return true;
    }
    
    function totalSupply() constant returns (uint256 supply) {
        return total;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if(_to == 0x0) revert();
        if(balances[msg.sender] < _value) revert();
        if(balances[_to] + _value < balances[_to]) revert();
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if(_to == 0x0) revert();
        if(balances[_from] < _value) revert();
        if(balances[_to] + _value < balances[_to]) revert();
        if(allowed[_from][msg.sender] < _value) revert();
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }
    
    function burn(uint256 _value) returns (bool success) {
        if(balances[msg.sender] < _value) revert();
        balances[msg.sender] -= _value;
        total -= _value;
        Burn(msg.sender, _value);
        
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) returns (bool success) {
        if(balances[_from] < _value) revert();
        if(allowed[_from][msg.sender] < _value) revert();
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        total -= _value;
        Burn(_from, _value);
        
        return true;
    }
    
    function sell() returns (bool success) {
        if(rate == 0) revert();
        uint256 numberTokens = balances[msg.sender];
        uint256 valueWei = numberTokens * rate;
        if(valueWei == 0) revert();
        
        balances[msg.sender] -= numberTokens;
        total -= numberTokens;
        msg.sender.transfer(valueWei * 1 wei);
        Sell(msg.sender, valueWei , rate);
        
        return true;
    }
    
    function () payable {
        if(rate == 0) revert();
        if(msg.value == 0) revert();
        
        uint256 numberTokens = msg.value / rate;
        if(numberTokens == 0) revert();
        
        balances[msg.sender] += numberTokens;
        total += numberTokens;
        Buy(msg.sender, numberTokens, rate);
    }
}
