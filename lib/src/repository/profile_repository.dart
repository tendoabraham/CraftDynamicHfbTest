part of craft_dynamic;

class ProfileRepository {
  final _bankRepository = BankAccountRepository();
  final _sharedPref = CommonSharedPref();
  final _services = APIService();

  Future<bool> checkAppActivationStatus() =>
      _sharedPref.getAppActivationStatus();

  Future<List<BankAccount>> getUserBankAccounts() async =>
      await _bankRepository.getAllBankAccounts() ?? [];

  getUserInfo(UserAccountData key) => _sharedPref.getUserAccountInfo(key);

  Future<DynamicResponse?> checkAccountBalance(String bankAccountID) async {
    return await _services.checkAccountBalance(
        bankAccountID: bankAccountID, merchantID: "BALANCE", moduleID: "HOME");
  }

  String getActualBalanceText(DynamicResponse dynamicResponse) {
    return dynamicResponse.resultsData
            ?.firstWhere((e) => e["ControlID"] == "BALTEXT")["ControlValue"] ??
        "Not available";
  }

  getAllAccountBalancesAndSaveInAppState() async {
    accountsAndBalances.clear();
    if (showAccountBalanceInDropdowns.value) {
      var accounts = await _bankRepository.getAllBankAccounts() ?? [];
      for (var account in accounts) {
        var accountBalance = await checkAccountBalance(account.bankAccountId);
        if (accountBalance != null &&
            accountBalance.status == StatusCode.success.statusCode) {
          accountsAndBalances.addAll(
              {account.bankAccountId: getActualBalanceText(accountBalance)});
        }
      }
      return;
    } else {
      accountsAndBalances.clear();
      return;
    }
  }

  Future<DynamicResponse?> checkMiniStatement(String bankAccountID,
      {merchantID = "MINISTATEMENT"}) {
    return _services.checkMiniStatement(
        bankAccountID: bankAccountID,
        merchantID: merchantID,
        moduleID: merchantID);
  }
}
