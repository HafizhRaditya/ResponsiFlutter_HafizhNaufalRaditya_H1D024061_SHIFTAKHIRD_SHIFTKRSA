class Formatter {
  static const _hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String temperature(double value) => '${value.round()}°';

  static String dayName(DateTime date, {DateTime? today}) {
    final acuan = today ?? DateTime.now();
    final hariIni = DateTime(acuan.year, acuan.month, acuan.day);
    final selisih = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(hariIni).inDays;
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Besok';
    return _hari[date.weekday - 1];
  }

  static String shortDate(DateTime date) =>
      '${date.day} ${_bulan[date.month - 1]}';

  static String fullDate(DateTime date) =>
      '${_hari[date.weekday - 1]}, ${date.day} ${_bulan[date.month - 1]} '
      '${date.year}';

  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}.'
      '${date.minute.toString().padLeft(2, '0')}';
}
