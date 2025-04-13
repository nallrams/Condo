import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Credit Card
        _buildPaymentMethodTile(
          context,
          method: 'credit_card',
          title: 'Credit / Debit Card',
          subtitle: 'Pay with Visa, Mastercard, etc.',
          icon: Icons.credit_card,
        ),
        
        const SizedBox(height: 12),
        
        // Bank Transfer
        _buildPaymentMethodTile(
          context,
          method: 'bank_transfer',
          title: 'Bank Transfer',
          subtitle: 'Pay via bank transfer',
          icon: Icons.account_balance,
        ),
        
        const SizedBox(height: 12),
        
        // Digital Wallet
        _buildPaymentMethodTile(
          context,
          method: 'digital_wallet',
          title: 'Digital Wallet',
          subtitle: 'Pay with PayPal, Google Pay, etc.',
          icon: Icons.account_balance_wallet,
        ),
      ],
    );
  }
  
  Widget _buildPaymentMethodTile(
    BuildContext context, {
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedMethod == method;
    
    return InkWell(
      onTap: () => onMethodSelected(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: method,
              groupValue: selectedMethod,
              onChanged: (value) => onMethodSelected(value as String),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
