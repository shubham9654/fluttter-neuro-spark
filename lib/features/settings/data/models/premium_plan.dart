/// Premium Plan Model
class PremiumPlan {
  final String id;
  final String name;
  final String description;
  final int priceInCents; // Price in cents (e.g., 999 = $9.99)
  final String currency;
  final String interval; // 'month' or 'year'
  final List<String> features;
  final bool isPopular;
  final String? stripePriceId; // Stripe Price ID for subscriptions

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceInCents,
    this.currency = 'usd',
    required this.interval,
    required this.features,
    this.isPopular = false,
    this.stripePriceId,
  });

  String get formattedPrice {
    final dollars = priceInCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }

  String get pricePerMonth {
    if (interval == 'year') {
      final monthlyPrice = priceInCents / 12;
      return '\$${(monthlyPrice / 100).toStringAsFixed(2)}/mo';
    }
    return '$formattedPrice/mo';
  }

  String get savings {
    if (interval == 'year') {
      final monthlyPrice = 9.99; // Assuming monthly is $9.99
      final yearlyPrice = priceInCents / 100;
      final savings = (monthlyPrice * 12) - yearlyPrice;
      if (savings > 0) {
        return 'Save \$${savings.toStringAsFixed(2)}';
      }
    }
    return '';
  }
}

