// VisitHistoryScreen.dart

// ignore_for_file: unused_element_parameter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/visit_history_provider.dart';
import 'package:vms_resident_app/src/core/navigation/route_observer.dart';
import 'package:vms_resident_app/src/features/shell/presentation/shell_screen.dart'; 

// Use status-based filters
const List<String> _filters = ['All', 'Pending', 'Validated', 'Expired', 'Cancelled'];

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> with RouteAware {
  // UPDATED: Default filter is 'All'
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
      // UPDATED: Use the new status-based method
      Provider.of<HistoryProvider>(context, listen: false).setFilterByStatus(_selectedFilter); 
    });
  }

  // 🔁 Automatically refresh when returning from another page
  @override
  void didPopNext() {
    _refreshHistory();
  }

  Future<void> _refreshHistory() async {
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    // Use the new status-based method
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
      appBar: AppBar(
        title: const Text('Visit History'),
        centerTitle: true,
        elevation: 0,
        // ADDED BACK BUTTON LOGIC HERE
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // fallback to ShellScreen if no previous page exists
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ShellScreen()),
              );
            }
          },
        ),
        // END BACK BUTTON LOGIC
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.sort, color: Colors.blue),
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }

                if (provider.historyList.isEmpty) {
                  return const Center(child: Text('No visit history found.'));
                }

                return RefreshIndicator(
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
      scrollDirection: Axis.horizontal, // allow horizontal scroll if filters overflow
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedFilter == filter
                      ? Colors.blue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: _selectedFilter == filter
                        ? Colors.white
                        : Colors.blue.shade700,
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
  // ignore: prefer_final_fields
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final String visitorName = log['visitor_name'] ?? 'Unnamed Visitor';
    final String accessCode = log['code'] ?? 'N/A';
    final String status = log['status'] ?? 'pending';
    debugPrint('🧩 Raw status from API: $status');
    final String? visitDateStr = log['visit_date'];

    DateTime? visitDate = DateTime.tryParse(visitDateStr ?? '');
    final String formattedDate = visitDate != null
        ? DateFormat('EEE, MMM d, yyyy').format(visitDate)
        : 'Unknown Date';
    
    // --- UPDATED STATUS MAPPING LOGIC ---
    String displayStatus;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'active':
      case 'pending': 
        // Requirement: If active, display as Pending
        displayStatus = 'PENDING';
        statusColor = Colors.orange;
        break;
      
      case 'used':
        // Requirement: If used, display as Validated
        displayStatus = 'VALIDATED'; 
        statusColor = Colors.green;
        break;
        
      case 'expired':
        // Requirement: If expired, display as Expired
        displayStatus = 'EXPIRED';
        statusColor = Colors.red;
        break;
        
      case 'cancelled':
        // Requirement: If cancelled, display as Cancelled
        displayStatus = 'CANCELLED'; 
        statusColor = Colors.grey;
        break;
        
      default:
        displayStatus = status.toUpperCase();
        statusColor = Colors.grey;
    }
    // --- END UPDATED STATUS MAPPING LOGIC ---

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
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      // USE THE NEW displayStatus VARIABLE
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
           // Corrected Code Snippet for trailing:
            trailing: SizedBox(
              width: 70,
              child: Column(
                // Use MainAxisAlignment.spaceBetween to distribute the space better
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // This Text will naturally go to the top
                  Text(
                    accessCode,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  // Only show delete button for active/pending codes
                  if (status.toLowerCase() == 'active' || status.toLowerCase() == 'pending')
                    // FIX: Wrap IconButton in a SizedBox to constrain its size and 
                    // reduce the default padding.
                    SizedBox( 
                      height: 30, // Reduced height for the button/icon area
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), // Reduced icon size
                        padding: EdgeInsets.zero, // Remove internal button padding
                        constraints: const BoxConstraints(), // Remove external button constraints
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
      title: const Text('Delete Visitor Code'),
      content: const Text('Are you sure you want to delete this visitor code?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Close dialog first before any async call
            Navigator.pop(dialogContext);

            // ✅ Get provider before async call
            final historyProvider = Provider.of<HistoryProvider>(
              context,
              listen: false,
            );

            try {
              await historyProvider.deleteVisitorCode(codeId);

              // ✅ Use mounted check before UI update
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