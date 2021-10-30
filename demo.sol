/**
 *Submitted for verification at FtmScan.com on 2021-09-19
*/
// SPDX-License-Identifier: MIT

/**
 * 合约的安全性已经被FTMSCAN验证并且公开
 * 代码非常简洁，目的就是为了帮助大家节省Gas费用 
 * 社区：https://futureworld.app
 * 作者：冈本聪
*/

pragma solidity 0.8.7;


/**
 * 以下的内容除了 ‘test’函数外，其余都建议保留。
 * 如遇到不懂可在技术群寻求支持
*/
interface iProjectAPI{
    function viewUserPay(uint _pid,address _user) external view returns (address user,string memory item,uint payTime,uint money,bool status);   //查询用户付款信息 
    function projectContractPay(uint _pid ,address _user,string memory _item,uint _amount) external returns(bool) ;
    function viewMyID() external view returns(uint) ;  //查询自己的ID
}


contract Demo {
    address private admin ;
    address projectApiAddr = 0x2474E374Db782bB3A609f6109A40EE366B6cD747 ;  // projectAPI合约地址
    iProjectAPI projectAPI = iProjectAPI(projectApiAddr);  //引用合约  
    uint public myID ;

    
    function testpay() public payable returns (bool) {
        require(msg.value > 0) ;
        bool status = payable(projectApiAddr).send(msg.value);
        if(status) projectAPI.projectContractPay(myID,msg.sender,'item-1',msg.value) ;
        return status ;
    }

    function testPayInfo() public view returns (address user,string memory item,uint payTime,uint money,bool status) {
        return projectAPI.viewUserPay(myID,msg.sender) ;
    }

    constructor(address _admin){
        admin = _admin ;
    }

    function confirmProject() public onlyAdmin {
        myID = projectAPI.viewMyID() ;
    }
    
    
    modifier onlyAdmin(){
        require(msg.sender == admin );
        _;
    }
    
    
}