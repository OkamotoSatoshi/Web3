/**
*  该合约是与开发者Dapp进行接口交互的合于。用途如下：
*  1. Dapp收费后再分配
*  2. 帮助项目进行初步的合约审核，社区宣传
*  3. 记录社区成员是否付费
*  https://futureworld.app 
*  未来世界DAO 社区发起人：冈本聪
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./safemath.sol" ;

contract projectsAPI {
	using SafeMath for uint256 ;

	//社区相关信息
	address public fundAddress ;  //资金会收款地址
	address public admin ;

	//项目方需要的相关变量和数据
	uint public PID = 1 ;   //项目的ID
	mapping (uint => project) public Projects;   // 项目ID => 项目信息
	mapping (uint => address) public projectOwner;   //项目的所有者
	mapping (address => uint[]) public myProjects ;  //持有者所有项目列表
	mapping (address => uint) private queryID  ;  //合约 => 项目ID

	//用户付费相关
	mapping (uint => mapping(address => payInfo)) public payInformation ; // 项目ID=>用户=>支付信息

	//相关资金问题
	uint private projectPercent = 80 ;  //项目方分成比例
	mapping(address=>uint) public projectBalance ; //项目方的收入
	uint public fundationBalance ;  //社区基金会

	//项目信息
	struct project {
		string name;	   //项目名称
		string intro;	   //项目简介
		string link ;	   //Dapp网站
		address wallet ;   //收款地址
		string chain ;     //主链名称(FTM，BSC....等)
		address contract_ ; //Dapp contract
		string  tag ;      //项目的类型
		uint8  status ;    //“1”表示 待审核，“2”表示审核通过，“3”表示拒绝
		uint  profitPercent ; //项目方的利润比例  
	}

	//付款人信息
	struct payInfo{
		address user ;  //付款人
		string item  ;  //付费的具体类目
		uint payTime ;	//支付时间
		uint money   ;	//支付金额
		bool status  ;  //付费状态
	}

	constructor(address _admin,address _fundAddress) {
		admin = _admin ;     //管理员
		fundAddress	= _fundAddress ;	//资金会的地址
	}

    //合约中用户支付查询
    function viewUserPay(uint _pid,address _user) external view returns (address user,string memory item,uint payTime,uint money,bool status) {
        user = payInformation[_pid][_user].user ;
        item = payInformation[_pid][_user].item ;
        payTime = payInformation[_pid][_user].payTime ;
        money = payInformation[_pid][_user].money ;
        status = payInformation[_pid][_user].status ;
        return (user,item,payTime,money,status) ;
    }

    //管理员修改项目信息
	function modifyAdminInfo(address _admin, address _fundAddress,uint _projectPercent) public onlyAdmin {
		admin = _admin ;     //管理员
		fundAddress	= _fundAddress ;	//资金会的地址
		projectPercent = _projectPercent;   // Dapp开发方分成
	}

	//社区资金会提款
	function fundationWithdraw()  public {
	    require(msg.sender == fundAddress ,"You can not do that!!!") ;
		payable(fundAddress).transfer(fundationBalance) ;
		fundationBalance = 0 ;
	}
	
	//项目方提款
	function projectWidraw(uint _pid) external onlyProjectOwner(_pid) {
		address wallet = Projects[_pid].wallet ;
		payable(wallet).transfer(projectBalance[wallet]) ;
		projectBalance[wallet] = 0 ;
	}
	
    receive() external payable {
        
    }

	//资金分配
	function _fundAllocation(uint _money,address _projectOwner) internal {
		projectBalance[_projectOwner] += (_money.mul(projectPercent)).div(100) ;
		fundationBalance += (_money - (_money.mul(projectPercent)).div(100)) ;
	}

    //项目合约调用查询自己的ID
    function viewMyID() external view returns(uint) {
        require(_isContract(msg.sender));
        return queryID[msg.sender] ; 
    }

	//项目方收钱接口
	function projectContractPay(uint _pid ,address _user,string memory _item,uint _amount) external returns (bool)  {  //开发者合约调用,huo'zhe。
		require(_isContract(msg.sender) && Projects[_pid].contract_ == msg.sender && Projects[_pid].status == 2) ;
		payInformation[_pid][_user] =  payInfo(_user,_item, block.timestamp, _amount,true) ;
		_fundAllocation(_amount,Projects[_pid].wallet);
		return true ;
	}
	
	//前端web方式收款
	function projectWebPay(uint _pid,string memory _item) public payable {
	    require(msg.sender != address(0)) ;
	    require(msg.value > 0) ;
	    payInformation[_pid][msg.sender] =  payInfo(msg.sender,_item, block.timestamp, msg.value,true) ;
		_fundAllocation(msg.value,Projects[_pid].wallet);
	}

    //开发者申请项目提交
	function supplyProject(string memory _name,string memory _intro,string memory _link,address _wallet,string memory _chain,address _contract,string memory _tag) external returns(uint myID) {
		require(msg.sender != address(0)) ; 
		require(queryID[_contract] == 0 ) ;
		Projects[PID] = project(_name,_intro,_link,_wallet,_chain,_contract,_tag,1,projectPercent) ;
		projectOwner[PID] = msg.sender ;
		myProjects[msg.sender].push(PID) ;
		queryID[_contract] = PID ;
		myID = PID ;
		PID++ ;
		return myID ;
	}

	//管理员修改项目信息
	function adminMofityProject(uint _pid,string memory _tag,uint8  _status) public onlyAdmin {
		string memory name = Projects[_pid].name ;
		string memory intro = Projects[_pid].intro ;
		string memory link = Projects[_pid].link ;
		string memory chain = Projects[_pid].chain ;
		address wallet = Projects[_pid].wallet ;
		address contract_ = Projects[_pid].contract_ ;
		uint percent = Projects[_pid].profitPercent ;
		Projects[_pid] = project(name,intro,link,wallet,chain,contract_,_tag,_status,percent) ;
	}
	
	//判断是否为合约地址
    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

	//项目方修改项目信息,适用于发布,升级合约
	function modifyProject(uint _pid ,string memory _name,string memory _intro,string memory _link,address _wallet,string memory _chain,address _contract,string memory _tag) external onlyProjectOwner(_pid){
		require(msg.sender != address(0)) ; 
		uint percent = Projects[_pid].profitPercent ;
		queryID[_contract] = _pid ;
		Projects[_pid] = project(_name,_intro,_link,_wallet,_chain,_contract,_tag,1,percent) ;
	}

	//社区管理员（没有具体的人，而是约束的某个合约）修改
	modifier onlyAdmin {
		require(admin == msg.sender) ;
		_;
	}

	modifier onlyProjectOwner(uint _pid) { 
		require (projectOwner[_pid] == msg.sender); 
		_; 
	}
	
	
    
}
