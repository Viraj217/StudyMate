import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:studymate/features/home/presentation/pages/browse_page.dart';
import 'package:studymate/features/home/presentation/pages/chatbot_page.dart';
import '../pages/notes_page.dart';
import '../pages/todo_page.dart';

class Mybottomnavbar extends StatefulWidget {
  const Mybottomnavbar({super.key});

  @override
  State<Mybottomnavbar> createState() => _MybottomnavbarState();
}

class _MybottomnavbarState extends State<Mybottomnavbar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    TodoPage(),
    NotesPage(),
    ChatbotPage(),
    BrowsePage(),
  ];

  final List<Map<String, dynamic>> _tabData = [
    {'icon': LineIcons.medicalNotes, 'label': 'To-Do'},
    {'icon': LineIcons.stickyNote, 'label': 'Notes'},
    {'icon': LineIcons.robot, 'label': 'Chat'},
    {'icon': LineIcons.bars, 'label': 'Browse'},
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeOutExpo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
          ),
          child: _buildBottomNavBar()),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: Color.fromRGBO(32, 101, 210, 1),
          borderRadius: BorderRadius.circular(45),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            _tabData.length,
            (index) => _buildTabButton(index),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
        child: Container(
          width: isSelected ? 110 : 50,
          height: 65,
          decoration: BoxDecoration(
            color: Color.fromRGBO(32, 101, 210, 1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutExpo,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(45),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(32, 101, 210, 1),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Icon(
                          _tabData[index]['icon'],
                          key: ValueKey(index),
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 2),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: Container(
                          margin: EdgeInsets.only(right: 2),
                          child: Text(
                            _tabData[index]['label'],
                            style: TextStyle(
                              color: Color.fromRGBO(32, 101, 210, 1),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
