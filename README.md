# Vouched Plugin for Flutter

## Running Example App
To run the example app properly, an API KEY is required.

The API KEY can be provided in two ways:

1. Using `VouchedScanner`:
```dart
VouchedScanner(
  apiKey: <YOUR-API-KEY>,
)
```

2. At build time:
```shell
flutter run --dart-define=VOUCHED_API_KEY=<YOUR-API-KEY>
```

