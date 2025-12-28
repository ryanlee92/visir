import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezonePickerWidget extends StatefulWidget {
  final String? currentTimezone;
  final Function(String?) onSelected;
  final bool allowNone;
  final bool allowDeviceDefault;
  final String? deviceTimezone;

  const TimezonePickerWidget({
    super.key,
    this.currentTimezone,
    required this.onSelected,
    this.allowNone = false,
    this.allowDeviceDefault = true,
    this.deviceTimezone,
  });

  @override
  State<TimezonePickerWidget> createState() => _TimezonePickerWidgetState();
}

class _TimezonePickerWidgetState extends State<TimezonePickerWidget> {
  late List<TimezoneItem> filteredTimezones;
  late List<TimezoneItem> allTimezones;

  @override
  void initState() {
    super.initState();
    allTimezones = _buildTimezoneList();
    filteredTimezones = allTimezones;
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<TimezoneItem> _buildTimezoneList() {
    final locations = tz.timeZoneDatabase.locations;
    final now = DateTime.now();
    final List<TimezoneItem> timezones = [];

    for (var entry in locations.entries) {
      final location = entry.value;
      final tzDateTime = tz.TZDateTime.from(now, location);
      final offset = tzDateTime.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60);
      final offsetString = 'GMT${hours >= 0 ? '+' : ''}$hours${minutes != 0 ? ':${minutes.abs().toString().padLeft(2, '0')}' : ':00'}';

      // Parse city name from location
      final parts = entry.key.split('/');
      final cityName = parts.length > 1 ? parts.last.replaceAll('_', ' ') : parts.first;
      final region = parts.length > 1 ? parts.first : '';

      timezones.add(TimezoneItem(id: entry.key, cityName: cityName, region: region, offsetString: offsetString, offsetMinutes: offset.inMinutes));
    }

    // Sort by offset, then by city name
    timezones.sort((a, b) {
      final offsetCompare = a.offsetMinutes.compareTo(b.offsetMinutes);
      if (offsetCompare != 0) return offsetCompare;
      return a.cityName.compareTo(b.cityName);
    });

    return timezones;
  }

  int _getItemCount() {
    int count = filteredTimezones.length;
    if (widget.allowDeviceDefault && widget.deviceTimezone != null) count++;
    if (widget.allowNone) count++;
    return count;
  }

  int _getTimezoneIndex(int index) {
    int offset = 0;
    if (widget.allowDeviceDefault && widget.deviceTimezone != null) offset++;
    if (widget.allowNone) offset++;
    return index - offset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          VisirSearchBar(
            padding: EdgeInsets.all(8),
            hintText: context.tr.search_timezone,
            onSubmitted: (text) async {},
            onChanged: (text) {
              final query = text.toLowerCase();
              setState(() {
                if (query.isEmpty) {
                  filteredTimezones = allTimezones;
                } else {
                  filteredTimezones = allTimezones.where((tz) {
                    return tz.cityName.toLowerCase().contains(query) ||
                        tz.region.toLowerCase().contains(query) ||
                        tz.offsetString.toLowerCase().contains(query) ||
                        tz.id.toLowerCase().contains(query);
                  }).toList();
                }
              });
            },
            onClose: () {},
          ),

          // Timezone list with Device Default and None options
          Expanded(
            child: ListView.builder(
              itemCount: _getItemCount(),
              padding: EdgeInsets.only(bottom: 12),
              itemBuilder: (context, index) {
                // Device Default option
                if (widget.allowDeviceDefault && widget.deviceTimezone != null && index == 0) {
                  final isSelected = widget.currentTimezone == null || widget.currentTimezone == widget.deviceTimezone;
                  return VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () {
                      widget.onSelected(null);
                      Navigator.of(context).pop();
                    },
                    isSelected: isSelected,
                    style: VisirButtonStyle(height: 36, padding: EdgeInsets.symmetric(horizontal: 12), margin: EdgeInsets.symmetric(vertical: 2)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Device Default', style: context.bodyMedium?.textColor(context.outlineVariant)),
                              if (widget.deviceTimezone != null)
                                Text(
                                  widget.deviceTimezone!,
                                  style: context.bodySmall?.textColor(context.inverseSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // None option (for secondary timezone only)
                if (widget.allowNone && index == (widget.allowDeviceDefault && widget.deviceTimezone != null ? 1 : 0)) {
                  final isSelected = widget.currentTimezone == null && !widget.allowDeviceDefault;
                  return VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    onTap: () {
                      widget.onSelected(null);
                      Navigator.of(context).pop();
                    },
                    isSelected: isSelected,
                    style: VisirButtonStyle(height: 36, padding: EdgeInsets.symmetric(horizontal: 12), margin: EdgeInsets.symmetric(vertical: 2)),
                    child: Row(
                      children: [Expanded(child: Text('None', style: context.bodyMedium?.textColor(context.outlineVariant)))],
                    ),
                  );
                }

                // Regular timezone items
                final timezoneIndex = _getTimezoneIndex(index);
                if (timezoneIndex >= filteredTimezones.length) {
                  return SizedBox.shrink();
                }

                final timezone = filteredTimezones[timezoneIndex];
                final isSelected = timezone.id == widget.currentTimezone;

                return VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  onTap: () {
                    widget.onSelected(timezone.id);
                    Navigator.of(context).pop();
                  },
                  isSelected: isSelected,
                  style: VisirButtonStyle(height: 36, padding: EdgeInsets.symmetric(horizontal: 12), margin: EdgeInsets.symmetric(vertical: 2)),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(timezone.id, style: context.bodyMedium?.textColor(context.outlineVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 2),
                          Text(timezone.offsetString, style: context.bodySmall?.textColor(context.inverseSurface)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimezoneItem {
  final String id;
  final String cityName;
  final String region;
  final String offsetString;
  final int offsetMinutes;

  TimezoneItem({required this.id, required this.cityName, required this.region, required this.offsetString, required this.offsetMinutes});
}
