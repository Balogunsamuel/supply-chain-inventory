// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SupplyChainInventory} from "../src/SupplyChainInventory.sol";
import {DeploySupplyChainInventory} from "../script/DeploySupplyChainInventory.s.sol";

error SupplyChainInventory__OnlyOwnerCanPerformThisAction();
error SupplyChainInventory__InvalidProductState();
error SupplyChainInventory__InvalidProductID();
error SupplyChainInventory__InvalidPaymentAmount();
error SupplyChainInventory__ProductIsNotAvailable();
error SupplyChainInventory__InvalidNewOwnerAddress();
error SupplyChain__InsufficientQuantityForTransfer();

contract supplyChainInventoryTest is Test {
    SupplyChainInventory supplyChainInventory;

    address public USER = makeAddr("user");

    function setUp() public {
        DeploySupplyChainInventory deployer = new DeploySupplyChainInventory();
        supplyChainInventory = deployer.run();
    }

    modifier createAccount() {
        vm.startPrank(msg.sender);
        supplyChainInventory.createProduct("Test Product", 100, 10);
        vm.stopPrank();
        _;
    }

    function testToSeeTheOwner() public {
        assertEq(supplyChainInventory.getOwner(), msg.sender);
    }

    function testCreateProduct() public {
        vm.startPrank(msg.sender);
        supplyChainInventory.createProduct("Test Product", 100, 10);

         (
            uint256 id,
            string memory name,
            uint256 price,
            ,
            ,
            bool isAvailable
        ) = supplyChainInventory.getProduct(1);

        assertEq(id, 1);
        assertEq(keccak256(abi.encodePacked(name)) , keccak256(abi.encodePacked("Test Product")));
        assert(price == 100);
        assert(isAvailable == true);
        vm.stopPrank();
    }

     function testPayForProduct() public {
        vm.startPrank(msg.sender);
        supplyChainInventory.createProduct("Test Product", 100, 10);
        vm.stopPrank();
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 5);
        console2.log(address(this));
         (, , , uint256 quantity, , ) = supplyChainInventory.getProduct(1);

        assert(quantity == 5);
    }

    function testFail_PayForProductInvalidProductID() public {
        vm.expectRevert(SupplyChainInventory__InvalidProductID.selector);
        supplyChainInventory.payForProduct{value: 1000}(2, address(this), 5);
    }

    function testFail_PayForProductInsufficientPayment() public  createAccount {
        //supplyChainInventory.createProduct("Test Product", 100, 10);
        vm.expectRevert(SupplyChainInventory__InvalidPaymentAmount.selector);
        supplyChainInventory.payForProduct{value: 500}(1, address(this), 5);
    }

    function testTransferProduct() public {
        vm.startPrank(msg.sender);
        supplyChainInventory.createProduct("Test Product", 100, 10);
        vm.stopPrank();
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 5);

        supplyChainInventory.transferProduct(1, address(0), 3);

        (, , , uint256 quantity, , ) = supplyChainInventory.getProduct(1);

        assert(quantity == 2);
    }

    function testFail_TransferProductInsufficientQuantity() public createAccount {
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 5);
        vm.expectRevert(SupplyChain__InsufficientQuantityForTransfer.selector);
        supplyChainInventory.transferProduct(1, address(0), 6);
    }

     function testGetOwnersOfAProduct() public createAccount {
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 5);

        address[] memory owners = supplyChainInventory.getOwnersOfAProduct(1);

        assert(owners.length == 2);
        assert(owners[0] == 0x0000000000000000000000000000000000000000);
    }

     function testOnlyOwnerCanCreateProduct() public {
        // Try to create a product as a non-owner.
        vm.expectRevert(SupplyChainInventory__OnlyOwnerCanPerformThisAction.selector);
        supplyChainInventory.createProduct("Test Product", 100, 10);
    }
    
      function testGetPrice() public createAccount {
        uint256 price = supplyChainInventory.getPrice(1);
        assert(price == 100);
    }

    function testGetQuantity() public {
        vm.startPrank(msg.sender);
        supplyChainInventory.createProduct("Test Product", 100, 10);
        vm.stopPrank();
        uint256 quantity = supplyChainInventory.getQuantity(1);
        assert(quantity == 10);
    }

    function testFail_GetPriceInvalidProductState() public createAccount {
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 5);
        vm.expectRevert(SupplyChainInventory__InvalidProductState.selector);
        supplyChainInventory.getPrice(2);
    }

    function testFail_GetQuantityInvalidProductState() public createAccount {
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 5);
        vm.expectRevert(SupplyChainInventory__InvalidProductState.selector);
        supplyChainInventory.getQuantity(1);
    }

    function testFail_GetPriceInvalidProductID() public {
        vm.expectRevert(SupplyChainInventory__InvalidProductID.selector);
        supplyChainInventory.getPrice(4);
    }

     function testQuantityAvailable() public createAccount {
        bool isAvailable = supplyChainInventory.quantityAvailable(1);
        assert(isAvailable = true);

        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 10);

        isAvailable = supplyChainInventory.quantityAvailable(1);
        assert(isAvailable = true);
    }

     function testPayForProductInvalidNewOwner() public createAccount {
        vm.expectRevert(SupplyChainInventory__InvalidNewOwnerAddress.selector);
        supplyChainInventory.payForProduct{value: 1000}(1, address(0), 5);
    }

    function testFail_PayForProductInsufficientQuantity() public createAccount {
        vm.expectRevert(SupplyChain__InsufficientQuantityForTransfer.selector);
        supplyChainInventory.payForProduct{value: 1000}(1, address(this), 11);
    } 
}