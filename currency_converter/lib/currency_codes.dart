const Map<String, String> countryCurrencyCodes = {
  "AU": "AUD",
  "BG": "BGN",
  "BR": "BRL",
  "CA": "CAD",
  "CH": "CHF",
  "CN": "CNY",
  "CZ": "CZK",
  "DK": "DKK",
  "DE": "EUR",
  "GB": "GBP",
  "HK": "HKD",
  "HU": "HUF",
  "ID": "IDR",
  "IL": "ILS",
  "IN": "INR",
  "IS": "ISK",
  "JP": "JPY",
  "KR": "KRW",
  "MX": "MXN",
  "MY": "MYR",
  "NO": "NOK",
  "NZ": "NZD",
  "PH": "PHP",
  "PL": "PLN",
  "RO": "RON",
  "SE": "SEK",
  "SG": "SGD",
  "TH": "THB",
  "TR": "TRY",
  "US": "USD",
  "ZA": "ZAR"
};


String getCurrencyCode(String countryName) {
  return countryCurrencyCodes[countryName] ?? 'unknown';
}