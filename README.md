# Biotech_Lab_System
CSSWENG
<h2>How to Run</h2>
1. create .env file on both frontend and lis folder (details from pat) <br>
2. delete pubspec.lock file in frontend and do flutter clean and then flutter pub get <br>
3. cd lis and type mvn spring-boot:run for the backend <br>
4. cd frontend and flutter run for the frontend <br>

<h2>frontend</h2>
1. `flutter run` on the frontend repo <br>
2. `flutter test` to test all function <br>
3. not sure if this applies to all, but i'll just put it here `flutter run -t lib/models/ui/main.dart`

<h2>backend</h2>
1. need endpoints to connect front and backend <br>
2. entities (model) are now implemented
<br>
note: lis is backend

<h2>Notes for this branch</h2>
1. Fix item details, can't call it as a route in main.dart
2. Create service for stock_locator

