// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstateTitle {
    
    struct Property {
        uint256 id;
        string addressLine;
        string city;
        string state;
        string zipCode;
        uint256 area;
        uint256 marketValue;
        address currentOwner;
        bool exists;
    }
    
    struct TitleTransfer {
        uint256 propertyId;
        address from;
        address to;
        uint256 timestamp;
        uint256 transactionValue;
    }

    0:
    1,0x0000000000000000000000000000000000000000,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,1755828896,0,
    1,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,1755829037,120
    
    address public owner;
    
    mapping(uint256 => Property) public properties;

    mapping(uint256 => TitleTransfer[]) public transferHistory;
    
    uint256 public propertyCount;
    
    event PropertyRegistered(uint256 propertyId, string addressLine, address owner);
    event TitleTransferred(uint256 propertyId, address from, address to, uint256 value);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }
    
    modifier propertyExists(uint256 _propertyId) {
        require(properties[_propertyId].exists, "Property does not exist");
        _;
    }
    
    modifier onlyPropertyOwner(uint256 _propertyId) {
        require(properties[_propertyId].currentOwner == msg.sender, "Only property owner can perform this action");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        propertyCount = 0;
    }
    
    function registerProperty(
        string memory _addressLine,
        string memory _city,
        string memory _state,
        string memory _zipCode,
        uint256 _area,
        uint256 _marketValue
    ) external onlyOwner returns (uint256) {
        propertyCount++;
        
        properties[propertyCount] = Property({
            id: propertyCount,
            addressLine: _addressLine,
            city: _city,
            state: _state,
            zipCode: _zipCode,
            area: _area,
            marketValue: _marketValue,
            currentOwner: msg.sender,
            exists: true
        });

        TitleTransfer memory initialTransfer = TitleTransfer({
            propertyId: propertyCount,
            from: address(0), // No previous owner
            to: msg.sender,
            timestamp: block.timestamp,
            transactionValue: 0
        });
        
        transferHistory[propertyCount].push(initialTransfer);
        
        emit PropertyRegistered(propertyCount, _addressLine, msg.sender);
        
        return propertyCount;
    }

    function transferTitle(
        uint256 _propertyId,
        address _newOwner,
        uint256 _transactionValue
    ) external propertyExists(_propertyId) onlyPropertyOwner(_propertyId) {
        require(_newOwner != address(0), "Invalid new owner address");
        require(_newOwner != msg.sender, "Cannot transfer to yourself");
        
        address previousOwner = properties[_propertyId].currentOwner;
        properties[_propertyId].currentOwner = _newOwner;
        
        TitleTransfer memory transfer = TitleTransfer({
            propertyId: _propertyId,
            from: previousOwner,
            to: _newOwner,
            timestamp: block.timestamp,
            transactionValue: _transactionValue
        });
        
        transferHistory[_propertyId].push(transfer);
        
        emit TitleTransferred(_propertyId, previousOwner, _newOwner, _transactionValue);
    }

    function getProperty(uint256 _propertyId) 
        external 
        view 
        propertyExists(_propertyId) 
        returns (
            uint256 id,
            string memory addressLine,
            string memory city,
            string memory state,
            string memory zipCode,
            uint256 area,
            uint256 marketValue,
            address currentOwner
        ) 
    {
        Property memory property = properties[_propertyId];
        return (
            property.id,
            property.addressLine,
            property.city,
            property.state,
            property.zipCode,
            property.area,
            property.marketValue,
            property.currentOwner
        );
    }

    function getTransferHistory(uint256 _propertyId) 
        external 
        view 
        propertyExists(_propertyId) 
        returns (TitleTransfer[] memory) 
    {
        return transferHistory[_propertyId];
    }
    
    function getTotalProperties() external view returns (uint256) {
        return propertyCount;
    }
    
    function getOwnedProperties(address _owner) external view returns (uint256[] memory) {
        uint256[] memory ownedProperties = new uint256[](propertyCount);
        uint256 count = 0;
        
        for (uint256 i = 1; i <= propertyCount; i++) {
            if (properties[i].exists && properties[i].currentOwner == _owner) {
                ownedProperties[count] = i;
                count++;
            }
        }
        
        // Resize array to actual count
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = ownedProperties[i];
        }
        
        return result;
    }
}

