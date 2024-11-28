import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

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

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:5000/get_role'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final roleData = json.decode(response.body);
        setState(() {
          userRole = roleData['role'];
        });

        // Navigate based on the user's role
        if (userRole == "admin") {
          Navigator.pushReplacementNamed(context, '/adminDashboard');
        } else if (userRole == "moderator") {
          Navigator.pushReplacementNamed(context, '/moderatorDashboard');
        } else if (userRole == "user") {
          Navigator.pushReplacementNamed(context, '/userDashboard');
        }
      }
    } catch (e) {
      print('Error fetching role: $e');
    }
  }

  // Fetch comments
  Future<void> _fetchComments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.6:5000/get_comments'), // Replace with your API endpoint
        headers: {'Authorization': 'Bearer $accessToken',"Content-Type": "application/json",},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          comments = List<Map<String, dynamic>>.from(data['comments']);
          print(comments);
        });
      }
    } catch (e) {
      print('Error fetching comments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Post a comment
  Future<void> _postComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.6:5000/post_comment'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',  // Added this header
        },
        body: json.encode({
          'email': widget.email, // Send the user's email with the comment
          'comments': comment,
        }),
      );

      if (response.statusCode == 201) {
        _fetchComments(); // Refresh comments after posting
      } else {
        print('Failed to post comment. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting comment: $e');
    }
  }

  // Delete a comment
  Future<void> _deleteComment(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://192.168.1.6:5000/delete_comment/$id'), // Replace with your API endpoint
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        _fetchComments(); // Refresh comments
      }
    } catch (e) {
      print('Error deleting comment: $e');
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
        title: Text(userRole != null ? "Role: $userRole" : "Loading...",style: TextStyle(color: Colors.white),),
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
                      'Comments : '+comment['comment'] ?? 'No comment available',  // Ensure comment is not null
                      style: TextStyle(
                        color: comment['comments'] == null ? Colors.black87 : Colors.black, // Set grey if null
                        fontSize: 20
                      ),
                    ),
                    subtitle: Text(
                      "By: ${comment['email'] ?? 'Unknown'}",  // Ensure email is not null
                      style: TextStyle(
                        color: comment['email'] == null ? Colors.grey : Colors.black, // Set grey if null
                      ),
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
          )

        ],
      ),
    );
  }
}
