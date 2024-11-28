import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'dashboard_service.dart'; // Import the service

class Dashboard extends StatefulWidget {
  final String email;
  const Dashboard({Key? key, required this.email}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? userRole; // To store the role of the logged-in user
  List<Map<String, dynamic>> comments = []; // Store comments with details
  bool isLoading = true;

  final DashboardService _dashboardService = DashboardService(); // Create an instance of the service

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    _fetchComments();
  }

  // Fetch the user's role
  Future<void> _fetchUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final role = await _dashboardService.fetchUserRole(accessToken);
    setState(() {
      userRole = role;
    });

    // Navigate based on the user's role
    if (userRole == "admin") {
      Navigator.pushReplacementNamed(context, '/adminDashboard');
    } else if (userRole == "moderator") {
      Navigator.pushReplacementNamed(context, '/moderatorDashboard');
    } else if (userRole == "user") {
      Navigator.pushReplacementNamed(context, '/userDashboard');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Fetch comments
  Future<void> _fetchComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) return;

    final fetchedComments = await _dashboardService.fetchComments(accessToken);
    setState(() {
      comments = fetchedComments;
    });
  }

  // Post a comment
  Future<void> _postComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) return;

    final success = await _dashboardService.postComment(widget.email, comment, accessToken);
    if (success) {
      _fetchComments(); // Refresh comments after posting
    } else {
      print('Failed to post comment.');
    }
  }

  // Delete a comment
  Future<void> _deleteComment(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) return;

    final success = await _dashboardService.deleteComment(id, accessToken);
    if (success) {
      _fetchComments(); // Refresh comments after deletion
    } else {
      print('Failed to delete comment.');
    }
  }

  // Show popup to add a comment
  void _showAddCommentDialog() {
    String commentText = "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Add Comment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[300],
        content: TextField(
          onChanged: (value) => commentText = value,
          decoration: const InputDecoration(
            hintText: "Enter your comment",
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentText.isNotEmpty) {
                _postComment(commentText);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        centerTitle: true,
        foregroundColor: Colors.white,
        title: Text(userRole != null ? "Role: $userRole" : "Loading...", style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (userRole == "admin" || userRole == "moderator")
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
                onPressed: _showAddCommentDialog,
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.green[100],
                  child: ListTile(
                    title: Text(
                      'Comments: ' + (comment['comment'] ?? 'No comment available'),
                      style: TextStyle(fontSize: 20),
                    ),
                    subtitle: Text(
                      "By: ${comment['email'] ?? 'Unknown'}",
                    ),
                    trailing: (userRole == "admin" || userRole == "moderator")
                        ? IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteComment(comment['id']),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
