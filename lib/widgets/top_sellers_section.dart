import 'package:flutter/material.dart';

class TopSellersSection extends StatelessWidget {
  const TopSellersSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hide this section until we have a sellers endpoint in the backend
    return const SizedBox.shrink();

    // TODO: Implement when sellers/shops endpoint is available
    // final screenWidth = MediaQuery.of(context).size.width;
    // final isTablet = screenWidth >= 650;
    // final listHeight = isTablet ? 160.0 : 140.0;
    //
    // return Column(
    //   children: [
    //     SectionHeader(
    //       title: 'Top Sellers',
    //       subtitle: 'Trusted stores for you',
    //       icon: Icons.store_rounded,
    //       onViewAll: () {},
    //     ),
    //     // Seller cards will go here
    //   ],
    // );
  }
}
