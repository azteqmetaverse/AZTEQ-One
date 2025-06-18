// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract AZTEQOne is IBEP20 {
    string public constant name = "AZTEQ One";
    string public constant symbol = "AZTEQ";
    uint8 public constant decimals = 8;
    uint256 public constant totalSupply = 116_203_150 * 10 ** 8;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _locked;
    address public owner;
    bool private _ownershipRenounced;

    event OwnershipRenounced(address indexed previousOwner);
    event ApprovalUpdated(address indexed owner, address indexed spender, uint256 value);
    event TransferFailed(address indexed sender, address indexed recipient, uint256 amount, string reason);
    event BalanceUpdated(address indexed account, uint256 newBalance);

    modifier onlyOwner() {
        require(msg.sender == owner && !_ownershipRenounced, "Caller is not the owner or ownership renounced");
        _;
    }

    modifier nonReentrant() {
        require(!_locked[msg.sender], "Reentrant call");
        _locked[msg.sender] = true;
        _;
        _locked[msg.sender] = false;
    }

    constructor() {
        owner = msg.sender;
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        emit BalanceUpdated(msg.sender, totalSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override nonReentrant returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance < amount) {
            emit TransferFailed(sender, recipient, amount, "BEP20: transfer amount exceeds allowance");
            revert("BEP20: transfer amount exceeds allowance");
        }
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    function renounceOwnership() public onlyOwner {
        _ownershipRenounced = true;
        address previousOwner = owner;
        owner = address(0);
        emit OwnershipRenounced(previousOwner);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        if (sender == address(0)) {
            emit TransferFailed(sender, recipient, amount, "BEP20: transfer from the zero address");
            revert("BEP20: transfer from the zero address");
        }
        if (recipient == address(0)) {
            emit TransferFailed(sender, recipient, amount, "BEP20: transfer to the zero address");
            revert("BEP20: transfer to the zero address");
        }
        if (recipient == address(this)) {
            emit TransferFailed(sender, recipient, amount, "BEP20: transfer to contract address");
            revert("BEP20: transfer to contract address");
        }
        if (_balances[sender] < amount) {
            emit TransferFailed(sender, recipient, amount, "BEP20: transfer amount exceeds balance");
            revert("BEP20: transfer amount exceeds balance");
        }
        unchecked {
            _balances[sender] -= amount;
            _balances[recipient] += amount;
        }
        emit Transfer(sender, recipient, amount);
        emit BalanceUpdated(sender, _balances[sender]);
        emit BalanceUpdated(recipient, _balances[recipient]);
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        if (owner_ == address(0)) {
            emit TransferFailed(owner_, spender, amount, "BEP20: approve from the zero address");
            revert("BEP20: approve from the zero address");
        }
        if (spender == address(0)) {
            emit TransferFailed(owner_, spender, amount, "BEP20: approve to the zero address");
            revert("BEP20: approve to the zero address");
        }
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
        emit ApprovalUpdated(owner_, spender, amount);
    }
}