import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();

  final List<CommunityPost> _posts = [
    CommunityPost(
      author: 'Rameshwarrao Deshmukh',
      village: 'Kalmeshwar, Nagpur',
      time: '2 hours ago',
      content: 'Any farmer going to Nagpur APMC mandi tomorrow morning? Looking to pool 40 bags of Soybean on tractor trolley to reduce transport cost.',
      upvotes: 18,
      comments: 6,
    ),
    CommunityPost(
      author: 'Sunil Wankhede',
      village: 'Hingna, Nagpur',
      time: '5 hours ago',
      content: 'Tested Lok-1 wheat seed germination rate today — got 92% germination after 72 hours. Certified seeds available at Hingna Taluka Krishi Kendra.',
      upvotes: 34,
      comments: 11,
    ),
    CommunityPost(
      author: 'Ganesh Bhoyar',
      village: 'Katol, Nagpur',
      time: 'Yesterday',
      content: 'Early morning light frost alert for Katol orange orchards this week. Suggest giving light evening irrigation to preserve root temperature.',
      upvotes: 52,
      comments: 19,
    ),
  ];

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _addPost() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _posts.insert(
        0,
        CommunityPost(
          author: 'You (Farmer)',
          village: 'Nagpur, Maharashtra',
          time: 'Just now',
          content: text,
          upvotes: 1,
          comments: 0,
        ),
      );
    });
    _postController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF044D3D);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FCF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Farmer Community (1.4k Members)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
        ),
      ),
      body: Column(
        children: [
          // Post Box
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryGreen,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      hintText: 'Share advice or ask fellow farmers...',
                      hintStyle: const TextStyle(fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: const Color(0xFFF6FEF1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFD6F0C1)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: primaryGreen),
                  onPressed: _addPost,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Community Posts Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _posts.length,
              itemBuilder: (context, i) {
                final p = _posts[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EDE2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFD6F0C1),
                            child: Text(p.author[0], style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.author, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                Text('${p.village} • ${p.time}', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(p.content, style: const TextStyle(fontSize: 13, height: 1.35)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => p.upvotes++),
                            child: Row(
                              children: [
                                const Icon(Icons.thumb_up_alt_outlined, size: 16, color: primaryGreen),
                                const SizedBox(width: 4),
                                Text('${p.upvotes}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${p.comments} Comments', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
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

class CommunityPost {
  final String author;
  final String village;
  final String time;
  final String content;
  int upvotes;
  int comments;

  CommunityPost({
    required this.author,
    required this.village,
    required this.time,
    required this.content,
    required this.upvotes,
    required this.comments,
  });
}

