// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChainInventory {

    error SupplyChainInventory__OnlyOwnerCanPerformThisAction();
    error SupplyChainInventory__InvalidProductState();
    error SupplyChainInventory__InvalidProductID();
    error SupplyChainInventory__InvalidPaymentAmount();
    error SupplyChainInventory__ProductIsNotAvailable();
    error SupplyChainInventory__InvalidNewOwnerAddress();
    error SupplyChain__InsufficientQuantityForTransfer();

    address private owner;
    uint256 private productCount;

    address[] owners;

    enum SupplyChainState {
        Created,
        Paid,
        Delivered
    }

    struct Product {
        uint256 id;
        string name;
        uint256 price;
        uint256 quantity;
        address[] owners;
        bool isAvailable;
        SupplyChainState state;
    }

    mapping(uint256 productId => Product) private s_products;
    mapping(uint256 productId => address[]) private ownersOfAProduct;

    event ProductCreated(uint256 id, string name, uint256 price, uint256 quantity, address owner);
    event ProductTransferred(uint256 id, address from, address to, uint256 quantity);
    event ProductPaid(uint256 _productID);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert SupplyChainInventory__OnlyOwnerCanPerformThisAction();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProduct(string memory _name, uint256 _price, uint256 _quantity) public onlyOwner {
        productCount++;
        s_products[productCount] = Product(productCount, _name, _price, _quantity, new address[](1), true, SupplyChainState.Created);
        emit ProductCreated(productCount, _name, _price, _quantity, msg.sender);
    }

    function getPrice(uint256 _productId) external view returns(uint256) {
        if(s_products[_productId].state != SupplyChainState.Created) {
            revert SupplyChainInventory__InvalidProductState();
        }

        uint256 priceOfProduct = s_products[_productId].price;
        return priceOfProduct;
    }
    
    function getQuantity(uint256 _productId) external view returns(uint256) {
        if (s_products[_productId].state != SupplyChainState.Created) {
            revert SupplyChainInventory__InvalidProductState();
        }

        uint256 quantityLeft = s_products[_productId].quantity;
        return quantityLeft;
    }

    function quantityAvailable(uint _productId) public returns(bool) {
        if (s_products[_productId].state != SupplyChainState.Created) {
            revert SupplyChainInventory__InvalidProductState();
        }
        
        Product storage product = s_products[_productId];
        
        if (product.quantity == 0) {
            product.isAvailable = false;
        } else {
            product.isAvailable = true;
        }

        return  product.isAvailable;
    }

    function payForProduct(uint256 _productId, address _newOwner, uint256 _quantity) public payable {
        if(_productId < 0 && _productId > productCount) {
            revert SupplyChainInventory__InvalidProductID();
        }
        //require(_productId > 0 && _productId <= productCount, "Invalid product ID");
        
        Product storage product = s_products[_productId];
        if (product.quantity == 0) {
            product.isAvailable = false;
        }

        uint256 priceToPay = product.price * _quantity; 

        if (!product.isAvailable) {
            revert SupplyChainInventory__ProductIsNotAvailable();
        }
         if (_newOwner == address(0)) {
            revert SupplyChainInventory__InvalidNewOwnerAddress();
        }
         if (_quantity > product.quantity) {
            revert SupplyChain__InsufficientQuantityForTransfer();
        }
         if (msg.value < priceToPay) {
            revert SupplyChainInventory__InvalidPaymentAmount();
        }

        if (product.quantity == 0) {
            product.isAvailable = false;
        }

        payable(owner).transfer(msg.value);
        emit ProductPaid(_productId);

        addProductOwnership(_productId, _newOwner);
        transferProduct(_productId, _newOwner, _quantity);
    }

      function addProductOwnership(uint256 productId, address newOwner) internal {
        s_products[productId].owners.push(newOwner);
        ownersOfAProduct[productId].push(newOwner);
    }

    function transferProduct(uint256 _productId, address _newOwner, uint256 _quantity) public {
        Product storage product = s_products[_productId];
        product.quantity -= _quantity;

        s_products[productCount + 1] = Product(productCount + 1, product.name, product.price, _quantity, new address[](1), true, SupplyChainState.Delivered);        emit ProductTransferred(_productId, msg.sender, _newOwner, _quantity);
    }

    function getOwner() external view returns(address) {
        return owner;
    }

    function getProductCount() external view returns(uint256) {
        return productCount;
    }

    function getProduct(uint256 _productID) external view returns(uint256, string memory, uint256, uint256, address[] memory, bool) {
        return (
        s_products[_productID].id,
        s_products[_productID].name,
        s_products[_productID].price,
        s_products[_productID].quantity,
        s_products[_productID].owners,
        s_products[_productID].isAvailable
        );
    } 

    function getOwnersOfAProduct(uint256 _productId) external view returns(address [] memory) {
       return s_products[_productId].owners;
    }
}
