import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/helpers.dart';
import '../providers/invoice_provider.dart';
import '../../../routes.dart' as app_routes;

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({
    Key? key,
    required this.invoiceId,
  }) : super(key: key);

  @override
  _InvoiceDetailScreenState createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load invoice details when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false)
          .getInvoiceById(widget.invoiceId);
    });
  }

  @override
  void dispose() {
    // Clear selected invoice when leaving the screen
    Provider.of<InvoiceProvider>(context, listen: false).clearSelectedInvoice();
    super.dispose();
  }

  Future<void> _generateAndPrintInvoice() async {
    final invoice = Provider.of<InvoiceProvider>(context, listen: false).selectedInvoice;
    if (invoice == null) return;

    final pdf = pw.Document();

    // Generate PDF content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('INVOICE',
                            style: pw.TextStyle(
                                fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text('#${invoice.id}',
                            style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Condo Management',
                            style: pw.TextStyle(
                                fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text('123 Condo Street',
                            style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('City, State, 12345',
                            style: const pw.TextStyle(fontSize: 14)),
                        pw.Text('Phone: (123) 456-7890',
                            style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Invoice Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Invoice Date',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(DateFormat('MMM dd, yyyy')
                            .format(invoice.issueDate)),
                        pw.SizedBox(height: 15),
                        pw.Text('Due Date',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(
                            DateFormat('MMM dd, yyyy').format(invoice.dueDate)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Status',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(
                            invoice.isOverdue && invoice.status != 'paid'
                                ? 'OVERDUE'
                                : invoice.status.toUpperCase(),
                            style: pw.TextStyle(
                                color: invoice.isOverdue &&
                                        invoice.status != 'paid'
                                    ? PdfColors.red
                                    : invoice.status == 'paid'
                                        ? PdfColors.green
                                        : PdfColors.orange)),
                        pw.SizedBox(height: 15),
                        pw.Text('Invoice Type',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 5),
                        pw.Text(invoice.invoiceType
                            .split('_')
                            .map((word) =>
                                '${word[0].toUpperCase()}${word.substring(1)}')
                            .join(' ')),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),

                // Invoice Items
                pw.Text('INVOICE ITEMS',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey200,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Item',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Description',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Price',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Total',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Table Items
                    ...invoice.items.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.id),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(item.description),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('${item.quantity}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '\$${item.amount.toStringAsFixed(2)}'),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                                '\$${item.totalAmount.toStringAsFixed(2)}'),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Total
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Text('Total Amount',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Container(
                            width: 120,
                            child: pw.Text(
                                '\$${invoice.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      if (invoice.status == 'paid')
                        pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Container(
                              width: 120,
                              child: pw.Text('Payment ID',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Container(
                              width: 120,
                              child: pw.Text(invoice.paymentId ?? 'N/A'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // Notes
                if (invoice.notes != null && invoice.notes!.isNotEmpty)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Notes',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          border: pw.Border.all(color: PdfColors.grey300),
                        ),
                        child: pw.Text(invoice.notes!),
                      ),
                    ],
                  ),

                pw.Spacer(),

                // Footer
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Thank you for your business. Please contact us if you have any questions.',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'invoice_${invoice.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Invoice Details',
        actions: [
          Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, child) {
              final invoice = invoiceProvider.selectedInvoice;
              if (invoice == null) {
                return const SizedBox.shrink();
              }
              
              return IconButton(
                icon: const Icon(Icons.print),
                onPressed: _generateAndPrintInvoice,
                tooltip: 'Generate PDF',
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        if (invoiceProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (invoiceProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: invoiceProvider.error!,
            onRetry: () => invoiceProvider.getInvoiceById(widget.invoiceId),
          );
        }

        final invoice = invoiceProvider.selectedInvoice;
        if (invoice == null) {
          return const EmptyStateWidget(
            message: 'Invoice not found',
            icon: Icons.error_outline,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Header
              _buildInvoiceHeader(invoice),
              
              const SizedBox(height: 24),
              
              // Invoice Status
              _buildStatusCard(invoice),
              
              const SizedBox(height: 24),
              
              // Invoice Items
              _buildInvoiceItems(invoice),
              
              const SizedBox(height: 24),
              
              // Notes
              if (invoice.notes != null && invoice.notes!.isNotEmpty)
                _buildNotesCard(invoice),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to format invoice type
  String formatInvoiceType(String type) {
    return type.split('_').map((word) => 
      word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}'
    ).join(' ');
  }
  
  Widget _buildInvoiceHeader(invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INVOICE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${invoice.id}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatInvoiceType(invoice.invoiceType),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Issued: ${DateFormat('MMM dd, yyyy').format(invoice.issueDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Due Date and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: invoice.isOverdue && invoice.status != 'paid'
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatCurrency(invoice.amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard(invoice) {
    final isOverdue = invoice.isOverdue && invoice.status != 'paid';
    
    return Container(
      decoration: BoxDecoration(
        color: Helpers.getStatusColor(isOverdue ? 'overdue' : invoice.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Helpers.getStatusColor(isOverdue ? 'overdue' : invoice.status),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isOverdue
                ? Icons.warning
                : invoice.status == 'paid'
                    ? Icons.check_circle
                    : Icons.info,
            color: Helpers.getStatusColor(isOverdue ? 'overdue' : invoice.status),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue
                      ? 'Payment Overdue'
                      : invoice.status == 'paid'
                          ? 'Payment Completed'
                          : 'Payment Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Helpers.getStatusColor(isOverdue ? 'overdue' : invoice.status),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOverdue
                      ? 'This invoice is past due. Please make payment as soon as possible.'
                      : invoice.status == 'paid'
                          ? 'Thank you for your payment. The invoice has been fully paid.'
                          : 'Please complete payment before the due date.',
                  style: TextStyle(
                    color: Helpers.getStatusColor(isOverdue ? 'overdue' : invoice.status).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInvoiceItems(invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            
            // Table Items
            ...invoice.items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(item.description),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Helpers.formatCurrency(item.amount),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Helpers.formatCurrency(item.totalAmount),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            // Total
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  const Spacer(flex: 6),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      Helpers.formatCurrency(invoice.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            
            // Payment Information
            if (invoice.status == 'paid' && invoice.paymentId != null)
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payment,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paid via Transaction #${invoice.paymentId}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotesCard(invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(invoice.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        final invoice = invoiceProvider.selectedInvoice;
        if (invoice == null) {
          return const SizedBox.shrink();
        }

        // Don't show pay button for paid invoices
        if (invoice.status == 'paid') {
          return const SizedBox.shrink();
        }

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
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.payment,
                  arguments: {
                    'amount': invoice.amount,
                    'purpose':
                        'Invoice Payment - ${formatInvoiceType(invoice.invoiceType)}',
                    'referenceId': invoice.id,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: invoice.isOverdue ? Colors.red : null,
              ),
              child: const Text('Pay Now'),
            ),
          ),
        );
      },
    );
  }
}
