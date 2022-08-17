// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import "../src/EtherStore.sol";


contract EtherStoreTest is Test {
    
    EtherStore public etherStore;
    Attack public attack;

    address internal Alice;
    address internal Bob;
    address internal Eve;


    function setUp() public {
        etherStore = new EtherStore(); 
        Alice = vm.addr(1);
        vm.deal(Alice,2 ether);
        Bob = vm.addr(2);
        vm.deal(Bob,2 ether);
        Eve = vm.addr(3);
        vm.deal(Eve,2 ether);
        attack = new Attack(address(etherStore));
    }

    function testDeposit(uint16 amount) public {
        etherStore.deposit{value:amount}();
        uint count = etherStore.balances(address(this));
        uint balance = payable(address(etherStore)).balance;
        assertTrue(balance == amount,"error balance");
        assertTrue(count==amount,"error");
    }

    function testBalances() public {        
        uint alice_balance = payable(Alice).balance;
        uint bob_balance = payable(Bob).balance;
        uint eve_balance = payable(Eve).balance;
        assertTrue(alice_balance == 2 ether,"wrong balance");
        assertTrue(bob_balance == 2 ether,"wrong balance");
        assertTrue(eve_balance == 2 ether,"wrong balance");
        vm.startPrank(Alice);
        payable(Bob).transfer(1 ether);
        assertTrue(payable(Bob).balance == 3 ether,"wrong balance");
        assertTrue(payable(Alice).balance == 1 ether,"wrong balance");
    }

    function testAttack() public{
        vm.startPrank(Alice);
        etherStore.deposit{value:1 ether}();
        vm.stopPrank();
        vm.startPrank(Bob);
        etherStore.deposit{value:1 ether}();
        vm.stopPrank();
        assertTrue(etherStore.getBalance() == 2 ether,"somthing wrong");
        vm.startPrank(Eve);      
        attack.attack{value:1 ether}();
        
        assertTrue(attack.getBalance() == 3 ether,"wrong balance");
       // payable(attack).transfer{value:1 ether}();
        //assertTrue(!attack.fallbackstatus(),"wrong fall back status");
    }

}