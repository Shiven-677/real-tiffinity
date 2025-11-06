// Global flag to manage checkout login state
bool _isCheckoutLoginGlobal = false;

bool getCheckoutLoginFlag() => _isCheckoutLoginGlobal;

void setCheckoutLoginFlagGlobal(bool value) {
  _isCheckoutLoginGlobal = value;
}
