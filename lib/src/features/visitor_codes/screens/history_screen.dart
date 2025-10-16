import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vms_resident_app/src/features/visitor_codes/providers/visit_history_provider.dart'; // Import the new provider

// Define the filter options
const List<String> _filters = ['This Week', 'This Month', 'Last 3 Months'];

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  String _selectedFilter = 'This Month';
  
  @override
  void initState() {
    super.initState();
    // Ensures the initial data is fetched based on the default filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false).setFilter(_selectedFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit History'),
        centerTitle: true,
        elevation: 0,
        actions: const [
          // Placeholder for the filter icon from the design
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.sort, color: Colors.blue),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          
          // History List
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: provider.historyList.length,
                  itemBuilder: (context, index) {
                    final log = provider.historyList[index];
                    return _HistoryLogTile(log: log);
                  },
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _filters.map((filter) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  Provider.of<HistoryProvider>(context, listen: false).setFilter(filter);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedFilter == filter ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: _selectedFilter == filter ? Colors.white : Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ... (VisitHistoryScreen and _buildFilterTabs remain unchanged)

class _HistoryLogTile extends StatelessWidget {
 final dynamic log; // Map<String, dynamic> representing an EntryLog

 const _HistoryLogTile({required this.log});

 @override
 Widget build(BuildContext context) {
    // Keys observed in the debug output: code, visitor_name, validated_at, result, gate
    
  final String visitorName = log['visitor_name'] ?? 'Unnamed Visitor';
    // The access code key is 'code' in the API response, not 'access_code'
  final String accessCode = log['code'] ?? 'XXXXX'; // ✅ FIX 1: Use 'code' instead of 'access_code'
  final String status = log['result'] ?? 'Pending'; // ✅ FIX 2: Use 'result' instead of 'status'
    
    // Check for 'validated_at' as the entry timestamp
  final DateTime? entryTime = log['validated_at'] != null 
    ? DateTime.tryParse(log['validated_at'])?.toLocal() // ✅ FIX 3: Use 'validated_at' instead of 'entry_time'
    : null;

  Color statusColor;
  String statusText;

  if (status == 'granted') { // Status value is lowercase 'granted'
   statusColor = Colors.green;
   statusText = 'Granted ${entryTime != null ? DateFormat('HH:mm a').format(entryTime) : ''}';
  } else if (status == 'denied') { // Status value would likely be lowercase 'denied'
   statusColor = Colors.red;
   statusText = 'Denied';
  } else {
   statusColor = Colors.orange;
   statusText = 'Pending';
  }
  
  final String dateDisplay = entryTime != null 
    ? DateFormat('MMM d, yyyy').format(entryTime) 
    : 'Unknown Date';

  return Container(
   padding: const EdgeInsets.symmetric(vertical: 12),
   decoration: BoxDecoration(
    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
   ),
   child: Row(
    children: [
     // Status Indicator
     CircleAvatar(
      radius: 4,
      backgroundColor: statusColor,
     ),
     const SizedBox(width: 12),

     // Visitor Info
     Expanded(
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
        Text(
         visitorName,
         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
         '$dateDisplay at ${entryTime != null ? DateFormat('h:mm a').format(entryTime) : 'N/A'}',
         style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        if (status != 'granted') // Check the lowercase status
         Text(
          statusText,
          style: TextStyle(color: statusColor, fontSize: 13),
         ),
       ],
      ),
     ),
     
     // Code and Chevron
     Row(
      children: [
       Text(
        accessCode,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
       ),
       const Icon(Icons.chevron_right, color: Colors.grey),
      ],
     ),
    ],
   ),
  );
 }
}