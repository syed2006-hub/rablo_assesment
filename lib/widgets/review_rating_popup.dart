import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Review & Ratings Module (DRD Specification)
/// - Star rating (1-5)
/// - 4-5 stars: Simple Thank You
/// - 1-3 stars: Detailed Feedback form with 4 categories (Equipment, Trainer, Facility, Membership)
/// - Multi-line review input box (50 - 500 characters with live character counter and validation)
/// - Automated review reminder simulation (70%, 80%, 90% thresholds)
import 'package:get/get.dart';

/// Review & Ratings Module (DRD Specification)
/// - Star rating (1-5)
/// - 4-5 stars: Simple Thank You
/// - 1-3 stars: Detailed Feedback form with 4 categories (Equipment, Trainer, Facility, Membership)
/// - Multi-line review input box (50 - 500 characters with live character counter and validation)
/// - Automated review reminder simulation (70%, 80%, 90% thresholds)
class ReviewRatingPopup extends StatefulWidget {
  final VoidCallback? onReviewSubmitted;
  final void Function(
    double rating,
    String review,
    List<String> categories,
    Map<String, String> notes,
  )? onSubmit;

  const ReviewRatingPopup({super.key, this.onReviewSubmitted, this.onSubmit});

  static void show({
    BuildContext? context,
    VoidCallback? onReviewSubmitted,
    void Function(
      double rating,
      String review,
      List<String> categories,
      Map<String, String> notes,
    )? onSubmit,
  }) {
    final ctx = context ?? Get.context;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ReviewRatingPopup(
          onReviewSubmitted: onReviewSubmitted,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  @override
  State<ReviewRatingPopup> createState() => _ReviewRatingPopupState();
}

class _ReviewRatingPopupState extends State<ReviewRatingPopup> {
  int _selectedRating = 0; // 1 to 5
  bool _submitted = false;

  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _equipmentOtherController = TextEditingController();
  final TextEditingController _trainerOtherController = TextEditingController();
  final TextEditingController _facilityOtherController = TextEditingController();
  final TextEditingController _managementOtherController = TextEditingController();

  // Selected issues for <= 3 stars
  final Set<String> _selectedIssues = <String>{};

  // Predefined Categories and Subcategories (DRD 2.1)
  final Map<String, List<String>> _categories = {
    'Equipment Issues': [
      'Not enough equipment',
      'Equipment not working',
      'Outdated equipment',
      'Unclean equipment',
      'Long wait for machines',
    ],
    'Trainer Issues': [
      'Unprofessional behavior',
      'Lacking skills or expertise',
      'Not attentive during sessions',
      'Often unavailable or late',
      'Inconsistent guidance',
    ],
    'Facility / Environment Issues': [
      'Poor cleanliness',
      'Unhygienic restrooms',
      'Poor ventilation',
      'Loud music/noise',
      'Insufficient parking',
    ],
    'Membership / Management Issues': [
      'Plan not as described',
      'Booking issues',
      'Payment/refund problems',
      'Unhelpful customer support',
      'Lack of promised classes',
    ],
  };

  @override
  void dispose() {
    _reviewController.dispose();
    _equipmentOtherController.dispose();
    _trainerOtherController.dispose();
    _facilityOtherController.dispose();
    _managementOtherController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    if (_selectedRating == 0) return false;
    if (_selectedRating >= 4) return true;

    // For <= 3 stars, review text must be between 50 and 500 characters
    final textLength = _reviewController.text.trim().length;
    final hasReview = textLength >= 50 && textLength <= 500;
    final hasCategorySelection = _selectedIssues.isNotEmpty;

    return hasReview && hasCategorySelection;
  }

  String? get _reviewErrorText {
    final textLength = _reviewController.text.trim().length;
    if (_selectedRating > 0 && _selectedRating <= 3) {
      if (textLength > 0 && textLength < 50) {
        return 'Review must be at least 50 characters (${50 - textLength} more needed).';
      }
      if (textLength > 500) {
        return 'Review cannot exceed 500 characters.';
      }
    }
    return null;
  }

  void _submitFeedback() {
    final notes = <String, String>{};
    if (_equipmentOtherController.text.trim().isNotEmpty) {
      notes['Equipment'] = _equipmentOtherController.text.trim();
    }
    if (_trainerOtherController.text.trim().isNotEmpty) {
      notes['Trainer'] = _trainerOtherController.text.trim();
    }
    if (_facilityOtherController.text.trim().isNotEmpty) {
      notes['Facility'] = _facilityOtherController.text.trim();
    }
    if (_managementOtherController.text.trim().isNotEmpty) {
      notes['Management'] = _managementOtherController.text.trim();
    }

    widget.onSubmit?.call(
      _selectedRating.toDouble(),
      _reviewController.text.trim(),
      _selectedIssues.toList(),
      notes,
    );
    setState(() => _submitted = true);
    widget.onReviewSubmitted?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return _buildThankYouDialog();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF244F59), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rate Your Experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'How was your recent gym and workout session? Tap a star to rate.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // Star Rating Section (1 to 5 stars)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isFilled = starIndex <= _selectedRating;
                  return IconButton(
                    iconSize: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    icon: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFilled ? Colors.amberAccent : Colors.white30,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = starIndex;
                      });
                    },
                  );
                }),
              ),
            ),

            if (_selectedRating > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _selectedRating >= 4 ? 'Great! ($selectedRatingText)' : 'Needs Improvement ($selectedRatingText)',
                    style: TextStyle(
                      color: _selectedRating >= 4 ? AppColors.primaryBright : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            // High rating quick submit
            if (_selectedRating >= 4) ...[
              const SizedBox(height: 20),
              // Optional compliment text
              TextField(
                controller: _reviewController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Share a compliment (optional)...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0F1E22),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitFeedback,
                  child: const Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],

            // Low rating (1 to 3 stars): Detailed Feedback form (DRD 2.1)
            if (_selectedRating > 0 && _selectedRating <= 3) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF381F1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We value your feedback. Please specify the issue categories below and provide at least 50 characters in your review.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Categories Accordion / Checkboxes
              ..._categories.entries.map((entry) {
                return _buildCategorySection(entry.key, entry.value);
              }),

              const SizedBox(height: 16),

              // Review Input Box (DRD: 50 to 500 characters)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Write Your Review *', style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
                  Text(
                    '${_reviewController.text.trim().length} / 500',
                    style: TextStyle(
                      color: _reviewController.text.trim().length >= 50 ? AppColors.primaryBright : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Write Your Review (Minimum 50 characters)...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF0F1E22),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBright, width: 1.5),
                  ),
                ),
              ),

              if (_reviewErrorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _reviewErrorText!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11.5),
                  ),
                ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? AppColors.primaryBright : Colors.white12,
                    foregroundColor: _isFormValid ? Colors.black : Colors.white38,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isFormValid ? _submitFeedback : null,
                  child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get selectedRatingText {
    switch (_selectedRating) {
      case 5:
        return 'Outstanding';
      case 4:
        return 'Very Good';
      case 3:
        return 'Average';
      case 2:
        return 'Poor';
      case 1:
        return 'Very Poor';
      default:
        return '';
    }
  }

  Widget _buildCategorySection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: items.map((subItem) {
                  final isChecked = _selectedIssues.contains(subItem);
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(subItem, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                    value: isChecked,
                    activeColor: AppColors.primaryBright,
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIssues.add(subItem);
                        } else {
                          _selectedIssues.remove(subItem);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThankYouDialog() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF1D3E35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryBright, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thank You for Your Feedback!',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your review has been submitted successfully. It helps us continually improve your fitness experience.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBright,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
