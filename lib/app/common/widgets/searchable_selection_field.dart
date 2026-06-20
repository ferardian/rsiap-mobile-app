import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/values/colors.dart';

class SearchableSelectionField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? selectedValue; // The value (e.g., '1')
  final String? selectedLabel; // The label to display (e.g., 'JAWA TENGAH')
  final List<dynamic> items;
  final String itemValueKey;
  final String itemLabelKey;
  final Function(String) onSelected;
  final bool isLoading;

  const SearchableSelectionField({
    Key? key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.selectedValue,
    this.selectedLabel,
    required this.items,
    required this.itemValueKey,
    required this.itemLabelKey,
    required this.onSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: (items.isEmpty && !isLoading)
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  _showSearchDialog(context);
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (selectedValue != null)
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(prefixIcon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedLabel ?? hint,
                    style: GoogleFonts.poppins(
                      color: selectedLabel != null
                          ? AppColors.textPrimary
                          : Colors.grey[400],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  const Icon(Icons.search, size: 20, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchQuery = ''.obs;
    final filteredItems = <dynamic>[].obs;

    // Helper to filter items based on query
    void applyFilter() {
      final q = searchQuery.value;
      if (q.isEmpty) {
        filteredItems.assignAll(items);
      } else {
        filteredItems.assignAll(
          items
              .where(
                (e) => e[itemLabelKey].toString().toLowerCase().contains(
                  q.toLowerCase(),
                ),
              )
              .toList(),
        );
      }
    }

    // Initialize
    applyFilter();

    // Re-filter whenever items source changes (e.g., fetch completes)
    // This makes the dialog reactive to background data loading
    if (items is RxList) {
      (items as RxList).listen((_) => applyFilter());
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: context.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih $label',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.back();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (val) {
                  searchQuery.value = val;
                  applyFilter();
                },
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ketik untuk mencari...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  // Show loading indicator if source is loading
                  if (isLoading && items.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }
                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data tidak ditemukan',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final value = item[itemValueKey].toString();
                      final labelText = item[itemLabelKey].toString();
                      final isSelected = value == selectedValue;

                      return ListTile(
                        dense: true,
                        title: Text(
                          labelText,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          onSelected(value); // We still pass ID for logic
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
