// VisitHistoryScreen.dart

// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/visit_history_provider.dart';
import 'package:vms_resident_app/src/core/navigation/route_observer.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart'; 

const List<String> _filters = ['All', 'Pending', 'Validated', 'Expired', 'Cancelled'];

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> with RouteAware {
  String _selectedFilter = 'All'; 
  double _opacity = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).setFilterByStatus(_selectedFilter); 
    });
  }

  @override
  void didPopNext() {
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    await provider.setFilterByStatus(_selectedFilter); 
    if (!mounted) return;

    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _opacity = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Visit History',
          style: TextStyle(color: Colors.amber),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShellScreen()),
              );
            }
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.sort, color: Colors.amber),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.amber),
                    ),
                  );
                }

                if (provider.historyList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No visit history found.',
                      style: TextStyle(color: Colors.amber),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Colors.amber,
                  onRefresh: () async => _refreshHistory(),
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: provider.historyList.length,
                      itemBuilder: (context, index) {
                        final log = provider.historyList[index];
                        return _HistoryLogTile(
                          log: log,
                          onDeleted: () => _refreshHistory(),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedFilter = filter);
                  Provider.of<HistoryProvider>(context, listen: false)
                      .setFilterByStatus(filter);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedFilter == filter ? Colors.amber : Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: _selectedFilter == filter ? Colors.black : Colors.amber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HistoryLogTile extends StatefulWidget {
  final dynamic log;
  final VoidCallback onDeleted;

  const _HistoryLogTile({
    required this.log,
    required this.onDeleted,
    super.key,
  });

  @override
  State<_HistoryLogTile> createState() => _HistoryLogTileState();
}

class _HistoryLogTileState extends State<_HistoryLogTile>
    with SingleTickerProviderStateMixin {
  final bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final String visitorName = log['visitor_name'] ?? 'Unnamed Visitor';
    final String accessCode = log['code'] ?? 'N/A';
    final String status = log['status'] ?? 'pending';
    final String? visitDateStr = log['visit_date'];

    DateTime? visitDate = DateTime.tryParse(visitDateStr ?? '');
    final String formattedDate = visitDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(visitDate)
        : 'Unknown Date';
    
    String displayStatus;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'active':
      case 'pending': 
        displayStatus = 'PENDING';
        statusColor = Colors.orange;
        break;
      case 'used':
        displayStatus = 'VALIDATED'; 
        statusColor = Colors.green;
        break;
      case 'expired':
        displayStatus = 'EXPIRED';
        statusColor = Colors.red;
        break;
      case 'cancelled':
        displayStatus = 'CANCELLED'; 
        statusColor = Colors.grey;
        break;
      default:
        displayStatus = status.toUpperCase();
        statusColor = Colors.grey;
    }

    return AnimatedOpacity(
      opacity: _isDeleting ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      onEnd: () {
        if (_isDeleting) widget.onDeleted();
      },
      child: AnimatedSlide(
        offset: _isDeleting ? const Offset(1, 0) : Offset.zero,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.amber.shade200, width: 0.5),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withAlpha(51),
              child: Icon(Icons.person, color: statusColor),
            ),
            title: Text(
              visitorName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.amber,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        displayStatus, 
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing: SizedBox(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    accessCode,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (status.toLowerCase() == 'active' || status.toLowerCase() == 'pending')
                    SizedBox( 
                      height: 30,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete code',
                        onPressed: () => _confirmDelete(codeId: log['id']),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete({required String? codeId}) {
    if (codeId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code ID not available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Visitor Code', style: TextStyle(color: Colors.amber)),
        content: const Text('Are you sure you want to delete this visitor code?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final historyProvider = Provider.of<HistoryProvider>(
                context,
                listen: false,
              );
              try {
                await historyProvider.deleteVisitorCode(codeId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visitor code deleted')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete code: $e')),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
