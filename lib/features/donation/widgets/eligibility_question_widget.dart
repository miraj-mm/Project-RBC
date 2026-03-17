import 'package:flutter/material.dart';
import '../../../core/core.dart';

class EligibilityQuestionWidget extends StatefulWidget {
  final String question;
  final String questionId;
  final bool isRequired;
  final Function(bool?) onAnswerChanged;

  const EligibilityQuestionWidget({
    super.key,
    required this.question,
    required this.questionId,
    required this.isRequired,
    required this.onAnswerChanged,
  });

  @override
  State<EligibilityQuestionWidget> createState() => _EligibilityQuestionWidgetState();
}

class _EligibilityQuestionWidgetState extends State<EligibilityQuestionWidget> {
  bool? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: _selectedAnswer == null 
              ? AppColors.inputBorder 
              : AppColors.primaryRed.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppSizes.paddingM),
          
          // Answer Options
          Row(
            children: [
              // Yes Option
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectAnswer(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingS,
                      horizontal: AppSizes.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedAnswer == true 
                          ? AppColors.success 
                          : AppColors.getBorderColor(context),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color: _selectedAnswer == true 
                            ? AppColors.success 
                            : AppColors.inputBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedAnswer == true 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: _selectedAnswer == true 
                              ? AppColors.white 
                              : AppColors.getTextSecondaryColor(context),
                          size: AppSizes.iconS,
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Text(
                          'Yes',
                          style: TextStyle(
                            color: _selectedAnswer == true 
                                ? AppColors.white 
                                : AppColors.getTextSecondaryColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppSizes.paddingM),
              
              // No Option
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectAnswer(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingS,
                      horizontal: AppSizes.paddingM,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedAnswer == false 
                          ? AppColors.error 
                          : AppColors.getBorderColor(context),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color: _selectedAnswer == false 
                            ? AppColors.error 
                            : AppColors.inputBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedAnswer == false 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_unchecked,
                          color: _selectedAnswer == false 
                              ? AppColors.white 
                              : AppColors.getTextSecondaryColor(context),
                          size: AppSizes.iconS,
                        ),
                        const SizedBox(width: AppSizes.paddingS),
                        Text(
                          'No',
                          style: TextStyle(
                            color: _selectedAnswer == false 
                                ? AppColors.white 
                                : AppColors.getTextSecondaryColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAnswer(bool answer) {
    setState(() {
      _selectedAnswer = answer;
    });
    widget.onAnswerChanged(answer);
  }
}
