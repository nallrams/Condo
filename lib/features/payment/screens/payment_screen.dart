import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_selector.dart';
import '../../../routes.dart' as app_routes;

class PaymentScreen extends StatefulWidget {
  final double? amount;
  final String? purpose;
  final String? referenceId;

  const PaymentScreen({
    Key? key,
    this.amount,
    this.purpose,
    this.referenceId,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'credit_card';
  
  // Credit Card Form
  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _cvvCode = '';
  bool _isCvvFocused = false;
  
  // Bank Transfer Form
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  
  // Digital Wallet Form
  final _emailController = TextEditingController();
  
  // Amount and Notes
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Pre-fill the amount if provided
    if (widget.amount != null) {
      _amountController.text = widget.amount!.toString();
    }
    
    // Pre-fill the notes if purpose is provided
    if (widget.purpose != null) {
      _notesController.text = widget.purpose!;
    }
  }
  
  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      _cardNumber = creditCardModel.cardNumber;
      _expiryDate = creditCardModel.expiryDate;
      _cardHolderName = creditCardModel.cardHolderName;
      _cvvCode = creditCardModel.cvvCode;
      _isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
  
  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    final userId = authProvider.currentUser!.id;
    final amount = double.parse(_amountController.text);
    final notes = _notesController.text;
    
    // Different payment details based on method
    Map<String, dynamic>? paymentDetails;
    
    if (_selectedPaymentMethod == 'credit_card') {
      paymentDetails = {
        'cardNumber': _cardNumber.replaceAll(' ', ''),
        'expiryDate': _expiryDate,
        'cardHolderName': _cardHolderName,
        // Don't store CVV for security reasons
      };
    } else if (_selectedPaymentMethod == 'bank_transfer') {
      paymentDetails = {
        'accountName': _accountNameController.text,
        'accountNumber': _accountNumberController.text,
        'bankName': _bankNameController.text,
      };
    } else if (_selectedPaymentMethod == 'digital_wallet') {
      paymentDetails = {
        'email': _emailController.text,
      };
    }
    
    final payment = await paymentProvider.processPayment(
      userId: userId,
      amount: amount,
      paymentMethod: _selectedPaymentMethod,
      referenceId: widget.referenceId ?? 'manual_payment',
      referenceType: widget.referenceId != null ? 'booking' : 'manual',
      paymentDetails: paymentDetails,
      notes: notes,
    );
    
    if (payment != null && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to payment history
      Navigator.pushNamedAndRemoveUntil(
        context,
        app_routes.AppRoutes.paymentHistory,
        (route) => route.settings.name == app_routes.AppRoutes.dashboard,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Make Payment',
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildBody() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        return LoadingOverlay(
          isLoading: paymentProvider.isLoading,
          message: 'Processing payment...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an amount';
                              }
                              if (!Validators.isValidAmount(value)) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                            readOnly: widget.amount != null, // Make read-only if amount is provided
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Payment Purpose / Notes',
                              prefixIcon: Icon(Icons.note),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Method Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PaymentMethodSelector(
                        selectedMethod: _selectedPaymentMethod,
                        onMethodSelected: _onPaymentMethodSelected,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Method Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildPaymentMethodForm(),
                    ),
                  ),
                  
                  // Error message if any
                  if (paymentProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          paymentProvider.error!,
                          style: TextStyle(
                            color: Colors.red.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPaymentMethodForm() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
        return _buildCreditCardForm();
      case 'bank_transfer':
        return _buildBankTransferForm();
      case 'digital_wallet':
        return _buildDigitalWalletForm();
      default:
        return _buildCreditCardForm();
    }
  }
  
  Widget _buildCreditCardForm() {
    return Column(
      children: [
        CreditCardWidget(
          cardNumber: _cardNumber,
          expiryDate: _expiryDate,
          cardHolderName: _cardHolderName,
          cvvCode: _cvvCode,
          showBackView: _isCvvFocused,
          obscureCardNumber: true,
          obscureCardCvv: true,
          isHolderNameVisible: true,
          cardBgColor: Colors.black87,
          labelCardHolder: 'CARD HOLDER',
          onCreditCardWidgetChange: (creditCardBrand) {},
        ),
        CreditCardForm(
          formKey: GlobalKey<FormState>(),
          cardNumber: _cardNumber,
          expiryDate: _expiryDate,
          cardHolderName: _cardHolderName,
          cvvCode: _cvvCode,
          onCreditCardModelChange: _onCreditCardModelChange,
          themeColor: Theme.of(context).primaryColor,
          textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          cardNumberDecoration: const InputDecoration(
            labelText: 'Number',
            hintText: 'XXXX XXXX XXXX XXXX',
            border: OutlineInputBorder(),
          ),
          expiryDateDecoration: const InputDecoration(
            labelText: 'Expiry Date',
            hintText: 'MM/YY',
            border: OutlineInputBorder(),
          ),
          cvvCodeDecoration: const InputDecoration(
            labelText: 'CVV',
            hintText: 'XXX',
            border: OutlineInputBorder(),
          ),
          cardHolderDecoration: const InputDecoration(
            labelText: 'Card Holder',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBankTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Account Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            prefixIcon: Icon(Icons.account_balance),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank Name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter bank name';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildDigitalWalletForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Digital Wallet',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email address';
            }
            if (!Validators.isValidEmail(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildBottomBar() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: paymentProvider.isLoading ? null : _processPayment,
              child: const Text('Confirm Payment'),
            ),
          ),
        );
      },
    );
  }
}
