import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../bloc/court/court_bloc.dart';
import '../../bloc/court/court_event.dart';
import '../../bloc/court/court_state.dart';
import 'widgets/court_card.dart';

class CourtListPage extends StatefulWidget {
  const CourtListPage({super.key});

  @override
  State<CourtListPage> createState() => _CourtListPageState();
}

class _CourtListPageState extends State<CourtListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CourtBloc>().add(const LoadAllCourts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sân'),
        centerTitle: true,
      ),
      body: BlocBuilder<CourtBloc, CourtState>(
        builder: (context, state) {
          if (state is CourtLoading) {
            return _buildLoadingGrid();
          } else if (state is CourtListLoaded) {
            if (state.courts.isEmpty) {
              return const Center(child: Text('Không có sân nào.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CourtBloc>().add(const LoadAllCourts());
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.courts.length,
                itemBuilder: (context, index) {
                  final court = state.courts[index];
                  return CourtCard(
                    court: court,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/court-detail',
                        arguments: court.id,
                      );
                    },
                  );
                },
              ),
            );
          } else if (state is CourtError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<CourtBloc>().add(const LoadAllCourts()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(),
          ),
        );
      },
    );
  }
}
