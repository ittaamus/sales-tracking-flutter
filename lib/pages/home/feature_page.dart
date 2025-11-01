part of '../library_page.dart';

class FeatureWidget extends StatelessWidget {
  const FeatureWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<CustomIcon> customIcons = [
      CustomIcon(name: "Barang", icon: 'assets/images/barang.png'),
      CustomIcon(name: "Customer", icon: 'assets/images/customer.png'),
      CustomIcon(name: "Order", icon: 'assets/images/order.png'),
      CustomIcon(name: "Invoice", icon: 'assets/images/invoice.png'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(customIcons.length, (index) {
        return Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(90),
              onTap: () {
                switch (customIcons[index].name) {
                  case "Barang":
                    Navigator.pushNamed(context, '/barang');
                    break;
                  case "Customer":
                    Navigator.pushNamed(context, '/customer');
                    break;
                  case "Order":
                    Navigator.pushNamed(context, '/order');
                    break;
                  case "Invoice":
                    Navigator.pushNamed(context, '/invoice');
                    break;
                }
              },
              child: Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(customIcons[index].icon),
              ),
            ),
            const SizedBox(height: 6),
            Text(customIcons[index].name),
          ],
        );
      }),
    );
  }
}

class CustomIcon {
  final String name;
  final String icon;

  CustomIcon({required this.name, required this.icon});
}
