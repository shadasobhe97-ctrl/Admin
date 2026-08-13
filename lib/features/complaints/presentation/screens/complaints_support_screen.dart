import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../logic/cubit/complaints_cubit.dart';
import 'complaints_screen.dart';

class ComplaintsSupportView extends StatelessWidget {
  const ComplaintsSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ComplaintsCubit>(
      create: (context) => sl<ComplaintsCubit>()..fetchComplaints(),
      child: const ComplaintsScreen(),
    );
  }
}
