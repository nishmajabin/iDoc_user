// lib/presentation/screens/available_specialists/widgets/doctor_filter_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_bloc.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

class DoctorFilterBottomSheet extends StatefulWidget {
  const DoctorFilterBottomSheet({super.key});

  @override
  State<DoctorFilterBottomSheet> createState() =>
      _DoctorFilterBottomSheetState();
}

class _DoctorFilterBottomSheetState extends State<DoctorFilterBottomSheet> {
  late DoctorFilter _currentFilter;

  // Filter options
  final List<String> _specializations = [
    'General',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Orthopedic',
    'Neurologist',
    'Gynecologist',
    'Psychiatrist',
    'ENT Specialist',
    'Endocrinologist',
    'Nutritionist',
    'Psychologist'
  ];

  // Updated experience ranges
  final List<String> _experienceRanges = [
    '0-1 years',
    '2-4 years',
    '5-7 years',
    '8+ years',
  ];

  final List<String> _genderOptions = ['Male', 'Female'];

  // Fee range
 double _minFee = 0;
 double _maxFee = 5000;
  RangeValues _feeRange = const RangeValues(0, 5000);

  // Rating - updated options
  double? _selectedRating;

  @override
  void initState() {
    super.initState();
    final state = context.read<DoctorBloc>().state;
    if (state is DoctorLoaded) {
      _currentFilter = state.filter;
      _initializeFromFilter(_currentFilter);
    } else {
      _currentFilter = const DoctorFilter();
    }
  }

  void _initializeFromFilter(DoctorFilter filter) {
    _feeRange = RangeValues(
      filter.minFee ?? 0,
      filter.maxFee ?? 5000,
    );
    _selectedRating = filter.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConsultationFeeSection(),
                  const SizedBox(height: 24),
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  _buildSpecializationSection(),
                  const SizedBox(height: 24),
                  _buildExperienceSection(),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 24),
                  _buildGenderSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Filter Doctors',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_currentFilter.hasActiveFilters)
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConsultationFeeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_wallet,
                color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Consultation Fee',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₹${_feeRange.start.round()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '₹${_feeRange.end.round()}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _feeRange,
          min: _minFee,
          max: _maxFee,
          divisions: 50,
          activeColor: AppColors.primaryColor,
          inactiveColor: AppColors.primaryColor.withOpacity(0.2),
          labels: RangeLabels(
            '₹${_feeRange.start.round()}',
            '₹${_feeRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _feeRange = values;
              _currentFilter = _currentFilter.copyWith(
                minFee: values.start,
                maxFee: values.end,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildRatingChip('4★ & above', 4.0),
            _buildRatingChip('3★ & above', 3.0),
            _buildRatingChip('2★ & above', 2.0),
            _buildRatingChip('All Ratings', null),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingChip(String label, double? rating) {
    final isSelected = _selectedRating == rating;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRating = selected ? rating : null;
          _currentFilter = _currentFilter.copyWith(minRating: _selectedRating);
        });
      },
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildSpecializationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services,
                color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Specialization',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _specializations
              .map((spec) => _buildFilterChip(
                    spec,
                    _currentFilter.specializations.contains(spec),
                    (selected) {
                      setState(() {
                        final updated = List<String>.from(
                          _currentFilter.specializations,
                        );
                        if (selected) {
                          updated.add(spec);
                        } else {
                          updated.remove(spec);
                        }
                        _currentFilter = _currentFilter.copyWith(
                          specializations: updated,
                        );
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _experienceRanges
              .map((range) => _buildFilterChip(
                    range,
                    _currentFilter.experienceRanges.contains(range),
                    (selected) {
                      setState(() {
                        final updated = List<String>.from(
                          _currentFilter.experienceRanges,
                        );
                        if (selected) {
                          updated.add(range);
                        } else {
                          updated.remove(range);
                        }
                        _currentFilter = _currentFilter.copyWith(
                          experienceRanges: updated,
                        );
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today,
                color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          'Available Today',
          _currentFilter.availableToday,
          (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(
                availableToday: value,
                availableThisWeek:
                    value ? false : _currentFilter.availableThisWeek,
              );
            });
          },
        ),
        const SizedBox(height: 8),
        _buildSwitchTile(
          'Available This Week',
          _currentFilter.availableThisWeek,
          (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(
                availableThisWeek: value,
                availableToday: value ? false : _currentFilter.availableToday,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.primaryColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Gender Preference',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ..._genderOptions.map((gender) => _buildFilterChip(
                  gender,
                  _currentFilter.gender == gender,
                  (selected) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(
                        gender: selected ? gender : null,
                        clearGender: !selected,
                      );
                    });
                  },
                )),
            _buildFilterChip(
              'No Preference',
              _currentFilter.gender == null,
              (selected) {
                if (selected) {
                  setState(() {
                    _currentFilter = _currentFilter.copyWith(clearGender: true);
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clearAllFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reset',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    print('=== APPLYING FILTERS ===');
    print('Current filter: $_currentFilter');
    print('Has active filters: ${_currentFilter.hasActiveFilters}');
    print('Min Fee: ${_currentFilter.minFee}');
    print('Max Fee: ${_currentFilter.maxFee}');
    print('Min Rating: ${_currentFilter.minRating}');
    print('Specializations: ${_currentFilter.specializations}');
    print('Experience Ranges: ${_currentFilter.experienceRanges}');
    print('Available Today: ${_currentFilter.availableToday}');
    print('Available This Week: ${_currentFilter.availableThisWeek}');
    print('Gender: ${_currentFilter.gender}');
    print('=======================');

    context.read<DoctorBloc>().add(ApplyFiltersEvent(_currentFilter));
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilter = const DoctorFilter();
      _feeRange = const RangeValues(0, 5000);
      _selectedRating = null;
    });
    context.read<DoctorBloc>().add(ClearFiltersEvent());
  }
}