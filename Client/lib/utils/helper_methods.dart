String getDefaultDeviceImageUrl(String deviceType) {
  switch (deviceType) {
    case 'WASTE_SORTER':
      return 'assets/images/waste_sorter_default_opaque.png';
    case 'THERMOMETER':
      return 'assets/images/thermometer_default_opaque.png';
    default:
      return 'assets/images/recycling.png';
  }
}

String formatDeviceType(String type) {
  String formatted = type.replaceAll('_', ' ');

  return formatted.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return '';
  }).join(' ');
}

String formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  final year = date.year;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/$year';
}