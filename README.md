# [STSWENG] Biotech Lab System
An inventory system containing transactions from the company's suppliers and their clients.

## Table of Contents

- [Setup](#setup)
- [Flutter Commands](#flutter-commands)
- [Resources](#resources)


## Setup
1. Clone the repository
```bash
git clone https://github.com/Patthethicc/Biotech_Lab_System
cd Biotech_Lab_System
```
2. Create `.env` files for both:
- `frontend/`
- `lis/`(backend)
3. Delete `pubspec.lock` file in `frontend/` and run:
```bash
flutter clean
flutter pub get
```
4. Access `lis/` and run:
```bash 
cd lis 
mvn spring-boot:run #
```
4. Run the frontend:
```bash
cd frontend 
flutter run
```

## Flutter Commands
- Run Flutter with specific entry:
```bash
flutter run -t lib/models/ui/main.dart
```

## Resources


