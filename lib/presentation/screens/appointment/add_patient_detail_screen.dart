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
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final AppointmentBloc _appointmentBloc;

  @override
  void initState() {
    super.initState();
    _appointmentBloc = AppointmentBloc(
      appointmentService: context.read(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    descriptionController.dispose();
    _appointmentBloc.close();
    super.dispose();
  }

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
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Info Card
                    _buildDoctorCard(),
                    const SizedBox(height: 24),

                    // Consultation Fee Display
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

                    // Patient Name Field
                    _buildTextField(
                      controller: nameController,
                      label: 'Patient Name',
                      hint: 'Enter patient name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Contact Number Field
                    _buildTextField(
                      controller: contactController,
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

                    // Description Field
                    _buildTextField(
                      controller: descriptionController,
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

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _appointmentBloc.add(
                              SetPatientDetailsEvent(
                                patientName: nameController.text.trim(),
                                contactNumber: contactController.text.trim(),
                                description: descriptionController.text.trim(),
                              ),
                            );
                          }
                        },
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
            child: const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 20,
            ),
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