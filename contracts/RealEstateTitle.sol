// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstateTitle {
    
    // Structure to represent a property
    struct Property {
        uint256 id;
        string addressLine;
        string city;
        string state;
        string zipCode;
        uint256 area; // in square meters
        uint256 marketValue; // in wei
        address currentOwner;
        bool exists;
    }
    
    // Structure to represent a title transfer
    struct TitleTransfer {
        uint256 propertyId;
        address from;
        address to;
        uint256 timestamp;
        uint256 transactionValue;
    }
    
    // Contract owner
    address public owner;
    
    // Mapping of properties
    mapping(uint256 => Property) public properties;
    
    // Mapping of property transfer history
    mapping(uint256 => TitleTransfer[]) public transferHistory;
    
    // Counter for property IDs
    uint256 public propertyCount;
    
    // Events
    event PropertyRegistered(uint256 propertyId, string addressLine, address owner);
    event TitleTransferred(uint256 propertyId, address from, address to, uint256 value);
    
    // Modifiers
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
    
    /**
     * @dev Register a new property
     */
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
        
        // Record initial registration as a transfer
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
    
    /**
     * @dev Transfer property title to new owner
     */
    function transferTitle(
        uint256 _propertyId,
        address _newOwner,
        uint256 _transactionValue
    ) external propertyExists(_propertyId) onlyPropertyOwner(_propertyId) {
        require(_newOwner != address(0), "Invalid new owner address");
        require(_newOwner != msg.sender, "Cannot transfer to yourself");
        
        // Update property ownership
        address previousOwner = properties[_propertyId].currentOwner;
        properties[_propertyId].currentOwner = _newOwner;
        
        // Record the transfer
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
    
    /**
     * @dev Get property details
     */
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
    
    /**
     * @dev Get transfer history for a property
     */
    function getTransferHistory(uint256 _propertyId) 
        external 
        view 
        propertyExists(_propertyId) 
        returns (TitleTransfer[] memory) 
    {
        return transferHistory[_propertyId];
    }
    
    /**
     * @dev Get total number of properties
     */
    function getTotalProperties() external view returns (uint256) {
        return propertyCount;
    }
    
    /**
     * @dev Check if address owns any properties
     */
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

