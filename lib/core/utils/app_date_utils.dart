import 'package:intl/intl.dart';

/// 날짜/시간 관련 유틸리티
/// Flutter 내장 DateUtils와 이름 충돌을 피하기 위해 AppDateUtils로 명명한다
abstract final class AppDateUtils {
  // 포맷터는 생성 비용이 있으므로 캐싱해서 재사용한다
  static final DateFormat _monthDayFormatter = DateFormat('M월 d일', 'ko');
  static final DateFormat _timeFormatter = DateFormat('a h:mm', 'ko');

  // -------------------------
  // 날짜 범위 계산
  // -------------------------

  /// 해당 날짜의 시작 시각 (00:00:00.000)을 반환한다
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 해당 날짜의 종료 시각 (23:59:59.999)을 반환한다
  ///
  /// DB 쿼리의 범위 조건에서 당일 마지막 시각을 포함하기 위해 사용한다
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// 오늘의 시작 시각 (00:00:00.000)을 반환한다
  static DateTime get todayStart => startOfDay(DateTime.now());

  /// 오늘의 종료 시각 (23:59:59.999)을 반환한다
  static DateTime get todayEnd => endOfDay(DateTime.now());

  // -------------------------
  // 날짜 포맷
  // -------------------------

  /// 날짜를 "3월 24일 (오늘)" 또는 "3월 24일 (어제)" 형식으로 반환한다
  ///
  /// 오늘/어제/그제 이외의 날짜는 "3월 24일" 형식만 반환한다
  static String formatDateWithLabel(DateTime date) {
    final base = _monthDayFormatter.format(date);
    final label = _getDayLabel(date);

    if (label == null) return base;
    return '$base ($label)';
  }

  /// 시각을 "오후 2:30" 형식으로 반환한다
  static String formatTime(DateTime dateTime) {
    // intl의 'a' 패턴은 로케일에 따라 오전/오후를 반환한다
    return _timeFormatter.format(dateTime);
  }

  // -------------------------
  // 내부 헬퍼
  // -------------------------

  /// 오늘/어제/그제에 해당하는 레이블 문자열을 반환한다
  /// 해당 없으면 null 반환
  static String? _getDayLabel(DateTime date) {
    final today = DateTime.now();
    final diff = _dayDifference(today, date);

    return switch (diff) {
      0 => '오늘',
      1 => '어제',
      2 => '그제',
      _ => null,
    };
  }

  /// 두 날짜 간의 일(day) 차이를 반환한다
  /// 시간 성분을 제거한 순수 날짜 기준으로 계산한다
  static int _dayDifference(DateTime a, DateTime b) {
    final dateA = DateTime(a.year, a.month, a.day);
    final dateB = DateTime(b.year, b.month, b.day);
    return dateA.difference(dateB).inDays.abs();
  }

  /// 두 DateTime이 같은 날인지 확인한다
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 주어진 날짜가 오늘인지 확인한다
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  // -------------------------
  // 주간 계산
  // -------------------------

  /// 주어진 날짜가 속한 주의 시작일(일요일)을 반환한다
  static DateTime weekStartOf(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday % 7));
  }

  /// 주간 뷰에 표시할 7일 리스트 (일요일 시작)
  static List<DateTime> weekDaysFrom(DateTime weekStart) {
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  /// 주간 범위 레이블 반환 (예: "4. 1 ~ 4. 7", "3. 29 ~ 4. 4")
  static String weekRangeLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.month == weekEnd.month) {
      return '${weekStart.month}월 ${weekStart.day}일 ~ ${weekStart.month}월 ${weekEnd.day}일';
    }
    return '${weekStart.month}월 ${weekStart.day}일 ~ ${weekEnd.month}월 ${weekEnd.day}일';
  }
}
