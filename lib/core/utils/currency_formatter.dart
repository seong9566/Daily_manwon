import 'package:intl/intl.dart';

/// 금액 포맷 유틸리티
/// 원화 표기 규칙을 일관되게 적용한다
abstract final class CurrencyFormatter {
  /// 천 단위 구분자 포맷터 (재사용을 위해 캐싱)
  static final NumberFormat _formatter = NumberFormat('#,###');

  /// 금액을 "₩ 7,200" 형식으로 포맷한다
  ///
  /// 음수인 경우: "-₩ 3,500"
  /// 0인 경우: "₩ 0"
  static String format(int amount) {
    if (amount < 0) {
      // 음수는 부호를 앞에 붙이고 절댓값을 포맷한다
      return '-₩ ${_formatter.format(amount.abs())}';
    }
    return '₩ ${_formatter.format(amount)}';
  }

  /// 금액을 "7,200원" 형식으로 포맷한다 (원 단위 표기)
  ///
  /// 음수인 경우: "-3,500원"
  static String formatWithWon(int amount) {
    if (amount < 0) {
      return '-${_formatter.format(amount.abs())}원';
    }
    return '${_formatter.format(amount)}원';
  }

  /// 금액을 천 단위 구분자만 적용한 숫자 문자열로 반환한다
  ///
  /// UI에서 단위를 별도 위젯으로 렌더링할 때 사용
  static String formatNumberOnly(int amount) {
    return _formatter.format(amount.abs());
  }
}
