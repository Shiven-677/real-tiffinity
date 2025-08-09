import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  const SearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ), // adjust roundedness
                ),
                hintText: 'Search...',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }
}
