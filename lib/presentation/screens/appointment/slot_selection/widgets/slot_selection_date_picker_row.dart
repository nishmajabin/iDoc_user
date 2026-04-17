import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:intl/intl.dart';

class SlotSelectionDatePickerRow extends StatelessWidget {
  final List<DateTime> availableDates;
  final DateTime selectedDate;

  const SlotSelectionDatePickerRow({
    required this.availableDates,
    required this.selectedDate,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.backgroundColor,
      child:
          availableDates.isEmpty
              ? Center(
                child: Text(
                  'No available dates',
                  style: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                ),
              )
              : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  final isSelected = date.isAtSameMomentAs(selectedDate);
                  return GestureDetector(
                    onTap:
                        () => context.read<AppointmentBloc>().add(
                          SelectDateEvent(date),
                        ),
                    child: Container(
                      width: 66,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.elevatedBgColor : AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.elevatedBgColor
                                  : AppColors.lightText,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: AppColors.elevatedBgColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected ? AppColors.backgroundColor : AppColors.lightTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd').format(date),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.backgroundColor : AppColors.shadowDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM').format(date),
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isSelected
                                      ? AppColors.backgroundColor.withValues(alpha: 0.8)
                                      : AppColors.lightTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}