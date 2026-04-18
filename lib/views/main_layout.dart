import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_controller.dart';
import 'home_screen.dart';
import 'pet_profile_screen.dart';
import 'discovery_screen.dart';
import 'marketplace_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;
  final List<bool> _loadedTabs = [true, false, false, false, false];

  Widget _buildScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const DiscoveryScreen();
      case 2:
        return const SizedBox.shrink();
      case 3:
        return const MarketplaceScreen();
      case 4:
        return const PetProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
      if (next != null) {
        setState(() {
          _currentIndex = 4;
          _loadedTabs[4] = true;
        });
      }
    });

    final tabChildren = List<Widget>.generate(5, (index) {
      if (!_loadedTabs[index]) return const SizedBox.shrink();
      return _buildScreenForIndex(index);
    });

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabChildren),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.push('/create_post');
            return;
          }
          setState(() {
            _currentIndex = index;
            _loadedTabs[index] = true;
          });
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
