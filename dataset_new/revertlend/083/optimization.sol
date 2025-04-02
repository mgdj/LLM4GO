function setOperator(address _operator, bool _active) public onlyOwner {
    if (operators[_operator] != _active) {
        emit OperatorChanged(_operator, _active);
        operators[_operator] = _active;
    }
}