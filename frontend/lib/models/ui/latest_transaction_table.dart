import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:frontend/models/api/transaction_entry.dart';
import 'package:intl/intl.dart';

class LatestTransactionsTable extends StatelessWidget {
  final List<TransactionEntry> transactions;
  final bool isLoading;

  const LatestTransactionsTable({
    super.key,
    required this.transactions,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final latest5 = transactions.take(5).toList();
    final dateFormatter = DateFormat('MMM d, yyyy');

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: -4,
          color: const Color.fromARGB(255, 234, 239, 245),
          shadowDarkColor: const Color(0xFFB0CDEB),
          shadowLightColor: Colors.white,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Latest Transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A4C78),
              ),
            ),
            const SizedBox(height: 12),
            isLoading
                ? Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: 2,
                          color: Color.fromARGB(255, 233, 241, 250),
                          boxShape: NeumorphicBoxShape.circle(),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A4C78)),
                          ),
                        ),
                      ),
                    ),
                  )
                : latest5.isEmpty
                    ? const Center(child: Text('No recent transactions'))
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latest5.length,
                      itemBuilder: (context, index) {
                        final tx = latest5[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Item description and brand
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.itemDescription,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2A4C78),
                                      ),
                                    ),
                                    Text(
                                      tx.brand,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Reference and date
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      tx.reference,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2A4C78),
                                      ),
                                    ),
                                    Text(
                                      dateFormatter.format(tx.transactionDate),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${tx.quantity}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2A4C78),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

          ],
        ),
      ),
    );
  }
}
