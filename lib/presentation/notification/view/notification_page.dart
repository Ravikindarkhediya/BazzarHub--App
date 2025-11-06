import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Dummy notification data
  final List<Map<String, String>> notifications = const [
    {
      "title": "New Offer Available!",
      "message": "Flat 20% off on all electronics items.",
      "time": "2 hours ago",
    },
    {
      "title": "Order Shipped 🚚",
      "message": "Your iPhone 14 Pro has been shipped successfully.",
      "time": "Yesterday",
    },
    {
      "title": "Payment Successful 💳",
      "message": "You paid ₹85,000 for iPhone 14 Pro.",
      "time": "2 days ago",
    },
    {
      "title": "Welcome to BazaarHub 🎉",
      "message": "Thanks for joining us! Start exploring amazing deals.",
      "time": "3 days ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: notifications.length,
        separatorBuilder: (context, index) =>
        const Divider(height: 0, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            title: Text(
              item["title"]!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item["message"]!),
            trailing: Text(
              item["time"]!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Example: show simple dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(item["title"]!),
                  content: Text(item["message"]!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
