class BackendService {
  static Future<bool> claimPoints(int points) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<bool> requestCashOut(int points, String method) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  static Future<bool> redeemGiftCard(String cardId, int points) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<bool> enterRaffle(String raffleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  static Future<String> getReferralLink(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'https://doomscroll.app/ref/$code';
  }
}
