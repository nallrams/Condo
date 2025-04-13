import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/invoice_provider.dart';
import '../widgets/invoice_card.dart';
import '../../../routes.dart' as app_routes;

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  _InvoiceListScreenState createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load user's invoices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
      Provider.of<InvoiceProvider>(context, listen: false).loadUserInvoices(userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Invoices',
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).cardColor,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'All Invoices'),
        ],
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Pending Invoices
        _buildPendingInvoices(),
        
        // All Invoices
        _buildAllInvoices(),
      ],
    );
  }

  Widget _buildPendingInvoices() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        if (invoiceProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (invoiceProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: invoiceProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              invoiceProvider.loadUserInvoices(userId);
            },
          );
        }

        final pendingInvoices = invoiceProvider.pendingInvoices;

        if (pendingInvoices.isEmpty) {
          return const EmptyStateWidget(
            message: 'No pending invoices',
            icon: Icons.check_circle_outline,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pendingInvoices.length,
          itemBuilder: (context, index) {
            final invoice = pendingInvoices[index];
            return InvoiceCard(
              invoice: invoice,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.invoiceDetail,
                  arguments: {'invoiceId': invoice.id},
                );
              },
              onPayNow: () {
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.payment,
                  arguments: {
                    'amount': invoice.amount,
                    'purpose': 'Invoice Payment - ${invoiceProvider.formatInvoiceType(invoice.invoiceType)}',
                    'referenceId': invoice.id,
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAllInvoices() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        if (invoiceProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (invoiceProvider.error != null) {
          return ErrorDisplayWidget(
            errorMessage: invoiceProvider.error!,
            onRetry: () {
              final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
              invoiceProvider.loadUserInvoices(userId);
            },
          );
        }

        final invoices = invoiceProvider.invoices;

        if (invoices.isEmpty) {
          return const EmptyStateWidget(
            message: 'No invoices found',
            icon: Icons.receipt_long,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return InvoiceCard(
              invoice: invoice,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  app_routes.AppRoutes.invoiceDetail,
                  arguments: {'invoiceId': invoice.id},
                );
              },
              onPayNow: invoice.status != 'paid'
                  ? () {
                      Navigator.pushNamed(
                        context,
                        app_routes.AppRoutes.payment,
                        arguments: {
                          'amount': invoice.amount,
                          'purpose': 'Invoice Payment - ${invoiceProvider.formatInvoiceType(invoice.invoiceType)}',
                          'referenceId': invoice.id,
                        },
                      );
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}
