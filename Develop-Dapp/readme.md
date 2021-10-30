![](http://futureworld.com/web/assets/img/logo-button.png)

[TOC]


## 简介

> projectAPI.sol 是“未来世界”DAO社区与开发者Dapp最核心的环节，它决定了社区的共识、帮助项目推广利润分配等问题。操作步骤如下。


## 第一步：创建你的Dapp合约
创建合约，在合约中引入demo.sol中的相关内容，除函数 test()之外，其余的如果对合约内容不够熟悉的最好全部保留，也可以根据您进行灵活配置。创建好你的合约合约。
> tips:可以将`projectAPI.sol`文件复制到本地进行调试与各项测试。


## 第二步 向社区`projectAPI.sol`提交你的项目申请
项目简介在[0x758a50c5dca4611d35a80f304aa1c1092ba09c1d](https://ftmscan.com/address/0x758a50c5dca4611d35a80f304aa1c1092ba09c1d "0x758a50c5dca4611d35a80f304aa1c1092ba09c1d")中找到函数`supplayProject（）`,提交项目的相关资料。资料包括`项目名称`,`项目简介`,`合约地址`，`收款地址`等等。


> tips:调用成功后联系社区相关工作人员进行进行合约审核。

## 第三步 在你的合约中调用`confirmProject()` 确认身份
## 其他问题
### 查询用户付费

- **solidity**
``` solidity
	projectAPI.viewUserPay(uint _pid,address _user);
```

- **javascript**
```javascript
contract.methods.payInformation('你的ID','用户地址','收费类目').call(function(s,r){
	if(s==null && r.status) {
		//执行你的代码....
	}
})
```

### 向用户发起付费
- **solidity**
``` solidity
	function test() public payable {
        require(msg.value > 0) ;
        projectAPI.projectContractPay(myID,msg.sender,'item-1') ;   //在合约中记录该笔用户记录
        payable(projectApiAddr).transfer(msg.value) ;       //将资金转移到合约中再分配（可随时提现）
    }
```
- **javascript**
```javascript
contract.methods.projectWebPay(uint _pid,string memory _item).send({from:address}).on('confirmation',function(){
	//在链上确认后执行相关你的代码
})
```

### 提款
在[0x758a50c5dca4611d35a80f304aa1c1092ba09c1d](https://ftmscan.com/address/0x758a50c5dca4611d35a80f304aa1c1092ba09c1d "0x758a50c5dca4611d35a80f304aa1c1092ba09c1d")中找到`projectWidraw(uint _pid)`进行提款即可，需要注意的是你必须用在supplyProject发起申请的地址才能够进行取款。

> tips:在合约中一共留下了3个地址。一个是你提交申请地址（项目管理）。一个是收款的钱包地址（用户收款）。一个是你的合约地址（用于再次确认是否属于您本人）



