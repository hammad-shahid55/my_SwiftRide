# SwiftRide Testing Guide

This directory contains all the tests for the SwiftRide Flutter application.

## Test Structure

```
test/
├── widget_test/           # Widget unit tests
│   ├── custom_text_field_test.dart
│   ├── main_button_test.dart
│   └── custom_text_widget_test.dart
├── unit_test/            # Screen and logic unit tests
│   ├── splash_screen_test.dart
│   ├── sign_in_screen_test.dart
│   └── test_runner.dart
├── test_config.dart      # Test configuration and utilities
└── README.md            # This file

integration_test/
├── app_test.dart         # Main E2E tests
└── driver_flow_test.dart # Driver-specific E2E tests
```

## Running Tests

### Unit Tests
```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/widget_test/custom_text_field_test.dart

# Run tests with coverage
flutter test --coverage
```

### Integration Tests
```bash
# Run integration tests on device/emulator
flutter test integration_test/app_test.dart

# Run all integration tests
flutter test integration_test/
```

### Widget Tests
```bash
# Run only widget tests
flutter test test/widget_test/
```

## Test Categories

### Widget Tests
- **CustomTextField**: Tests form validation, password visibility, email validation
- **MainButton**: Tests button functionality, styling, and interactions
- **CustomTextWidget**: Tests text display, styling, and layout

### Unit Tests
- **SplashScreen**: Tests screen initialization, animations, and navigation
- **SignInScreen**: Tests form elements, validation, and user interactions

### Integration Tests
- **App Flow**: Tests complete user journeys from app launch to key features
- **Driver Flow**: Tests driver-specific functionality and registration

## Test Configuration

The `test_config.dart` file contains:
- Default timeouts and durations
- Test data constants
- Helper methods for common test operations
- Test data factory methods

## Best Practices

1. **Test Isolation**: Each test should be independent and not rely on other tests
2. **Descriptive Names**: Use clear, descriptive test names that explain what is being tested
3. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification phases
4. **Mock External Dependencies**: Use mocks for network calls, databases, and external services
5. **Test Edge Cases**: Include tests for error conditions and edge cases

## Dependencies

The following testing dependencies are included in `pubspec.yaml`:
- `flutter_test`: Core Flutter testing framework
- `integration_test`: End-to-end testing framework
- `mockito`: Mocking framework for unit tests
- `build_runner`: Code generation for mocks

## Coverage

To generate test coverage reports:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Continuous Integration

Tests should be run automatically in CI/CD pipelines:
- Unit tests should run on every commit
- Integration tests should run on pull requests
- All tests should pass before merging to main branch
