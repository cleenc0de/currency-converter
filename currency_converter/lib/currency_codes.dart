const Map<String, String> countryCurrencyCodes = {
  "DE": "EUR",
  "UK": "GBP",
  "US": "USD",
};

String getCurrencyCode(String countryName) {
  return countryCurrencyCodes[countryName] ?? 'unknown';
}