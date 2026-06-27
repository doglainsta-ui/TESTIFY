import 'package:flutter/material.dart';
import '../models/question_model.dart'; // Fixed import to match your file structure

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? selectedOption;
  final Function(String) onSelect;
  final VoidCallback? onFlag;
  final VoidCallback? onMistakeCopy;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedOption,
    required this.onSelect,
    this.onFlag,
    this.onMistakeCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Options
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final label = String.fromCharCode(65 + index); // A, B, C, D...
              final isSelected = selectedOption == label;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => onSelect(label),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey[50],
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected ? Colors.black87 : Colors.black54,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onMistakeCopy != null)
                  IconButton.outlined(
                    onPressed: onMistakeCopy,
                    icon: const Icon(Icons.push_pin_outlined),
                    tooltip: 'Add to Mistake Copy',
                  ),
                if (onFlag != null) ...[
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: onFlag,
                    icon: const Icon(Icons.flag_outlined),
                    tooltip: 'Flag question',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
