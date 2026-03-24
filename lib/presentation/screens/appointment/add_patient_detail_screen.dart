import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection_screen.dart';
import 'package:idoc_user/presentation/screens/appointment/widgets/consultation_fee_display.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;

  const PatientDetailsScreen({
    Key? key,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    required this.consultationFee,
  }) : super(key: key);

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  // Name controller is kept so the user can edit manually when the fetch
  // fails or returns null (graceful fallback).
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AppointmentBloc _appointmentBloc;

  /// True when we have a valid name from Firestore — the name field becomes
  /// a read-only display card and the controller is no longer used.
  bool _isNamePrefilled = false;

  @override
  void initState() {
    super.initState();
    _appointmentBloc = AppointmentBloc(
      appointmentService: context.read(),
    );
    // Kick off the name fetch immediately using the logged-in user's uid.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _appointmentBloc.add(FetchPatientNameEvent(uid));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _appointmentBloc.close();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// The name that will be submitted — from Firestore if pre-filled,
  /// otherwise from the manual text field.
  String get _resolvedPatientName =>
      _isNamePrefilled ? _nameController.text : _nameController.text.trim();

  void _onNameFetched(String? name) {
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
      setState(() => _isNamePrefilled = true);
    } else {
      // Name unavailable — keep the editable field, user types manually.
      setState(() => _isNamePrefilled = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _appointmentBloc.add(
        SetPatientDetailsEvent(
          patientName: _resolvedPatientName,
          contactNumber: _contactController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentBloc,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Appointment'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: BlocListener<AppointmentBloc, AppointmentState>(
          listener: (context, state) {
            // Name fetched — update UI.
            if (state is PatientNameFetched) {
              _onNameFetched(state.patientName);
            }

            // Patient details confirmed — navigate to slot selection.
            if (state is PatientDetailsSet) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: _appointmentBloc,
                    child: SlotSelectionScreen(
                      consultationFee: widget.consultationFee,
                      doctorId: widget.doctorId,
                      doctorName: widget.doctorName,
                      doctorSpecialist: widget.doctorSpecialist,
                      doctorProfileImageUrl: widget.doctorProfileImageUrl,
                    ),
                  ),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Doctor card ──────────────────────────────────────
                    _buildDoctorCard(),
                    const SizedBox(height: 24),

                    // ── Consultation fee ─────────────────────────────────
                    ConsultationFeeDisplay(
                      consultationFee: widget.consultationFee,
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Appointment For',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Patient name — auto-fetched or manual ────────────
                    BlocBuilder<AppointmentBloc, AppointmentState>(
                      buildWhen: (prev, curr) =>
                          curr is PatientNameLoading ||
                          curr is PatientNameFetched,
                      builder: (context, state) {
                        if (state is PatientNameLoading) {
                          return _buildNameShimmer();
                        }
                        return _isNamePrefilled
                            ? _buildPrefilledNameCard()
                            : _buildNameTextField();
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Contact number ───────────────────────────────────
                    _buildTextField(
                      controller: _contactController,
                      label: 'Contact Number',
                      hint: 'Enter contact number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact number';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a valid contact number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Reason for appointment ───────────────────────────
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Reason for Appointment',
                      hint: 'Describe your symptoms or reason for visit',
                      icon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please describe the reason for appointment';
                        }
                        if (value.trim().length < 10) {
                          return 'Please provide more details (at least 10 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Next button ──────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D4FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  /// Shown while the name is being fetched — matches the height of the
  /// text field so there is no layout jump.
  Widget _buildNameShimmer() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.person_outline, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  /// Shown when Firestore returned a valid name — read-only, clearly branded
  /// with a "verified" badge so the user knows it came from their profile.
  Widget _buildPrefilledNameCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Color(0xFF00D4FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Name',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Badge indicating the name was pulled from the user's profile.
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified_user_outlined,
                    size: 12, color: Color(0xFF00D4FF)),
                SizedBox(width: 4),
                Text(
                  'From Profile',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF00D4FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fallback editable field shown when the name could not be fetched.
  Widget _buildNameTextField() {
    return _buildTextField(
      controller: _nameController,
      label: 'Patient Name',
      hint: 'Enter patient name',
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter patient name';
        }
        return null;
      },
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              image: widget.doctorProfileImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.doctorProfileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.doctorProfileImageUrl == null
                ? const Icon(Icons.person, size: 30, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.doctorName ?? "Doctor"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctorSpecialist ?? 'Specialist',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 60 : 0),
          child: Icon(icon, color: const Color(0xFF00D4FF)),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 2),
        ),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }
}