@echo off
echo Running SwiftRide Tests...
echo.

echo Installing dependencies...
flutter pub get
echo.

echo Running unit tests...
flutter test test/
echo.

echo Running integration tests...
flutter test integration_test/
echo.

echo All tests completed!
pause
