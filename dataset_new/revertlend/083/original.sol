/**
    * @notice Owner controlled function to activate/deactivate operator address
    * @param _operator operator
    * @param _active active or not
    */
function setOperator(address _operator, bool _active) public onlyOwner {
    emit OperatorChanged(_operator, _active);
    operators[_operator] = _active;
}