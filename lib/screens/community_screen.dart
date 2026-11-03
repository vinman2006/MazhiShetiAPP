import 'package:flutter/material.dart';
import '../models/farmer_profile.dart';

class CommunityScreen extends StatefulWidget {
  final FarmerProfileState? profileState;
  const CommunityScreen({super.key, this.profileState});

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
      comments: [
        'I am leaving from Kalmeshwar at 6 AM, have space for 20 bags.',
        'What rate did you get yesterday in Nagpur mandi?',
      ],
    ),
    CommunityPost(
      author: 'Sunil Wankhede',
      village: 'Hingna, Nagpur',
      time: '5 hours ago',
      content: 'Tested Lok-1 wheat seed germination rate today — got 92% germination after 72 hours. Certified seeds available at Hingna Taluka Krishi Kendra.',
      upvotes: 34,
      comments: [
        'Very good germination rate! Did you do fungicide seed treatment first?',
      ],
    ),
    CommunityPost(
      author: 'Ganesh Bhoyar',
      village: 'Katol, Nagpur',
      time: 'Yesterday',
      content: 'Early morning light frost alert for Katol orange orchards this week. Suggest giving light evening irrigation to preserve root temperature.',
      upvotes: 52,
      comments: [
        'Thanks for the alert, turning on the drip tonight.',
      ],
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

    final p = widget.profileState;
    final authorName = (p != null && p.fullName.trim().isNotEmpty) ? p.fullName : 'Farmer User';
    final location = (p != null && p.village.isNotEmpty && p.selectedDistrict != null)
        ? '${p.village}, ${p.selectedDistrict}'
        : (p?.selectedLocation.isNotEmpty == true ? p!.selectedLocation : 'Nagpur, Maharashtra');

    setState(() {
      _posts.insert(
        0,
        CommunityPost(
          author: authorName,
          village: location,
          time: 'Just now',
          content: text,
          upvotes: 1,
          comments: [],
        ),
      );
    });
    _postController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showCommentsSheet(CommunityPost post) {
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(ctx).viewInsets.bottom + 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: Color(0xFF044D3D)),
                    const SizedBox(width: 8),
                    Text(
                      'Comments (${post.comments.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF072A2C)),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FCF7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5EDE2)),
                  ),
                  child: Text(
                    post.content,
                    style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                if (post.comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text('No comments yet. Be the first to reply!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: post.comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (_, i) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFFD6F0C1),
                            child: Icon(Icons.person, size: 14, color: Color(0xFF044D3D)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              post.comments[i],
                              style: const TextStyle(fontSize: 13, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Add an answer or comment...',
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF9FCF7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFFD6F0C1)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF044D3D),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: () {
                          final text = commentCtrl.text.trim();
                          if (text.isEmpty) return;
                          setState(() {
                            post.comments.add(text);
                          });
                          setSheetState(() {});
                          commentCtrl.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      filled: true,
                      fillColor: const Color(0xFFF9FCF7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFD6F0C1)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addPost,
                  icon: const Icon(Icons.send, color: primaryGreen),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Posts Feed
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: _posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = _posts[index];
                return Container(
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
                            child: Text(
                              p.author.isNotEmpty ? p.author[0].toUpperCase() : 'F',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => setState(() => p.upvotes++),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.thumb_up_alt_outlined, size: 16, color: primaryGreen),
                                  const SizedBox(width: 4),
                                  Text('${p.upvotes}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _showCommentsSheet(p),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: primaryGreen),
                                  const SizedBox(width: 4),
                                  Text('${p.comments.length} Comments', style: const TextStyle(fontSize: 12, color: primaryGreen, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
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
  List<String> comments;

  CommunityPost({
    required this.author,
    required this.village,
    required this.time,
    required this.content,
    required this.upvotes,
    required this.comments,
  });
}
