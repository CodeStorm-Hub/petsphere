import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: () {}, 
            child: const Text('Share', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    maxLines: 5,
                    minLines: 1,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.add_a_photo, color: Colors.grey)),
                )
              ],
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('Add Location'),
            trailing: Icon(Icons.chevron_right),
          )
        ],
      ),
    );
  }
}
